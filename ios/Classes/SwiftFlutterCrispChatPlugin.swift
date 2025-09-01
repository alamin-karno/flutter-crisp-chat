import Flutter
import UIKit
import UserNotifications
import Crisp

/// [SwiftFlutterCrispChatPlugin] manages the integration of Crisp Chat SDK with Flutter,
/// handling all method channel callbacks and implementing UIApplicationDelegate methods.
public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // The method channel used to communicate with Flutter
    private var channel: FlutterMethodChannel?

    // Configuration object for Crisp SDK
    private var crispConfig: CrispConfig?

    // Keep a weak reference to any previously set UNUserNotificationCenter delegate
    private weak var previousNotificationCenterDelegate: UNUserNotificationCenterDelegate?

    /// Registers the plugin with the Flutter engine.
    /// This sets up the method channel and adds the plugin as a delegate for method calls.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_crisp_chat", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCrispChatPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)

        // Decide whether to replace the existing UNUserNotificationCenter delegate.
        // If the current delegate is Flutter's lifecycle provider (which multiplexes
        // notifications to all registered plugins), do not replace it to avoid
        // recursive forwarding loops. Otherwise, replace it and forward to the
        // previous delegate so any existing notification handling continues to work
        let center = UNUserNotificationCenter.current()
        var shouldReplaceDelegate = true

        if let existingDelegate = center.delegate {
            if let flutterProviderProtocol = NSProtocolFromString("FlutterAppLifeCycleProvider"),
               (existingDelegate as AnyObject).conforms(to: flutterProviderProtocol) {
                shouldReplaceDelegate = false
            }
        }

        if shouldReplaceDelegate {
            instance.previousNotificationCenterDelegate = center.delegate
            center.delegate = instance
        }
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

        case "pushSessionEvent":
            guard let args = call.arguments as? [String: Any],
                  let name = args["name"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected at least 'name' of type String.", details: nil))
                return
            }

            var eventColor: SessionEventColor = .blue

            if let colorString = args["color"] as? String {
                switch colorString.lowercased() {
                case "black": eventColor = .black
                case "blue": eventColor = .blue
                case "brown": eventColor = .brown
                case "green": eventColor = .green
                case "grey": eventColor = .grey
                case "orange": eventColor = .orange
                case "pink": eventColor = .pink
                case "purple": eventColor = .purple
                case "red": eventColor = .red
                case "yellow": eventColor = .yellow
                default:
                    print("Invalid color string: \(colorString). Using default: .blue")
                    eventColor = .blue
                }
            }

            let event = SessionEvent(name: name, color: eventColor)
            CrispSDK.session.pushEvents([event])
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
        if CrispSDK.isCrispPushNotification(notification) {
            CrispSDK.handlePushNotification(notification)
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
            return
        }

        // Forward to previous delegate if it implements this method
        if let prev = previousNotificationCenterDelegate as? NSObjectProtocol,
           prev.responds(to: #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:))) {
            previousNotificationCenterDelegate?.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
            return
        }

        // Default behavior: do show non-Crisp notifications in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    /// Handles user interactions with notifications.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        if CrispSDK.isCrispPushNotification(notification) {
            CrispSDK.handlePushNotification(notification)
            completionHandler()
            return
        }

        // Forward to previous delegate if it implements this method
        if let prev = previousNotificationCenterDelegate as? NSObjectProtocol,
           prev.responds(to: #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:))) {
            previousNotificationCenterDelegate?.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
            return
        }

        // Fallback: complete
        completionHandler()
    }
}
