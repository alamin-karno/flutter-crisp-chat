import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Registers all plugins used by the Flutter app.
        // This should typically be one of the first things to run.
        GeneratedPluginRegistrant.register(with: self)

        // Register for Apple Push Notification service (APNs) to receive remote notifications.
        // This is required for third-party services like Crisp that use push notifications.
        UIApplication.shared.registerForRemoteNotifications()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
