// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart'; //ignore: uri_does_not_exist

// ignore_for_file: undefined_class, undefined_identifier, non_type_as_type_argument

// Esta función debe ser una función de nivel superior, fuera de cualquier clase.
// Es el manejador para cuando se recibe un mensaje con la app en segundo plano.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // 1. Pide permiso al usuario
    await _fcm.requestPermission();

    // 2. Obtiene el token de FCM
    final fcmToken = await _fcm.getToken();
    print("📱 FCM Token: $fcmToken");
    // Aquí es donde deberías guardar el token en Firestore para el usuario actual.
    // Esta lógica ya la tienes en tu AuthService.

    // 3. Configura los manejadores de mensajes
    _initPushNotifications();
  }

  void _initPushNotifications() {
    // Manejador para cuando la app está terminada y se abre desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App opened from terminated state by notification: ${message.notification?.title}");
        // Aquí podrías navegar a una pantalla específica si el mensaje tiene datos
      }
    });

    // Manejador para cuando la app está en segundo plano y se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App opened from background state by notification: ${message.notification?.title}");
      // Aquí también podrías navegar a una pantalla específica
    });

    // Manejador para cuando se recibe una notificación CON LA APP EN PRIMER PLANO
    FirebaseMessaging.onMessage.listen((message) {
      print("Got a message whilst in the foreground!");
      print("Message data: ${message.data}");

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Aquí es donde MOSTRARÍAS la notificación manualmente
        // Por ejemplo, usando un paquete como 'flutter_local_notifications'
        // o un SnackBar/diálogo simple.
      }
    });

    // Manejador para cuando se recibe un mensaje con la app en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}