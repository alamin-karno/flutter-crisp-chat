package com.alaminkarno.flutter_crisp_chat;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import im.crisp.client.external.notification.CrispNotificationClient;

/**
 * A custom {@link FirebaseMessagingService} that handles Crisp push notifications
 * without automatically opening the ChatActivity when a notification is tapped.
 * <p>
 * This service is intended for users who want to control when the Crisp chatbox
 * is opened after a notification tap (e.g., showing the app's main screen first).
 * <p>
 * When a user taps a Crisp notification, it will launch the app's MainActivity
 * without auto-opening the Crisp ChatActivity. You can then call
 * {@code FlutterCrispChat.openChatboxFromNotification()} from Dart to open the chatbox.
 * <p>
 * To use this service, declare it in your {@code AndroidManifest.xml}:
 * <pre>
 * &lt;service
 *     android:name="com.alaminkarno.flutter_crisp_chat.CrispChatNotificationService"
 *     android:exported="false"&gt;
 *     &lt;intent-filter&gt;
 *         &lt;action android:name="com.google.firebase.MESSAGING_EVENT" /&gt;
 *     &lt;/intent-filter&gt;
 * &lt;/service&gt;
 * </pre>
 *
 * @see im.crisp.client.external.notification.CrispNotificationService
 */
public class CrispChatNotificationService extends FirebaseMessagingService {

    private static final String TAG = "CrispChatNotification";

    @Override
    public void onMessageReceived(@NonNull RemoteMessage message) {
        if (CrispNotificationClient.isCrispNotification(message)) {
            // Handle Crisp notification without auto-opening ChatActivity
            CrispNotificationClient.handleNotification(this, message, false);
        } else {
            // Non-Crisp notification - let other handlers process it
            super.onMessageReceived(message);
            Log.d(TAG, "Non-Crisp notification received.");
        }
    }

    @Override
    public void onNewToken(@NonNull String token) {
        super.onNewToken(token);
        // Forward the FCM token to Crisp for notification delivery
        CrispNotificationClient.sendTokenToCrisp(this, token);
    }
}
