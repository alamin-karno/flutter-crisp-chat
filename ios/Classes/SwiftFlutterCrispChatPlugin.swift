import Flutter
import UIKit
import Crisp

/// [SwiftFlutterCrispChatPlugin] manages the integration of Crisp Chat SDK with Flutter,
/// handling all method channel callbacks and implementing UIApplicationDelegate methods.
public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {

    // The method channel used to communicate with Flutter
    private var channel: FlutterMethodChannel?

    // Configuration object for Crisp SDK
    private var crispConfig: CrispConfig?

    /// Registers the plugin with the Flutter engine.
    /// This sets up the method channel and adds the plugin as a delegate for method calls.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_crisp_chat", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCrispChatPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    /// Handles method calls from Flutter to native iOS.
    /// The calls are routed to appropriate Crisp SDK methods based on the method name.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "openCrispChat":
            // Open Crisp Chat interface with given configuration
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "No arguments passed.", details: nil))
                return
            }

            // Initialize Crisp configuration from arguments
            let crispConfig = CrispConfig.fromJson(args)
            CrispSDK.configure(websiteID: crispConfig.websiteID)

            // Configure Crisp session if additional data is provided
            if let tokenId = crispConfig.tokenId {
                CrispSDK.setTokenID(tokenID: tokenId)
            }
            if let segment = crispConfig.sessionSegment {
                CrispSDK.session.segment = segment
            }

            // Set user details such as email, nickname, phone, and avatar
            CrispSDK.user.email = crispConfig.user?.email
            CrispSDK.user.nickname = crispConfig.user?.nickName
            CrispSDK.user.phone = crispConfig.user?.phone
            if let avatarURLString = crispConfig.user?.avatar, let avatarURL = URL(string: avatarURLString) {
                CrispSDK.user.avatar = avatarURL
            } else {
                CrispSDK.user.avatar = nil
            }

            // Configure company details if available
            CrispSDK.user.company = crispConfig.user?.company?.toCrispCompany()

            // Present the chat view controller on the root view controller
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(ChatViewController(), animated: true)
            }

        case "resetCrispChatSession":
            // Resets the current Crisp chat session
            CrispSDK.session.reset()
            result(nil)

        case "setSessionString":
            // Sets a custom string attribute in the Crisp session
            guard let args = call.arguments as? [String: Any],
                  let key = args["key"] as? String,
                  let value = args["value"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected key of type String and value of type String.", details: nil))
                return
            }
            CrispSDK.session.setString(value, forKey: key)
            result(nil)

        case "setSessionInt":
            // Sets a custom integer attribute in the Crisp session
            guard let args = call.arguments as? [String: Any],
                  let key = args["key"] as? String,
                  let value = args["value"] as? Int else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected key of type String and value of type Int.", details: nil))
                return
            }
            CrispSDK.session.setInt(value, forKey: key)
            result(nil)

        case "getSessionIdentifier":
            // Retrieves the current session identifier
            if let sessionId = CrispSDK.session.identifier {
                result(sessionId)
            } else {
                result(FlutterError(code: "NO_SESSION", message: "No active session found", details: nil))
            }

        default:
            // Handles unimplemented method calls
            result(FlutterMethodNotImplemented)
        }
    }

    /// Handles registration of device token for push notifications.
    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CrispSDK.setDeviceToken(deviceToken)
    }

    /// Handles incoming notifications and checks if they are Crisp notifications.
    /// If they are Crisp notifications, they are processed by the Crisp SDK. Otherwise, they are handled as usual.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if CrispSDK.isCrispPushNotification(notification) {
            CrispSDK.handlePushNotification(notification)
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
        } else {
            // Notify Flutter or rethrow to allow other handlers to process the notification
            channel?.invokeMethod("onNotificationReceived", arguments: notification.request.content.userInfo)
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound, .badge])
            } else {
                completionHandler([.alert, .sound, .badge])
            }
        }
    }

    /// Handles user interactions with notifications.
    /// Crisp notifications are processed by the Crisp SDK. Non-Crisp notifications are re-thrown.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        if CrispSDK.isCrispPushNotification(notification) {
            CrispSDK.handlePushNotification(notification)
        } else {
            // Notify Flutter about the interaction or rethrow for further processing
            channel?.invokeMethod("onNotificationTapped", arguments: response.notification.request.content.userInfo)
        }
        completionHandler()
    }
}
