import 'package:flutter/foundation.dart';

/// Which Crisp features work on the platform the example is running on.
///
/// Mirrors the platform notes in the `crisp_chat` API docs, so the example
/// can explain why an option does nothing instead of silently ignoring it.
abstract final class PlatformSupport {
  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  static String get name {
    if (kIsWeb) return 'Web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }

  /// `FlutterCrispChat.onCrispEvent` only emits on Android and iOS.
  static bool get liveEvents => isMobile;

  /// Push notifications go through Firebase, which the example only sets up
  /// on Android and iOS.
  static bool get pushNotifications => isMobile;

  /// `CrispConfig.colorMode` is ignored on Android.
  static bool get colorMode => !isAndroid;

  /// `CrispConfig.locale` is ignored on Android and iOS.
  static bool get locale => isWeb || isDesktop;

  /// `CrispConfig.modalPresentationStyle` is iOS-only.
  static bool get modalStyle => isIOS;

  /// `FlutterCrispChat.isSessionOngoing()` always returns `null` on Android.
  static bool get sessionOngoing => !isAndroid;
}
