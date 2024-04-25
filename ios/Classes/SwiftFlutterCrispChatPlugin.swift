import Flutter
import UIKit
import Crisp
/// [SwiftFlutterCrispChatPlugin] to handle all method channel callback using [FlutterPlugin]
/// and [UIApplicationDelegate] class.
public class SwiftFlutterCrispChatPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {

    private var channel: FlutterMethodChannel?

    /// [register] is initilize the Method Channel Call and binding all method call.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_crisp_chat", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCrispChatPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

   /// [handle] is Handaling MethodChannel Call and Getting Arguments from methods then pass through the Crisp SDK.
   /// then using ViewContoller opening the [ChatViewCrontroller] in UI.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "openCrispChat" {
            guard let args = call.arguments as? [String : Any] else {return}
            let crispConfig = CrispConfig.fromJson(args)
            CrispSDK.configure(websiteID: crispConfig.websiteID)
            if(crispConfig.tokenId != nil){
                CrispSDK.setTokenID(tokenID: crispConfig.tokenId!)
            }
            if(crispConfig.sessionSegment != nil){
                CrispSDK.session.segment = crispConfig.sessionSegment!
            }
            CrispSDK.user.email = crispConfig.user?.email
            CrispSDK.user.nickname = crispConfig.user?.nickName
            CrispSDK.user.phone = crispConfig.user?.phone
            CrispSDK.user.avatar = crispConfig.user?.avatar == nil ? nil : URL(string: crispConfig.user!.avatar!)
            CrispSDK.user.company = crispConfig.user?.company?.toCrispCompany();
            
            if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                viewController.present(ChatViewController(), animated: true)
            }
        }
        else if call.method == "resetCrispChatSession" {
            CrispSDK.session.reset()
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
}

