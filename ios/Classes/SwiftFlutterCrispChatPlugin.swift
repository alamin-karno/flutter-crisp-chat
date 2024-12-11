import Flutter
import UIKit
import Crisp
/// [SwiftFlutterCrispChatPlugin] to handle all method channel callback using [FlutterPlugin]
/// and [UIApplicationDelegate] class.
public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {

    private var channel: FlutterMethodChannel?
    private var crispConfig: CrispConfig?

    /// [register] is initialize the Method Channel Call and binding all method call.
    public static func register(with registrar: FlutterPluginRegistrar) {
            let channel = FlutterMethodChannel(name: "flutter_crisp_chat", binaryMessenger: registrar.messenger())
            let instance = SwiftFlutterCrispChatPlugin()
            instance.channel = channel
            registrar.addMethodCallDelegate(instance, channel: channel)
            registrar.addApplicationDelegate(instance)
    }

   /// [handle] is Handling MethodChannel Call and Getting Arguments from methods then pass through the Crisp SDK.
   /// then using ViewController opening the [ChatViewController] in UI.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "openCrispChat":
            guard let args = call.arguments as? [String: Any] else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "No arguments passed.", details: nil))
                        return
                    }
            let crispConfig = CrispConfig.fromJson(args)
            CrispSDK.configure(websiteID: crispConfig.websiteID)

            if let tokenId = crispConfig.tokenId {
                CrispSDK.setTokenID(tokenID: tokenId)
            }

            if let segment = crispConfig.sessionSegment {
                CrispSDK.session.segment = segment
            }

            CrispSDK.user.email = crispConfig.user?.email
            CrispSDK.user.nickname = crispConfig.user?.nickName
            CrispSDK.user.phone = crispConfig.user?.phone

            if let avatarURLString = crispConfig.user?.avatar, let avatarURL = URL(string: avatarURLString) {
                CrispSDK.user.avatar = avatarURL
            } else {
                CrispSDK.user.avatar = nil
            }

            CrispSDK.user.company = crispConfig.user?.company?.toCrispCompany()

            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(ChatViewController(), animated: true)
            }

        case "resetCrispChatSession":
            CrispSDK.session.reset()
            result(nil)

        case "setSessionString":
            guard let args = call.arguments as? [String: Any],
                  let key = args["key"] as? String,
                  let value = args["value"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected key of type String and value of type String.", details: nil))
                return
            }
            CrispSDK.session.setString(value, forKey: key)
            result(nil)

        case "setSessionInt":
            guard let args = call.arguments as? [String: Any],
                  let key = args["key"] as? String,
                  let value = args["value"] as? Int else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected key of type String and value of type Int.", details: nil))
                return
            }
            CrispSDK.session.setInt(value, forKey: key)
            result(nil)

        case "getSessionIdentifier":
                if let sessionId = CrispSDK.session.identifier {
                    result(sessionId)
                } else {
                    result(FlutterError(code: "NO_SESSION", message: "No active session found", details: nil))
                }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            CrispSDK.setDeviceToken(deviceToken)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       if CrispSDK.isCrispPushNotification(notification) {
            CrispSDK.handlePushNotification(notification)
            completionHandler([.banner, .sound])
          } else {
              completionHandler([])
          }
       }

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
       let notification = response.notification
       if CrispSDK.isCrispPushNotification(notification) {
           CrispSDK.handlePushNotification(notification)
       }
       completionHandler()
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                }
            }
        }
        center.delegate = self
        return true
    }
}

