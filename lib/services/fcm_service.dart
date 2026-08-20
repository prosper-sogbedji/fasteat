import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../data/api/api_config.dart';
import '../data/api/auth_service.dart';

/// Handler de fond (doit être une fonction top-level, pas une méthode de classe)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM Background] ${message.notification?.title} — ${message.notification?.body}');
}

/// Service centralisé pour Firebase Cloud Messaging.
///
/// À appeler une seule fois depuis [main.dart] après [Firebase.initializeApp()].
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  static const _channelId = 'fasteat_orders';
  static const _channelName = 'Commandes FastEat';
  static const _channelDesc = 'Notifications de statut de commandes FastEat';

  /// Initialise FCM, les canaux locaux et enregistre les handlers.
  Future<void> init() async {
    // 1. Enregistrer le handler de fond
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Demander la permission (Android 13+ et iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // 3. Configurer le canal de notification local (Android)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 4. Initialiser flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotif.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onLocalNotifTapped,
    );

    // 5. Forcer les notifications foreground sur Android
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 6. Handler foreground : afficher notification locale
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 7. Handler tap depuis background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 8. Vérifier si l'app a été ouverte depuis une notification (app terminée)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] App lancée depuis notification: ${initial.data}');
    }

    // 9. Enregistrer le token FCM sur le serveur
    await _registerToken();

    // Écouter les rafraîchissements de token
    _messaging.onTokenRefresh.listen((newToken) => _sendTokenToServer(newToken));
  }

  /// Affiche une notification locale quand l'app est en foreground.
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    debugPrint('[FCM Foreground] ${notif.title} — ${notif.body}');

    await _localNotif.show(
      id: notif.hashCode,
      title: notif.title,
      body: notif.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Appelé quand l'utilisateur tape sur une notification (app en arrière-plan).
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM Tap background] ${message.data}');
    // La navigation sera gérée dans app.dart via getInitialMessage / onMessageOpenedApp
  }

  /// Appelé quand l'utilisateur tape sur une notification locale (foreground).
  void _onLocalNotifTapped(NotificationResponse response) {
    debugPrint('[FCM Local Notif Tap] payload: ${response.payload}');
  }

  /// Récupère le token FCM et l'envoie au backend.
  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      debugPrint('[FCM Token] $token');
      await _sendTokenToServer(token);
    } catch (e) {
      debugPrint('[FCM] Erreur token: $e');
    }
  }

  /// Envoie le token FCM au backend FastEat Render.
  Future<void> _sendTokenToServer(String token) async {
    try {
      final auth = AuthService();
      final savedToken = await auth.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        // Pas encore connecté — on réessaiera au login
        debugPrint('[FCM] Pas de session, token non envoyé au serveur pour l\'instant.');
        return;
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $savedToken',
            },
            body: jsonEncode({'fcmToken': token}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FCM] Token enregistré sur le serveur ✓');
      } else {
        debugPrint('[FCM] Serveur a répondu ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[FCM] Impossible d\'envoyer le token: $e');
    }
  }

  /// Retourne le token FCM actuel (utile pour le debug).
  Future<String?> getToken() => _messaging.getToken();
}
