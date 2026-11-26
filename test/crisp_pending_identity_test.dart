import 'package:crisp_chat/crisp_chat.dart';
import 'package:crisp_chat/src/crisp_pending_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrispPendingIdentity.applyTo', () {
    test('returns the config unchanged when nothing is pending', () {
      final config = CrispConfig(
        websiteID: 'site-id',
        tokenId: 'config-token',
        user: User(email: 'c@example.com'),
        locale: 'fr',
      );
      final applied = CrispPendingIdentity().applyTo(config);
      expect(applied.toJson(), config.toJson());
      expect(applied.locale, 'fr');
    });

    test('fills in the pending token and user details', () {
      final pending = CrispPendingIdentity()
        ..setToken('user-42')
        ..email = 'p@example.com'
        ..signature = 'sig'
        ..nickname = 'Pat';
      final applied = pending.applyTo(CrispConfig(websiteID: 'site-id'));
      expect(applied.tokenId, 'user-42');
      expect(applied.user?.email, 'p@example.com');
      expect(applied.user?.signature, 'sig');
      expect(applied.user?.nickName, 'Pat');
    });

    test('values in the config take precedence', () {
      final pending = CrispPendingIdentity()
        ..setToken('pending-token')
        ..email = 'p@example.com'
        ..signature = 'pending-sig'
        ..phone = '+15550100';
      final applied = pending.applyTo(CrispConfig(
        websiteID: 'site-id',
        tokenId: 'config-token',
        user: User(email: 'c@example.com'),
      ));
      expect(applied.tokenId, 'config-token');
      expect(applied.user?.email, 'c@example.com');
      // The pending signature belongs to the pending email, not this one.
      expect(applied.user?.signature, isNull);
      expect(applied.user?.phone, '+15550100');
    });

    test('a cleared token and user are no longer applied', () {
      final pending = CrispPendingIdentity()
        ..setToken('user-42')
        ..nickname = 'Pat';
      pending
        ..setToken(null)
        ..clearUser();
      final applied = pending.applyTo(CrispConfig(websiteID: 'site-id'));
      expect(applied.tokenId, isNull);
      expect(applied.user, isNull);
    });
  });
}
