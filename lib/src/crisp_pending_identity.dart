import 'config.dart';

/// The token and user details set with `FlutterCrispChat.setTokenId` and the
/// user setters on Web and desktop, where the Crisp script may not be loaded
/// yet. They are merged into the [CrispConfig] of the next chat opening.
class CrispPendingIdentity {
  /// The token set with `setTokenId`, or `null` once it was cleared.
  String? tokenId;

  String? email;
  String? signature;
  String? nickname;
  String? phone;
  String? avatar;

  /// Sets the token; `null` clears it.
  void setToken(String? value) => tokenId = value;

  /// Forgets the user details, as a session reset does.
  void clearUser() {
    email = null;
    signature = null;
    nickname = null;
    phone = null;
    avatar = null;
  }

  bool get _hasUser =>
      email != null || nickname != null || phone != null || avatar != null;

  /// Returns [config] with the pending token and user details filled in.
  /// Values passed in [config] take precedence.
  CrispConfig applyTo(CrispConfig config) {
    final configUser = config.user;
    final user = !_hasUser
        ? configUser
        : User(
            email: configUser?.email ?? email,
            signature:
                configUser?.email != null ? configUser?.signature : signature,
            nickName: configUser?.nickName ?? nickname,
            phone: configUser?.phone ?? phone,
            avatar: configUser?.avatar ?? avatar,
            company: configUser?.company,
          );
    return CrispConfig(
      websiteID: config.websiteID,
      tokenId: config.tokenId ?? tokenId,
      sessionSegment: config.sessionSegment,
      enableNotifications: config.enableNotifications,
      user: user,
      modalPresentationStyle: config.modalPresentationStyle,
      localMessages: config.localMessages,
      colorMode: config.colorMode,
      locale: config.locale,
    );
  }
}
