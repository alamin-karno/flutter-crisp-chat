import Flutter
import UIKit
import Crisp

public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
  private var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_crisp_chat", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCrispChatPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "openCrispChat" {
            guard let args = call.arguments as? [String : Any] else {return}
            let websiteID = args["websiteID"] as! String
            CrispSDK.configure(websiteID: websiteID)
            if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.present(ChatViewController(), animated: true)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

