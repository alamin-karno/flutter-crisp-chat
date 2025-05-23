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

        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = instance
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
            // Initialize the Crisp SDK with the website ID. This is the first and essential step.
            CrispSDK.configure(websiteID: crispConfig.websiteID)

            // Configure Crisp session if additional data is provided
            // Set the session token ID, if available.
            if let tokenId = crispConfig.tokenId {
                CrispSDK.setTokenID(tokenID: tokenId)
            }
            // Set the session segment, if available.
            if let segment = crispConfig.sessionSegment {
                CrispSDK.session.segment = segment
            }

            // Set user details to provide more context to the support team.
            // Set user's email.
            CrispSDK.user.email = crispConfig.user?.email
            // Set user's nickname.
            CrispSDK.user.nickname = crispConfig.user?.nickName
            // Set user's phone number.
            CrispSDK.user.phone = crispConfig.user?.phone
            // Set user's avatar URL.
            if let avatarURLString = crispConfig.user?.avatar, let avatarURL = URL(string: avatarURLString) {
                CrispSDK.user.avatar = avatarURL
            } else {
                CrispSDK.user.avatar = nil
            }

            // Set company details for the user, if available.
            CrispSDK.user.company = crispConfig.user?.company?.toCrispCompany()

            // Present the chat view controller.
            // This sequence finds the key window's root view controller to present the chat UI modally.
            if let viewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController {
                viewController.present(ChatViewController(), animated: true)
            }

            result(nil)

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
            
        case "setSessionSegments":
            // Sets session segment
            guard let args = call.arguments as? [String: Any],
                  let segments = args["segments"] as? [String],
                  let overwrite = args["overwrite"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected segments of type String and overwrite of type Bool.", details: nil))
                return
            }
            
            let previousSegments = CrispSDK.session.segments
            CrispSDK.session.segments = overwrite ? segments : (previousSegments ?? []) + segments
            result(nil)
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
    /// If they are, they are processed by the Crisp SDK.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Check if the incoming notification is from Crisp.
        if CrispSDK.isCrispPushNotification(notification) {
            // If it's a Crisp notification, let the Crisp SDK handle it.
            CrispSDK.handlePushNotification(notification)
            // Specify presentation options for the notification when the app is in the foreground.
            // .banner (iOS 14+) or .alert (older iOS) shows the notification content, .sound plays a sound.
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
        } else {
            // If not a Crisp notification, don't show any specific presentation options here.
            // This allows other notification handling logic (if any) to take over.
            completionHandler([])
        }
    }

    /// Handles user interactions with notifications.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        if CrispSDK.isCrispPushNotification(notification) {
            CrispSDK.handlePushNotification(notification)
        }
        completionHandler()
    }
}
