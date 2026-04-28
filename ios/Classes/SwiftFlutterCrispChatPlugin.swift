import Flutter
import UIKit
import Crisp

/// [SwiftFlutterCrispChatPlugin] manages the integration of Crisp Chat SDK with Flutter,
/// handling all method channel callbacks and implementing UIApplicationDelegate methods.
public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    private var channel: FlutterMethodChannel?
    private var crispConfig: CrispConfig?

    /// Dedicated window used to present the Crisp chat.
    ///
    /// Using a separate UIWindow means Flutter's own window is never covered,
    /// so FlutterViewController never pauses its rendering engine — eliminating
    /// the black screen that occurs when a fullScreen modal dismisses over
    /// FlutterViewController. The window also intercepts all touch events while
    /// visible, preventing tap-through to the Flutter UI underneath.
    private var chatWindow: UIWindow?

    /// Registers the plugin with the Flutter engine.
    /// This sets up the method channel and adds the plugin as a delegate for method calls.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_crisp_chat", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCrispChatPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)

        UNUserNotificationCenter.current().delegate = instance

        // Register for remote notifications as required by Crisp SDK
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    /// Handles method calls from Flutter to native iOS.
    /// The calls are routed to appropriate Crisp SDK methods based on the method name.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "openCrispChat":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "No arguments passed.", details: nil))
                return
            }

            let crispConfig = CrispConfig.fromJson(args)
            let websiteID = crispConfig.websiteID.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !websiteID.isEmpty else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Crisp website ID not found.",
                        details: nil
                    )
                )
                return
            }

            CrispSDK.configure(websiteID: websiteID)
            CrispSDK.setShouldPromptForNotificationPermission(crispConfig.enableNotifications)

            if let tokenId = crispConfig.tokenId {
                CrispSDK.setTokenID(tokenID: tokenId)
            }
            if let segment = crispConfig.sessionSegment {
                CrispSDK.session.segment = segment
            }

            CrispSDK.user.email = crispConfig.user?.email
            CrispSDK.user.signature = crispConfig.user?.signature
            CrispSDK.user.nickname = crispConfig.user?.nickName
            CrispSDK.user.phone = crispConfig.user?.phone
            if let avatarURLString = crispConfig.user?.avatar, let avatarURL = URL(string: avatarURLString) {
                CrispSDK.user.avatar = avatarURL
            } else {
                CrispSDK.user.avatar = nil
            }

            CrispSDK.user.company = crispConfig.user?.company?.toCrispCompany()

            openChat(modalPresentationStyle: crispConfig.modalPresentationStyle)

            result(nil)

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

        case "setSessionSegments":
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

        case "openChatboxFromNotification":
            result(false)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Opens the Crisp chat in a dedicated UIWindow.
    ///
    /// The chat window sits above Flutter's window at `.alert` level.
    /// Flutter's window is never covered, so its rendering engine never pauses —
    /// no black screen on dismiss. The chat window intercepts all touches while
    /// visible — no tap-through to Flutter.
    private func openChat(modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        guard chatWindow == nil,
              let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        let chatVC = ChatViewController()
        chatVC.modalPresentationStyle = modalPresentationStyle

        let hostVC = CrispChatHostViewController(chatViewController: chatVC) { [weak self] in
            self?.chatWindow?.isHidden = true
            self?.chatWindow = nil
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = hostVC
        window.windowLevel = .alert
        window.makeKeyAndVisible()
        chatWindow = window
    }

    /// Handles registration of device token for push notifications.
    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        print("[CrispPlugin] Device token registered")
        #endif
        CrispSDK.setDeviceToken(deviceToken)
    }

    /// Handles incoming notifications and checks if they are Crisp notifications.
    /// If they are, they are processed by the Crisp SDK.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        #if DEBUG
        print("[CrispPlugin] willPresent notification called")
        #endif
        if CrispSDK.isCrispPushNotification(notification) {
            #if DEBUG
            print("[CrispPlugin] Crisp notification detected in willPresent")
            #endif
            CrispSDK.handlePushNotification(notification)
            if #available(iOS 14.0, *) {
                completionHandler([.banner, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
        } else {
            #if DEBUG
            print("[CrispPlugin] Non-Crisp notification in willPresent")
            #endif
            completionHandler([])
        }
    }

    /// Handles user interactions with notifications.
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        #if DEBUG
        print("[CrispPlugin] didReceive notification response called")
        #endif
        let notification = response.notification
        if CrispSDK.isCrispPushNotification(notification) {
            #if DEBUG
            print("[CrispPlugin] Crisp notification tapped - opening chat")
            #endif
            CrispSDK.handlePushNotification(notification)

            DispatchQueue.main.async { [weak self] in
                self?.openChat()
            }
        } else {
            #if DEBUG
            print("[CrispPlugin] Non-Crisp notification tapped")
            #endif
        }
        completionHandler()
    }
}

/// A transparent host view controller that is the root of the chat UIWindow.
///
/// Presents ChatViewController as soon as it appears, then hides the entire
/// chat window when ChatViewController is dismissed — without touching
/// Flutter's view hierarchy or rendering engine.
private class CrispChatHostViewController: UIViewController {
    private let chatViewController: ChatViewController
    private let onDismissed: () -> Void
    private var hasPresentedChat = false
    private var pendingDismissalCheck: DispatchWorkItem?

    init(chatViewController: ChatViewController, onDismissed: @escaping () -> Void) {
        self.chatViewController = chatViewController
        self.onDismissed = onDismissed
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasPresentedChat else { return }
        hasPresentedChat = true
        attachSentinelAndPresent(chatViewController)
    }

    private func attachSentinelAndPresent(_ viewController: UIViewController) {
        let sentinel = CrispDismissalSentinel { [weak self] in
            self?.scheduleDismissalCheck()
        }
        sentinel.attach(to: viewController.view)
        present(viewController, animated: true)
    }

    /// Called whenever a sentinel detects that its host view left the window hierarchy.
    ///
    /// Defers the actual decision to the next main-queue cycle. This gives the Crisp SDK
    /// a chance to synchronously re-present another VC (e.g. a camera picker after a
    /// camera-permission grant) before we decide whether the dismissal was user-initiated.
    ///
    /// - If Crisp re-presented something: attach a new sentinel to track that VC.
    /// - If nothing was re-presented: treat as a real user dismissal and tear down the window.
    private func scheduleDismissalCheck() {
        pendingDismissalCheck?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if let newVC = self.presentedViewController {
                // Crisp SDK re-presented a VC (e.g. camera picker). Track its dismissal.
                let newSentinel = CrispDismissalSentinel { [weak self] in
                    self?.scheduleDismissalCheck()
                }
                newSentinel.attach(to: newVC.view)
            } else {
                self.onDismissed()
            }
        }
        pendingDismissalCheck = workItem
        DispatchQueue.main.async(execute: workItem)
    }
}

/// Invisible zero-size view embedded in a view controller's view hierarchy.
///
/// UIKit removes the view from its window after any dismissal animation completes,
/// regardless of modalPresentationStyle. `didMoveToWindow` with `window == nil` is
/// therefore a reliable cross-style dismissal signal.
private class CrispDismissalSentinel: UIView {
    private let onDismissed: () -> Void
    private var hasBeenInWindow = false
    private var hasFired = false

    init(onDismissed: @escaping () -> Void) {
        self.onDismissed = onDismissed
        super.init(frame: .zero)
        isHidden = true
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attach(to view: UIView) {
        view.addSubview(self)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            hasBeenInWindow = true
        } else if hasBeenInWindow && !hasFired {
            hasFired = true
            onDismissed()
        }
    }
}
