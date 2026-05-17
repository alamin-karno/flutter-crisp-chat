#import "FlutterCrispChatPlugin.h"
#if __has_include(<crisp_chat/crisp_chat-Swift.h>)
#import <crisp_chat/crisp_chat-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "crisp_chat-Swift.h"
#endif

@implementation FlutterCrispChatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCrispChatPlugin registerWithRegistrar:registrar];
}
@end
