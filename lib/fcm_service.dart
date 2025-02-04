import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("DeviceTokens");

  FCMService() {
    // Listen for token refresh events
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveOrUpdateFCMToken(newToken);
    });
  }

  // Save or update the FCM token in Firebase
  Future<void> saveOrUpdateFCMToken() async {
    try {
      // Get the FCM token for this device
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        print("FCM Token: $token");
        await _saveOrUpdateFCMToken(token);
      } else {
        print("Failed to get FCM Token.");
      }
    } catch (e) {
      print("Error saving/updating FCM token: $e");
    }
  }

  // Helper method to save or update the FCM token in Firebase
  Future<void> _saveOrUpdateFCMToken(String token) async {
    try {
      // Check if the token already exists in the database
      final snapshot =
          await _database.orderByChild("token").equalTo(token).once();

      if (snapshot.snapshot.value == null) {
        // Token doesn't exist, save it
        String deviceId = "device_${DateTime.now().millisecondsSinceEpoch}";
        await _database.child(deviceId).set({
          "token": token,
          "timestamp": DateTime.now().toIso8601String(),
        });
        print("New token saved to Firebase Database!");
      } else {
        print("Token already exists in Firebase. No update required.");
      }
    } catch (e) {
      print("Error saving/updating FCM token: $e");
    }
  }
}
