import 'package:appointment_app/config/theme/app_theme.dart';
import 'package:appointment_app/infrastructure/routes.dart';
import 'package:appointment_app/infrastructure/shared_preferences.dart';
import 'package:appointment_app/presentation/providers/form/provider_form.dart';
import 'package:appointment_app/presentation/providers/form/provider_image_input.dart';
import 'package:appointment_app/presentation/providers/provider_map.dart';
import 'package:appointment_app/presentation/providers/provider_theme.dart';
import 'package:appointment_app/presentation/screens/home/home_screen.dart';
import 'package:appointment_app/presentation/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// * Config Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// * End

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.configPrefs();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) { 
    _showNotification(message);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (_) => ProviderTheme() ),
        ChangeNotifierProvider( create: (_) => ProviderFont() ),
      ],
      child: const MyApp()
    )
  );  
}

FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void _showNotification(RemoteMessage message) async{
  var androidInitialization = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: androidInitialization);
  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (payload){}
  );
  const String channelID = 'high_importance_channel';
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    channelID, 
    'High Importance Notifications',
    importance: Importance.max
  );
  AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(    
    channelID, 
    'High Importance Notifications',
    channelDescription: 'Channel description',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker'
  );
  NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
  await _flutterLocalNotificationsPlugin.show(
    0, 
    message.notification?.title ?? 'Notificacion', 
    message.notification?.body ?? 'Cuerpo del Mensaje', 
    notificationDetails
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final changeTheme = context.watch<ProviderTheme>();
    final changeFont = context.watch<ProviderFont>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider( create: (_) => ProviderDropdown() ),
        ChangeNotifierProvider( create: (_) => ProviderInputTime() ),
        ChangeNotifierProvider( create: (_) => ProviderImageInput() ),
        ChangeNotifierProvider( create: (_) => ProviderMap() ),
        ChangeNotifierProvider( create: (_) => ProviderControllerMap() ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: getRoutes(),
        title: 'AppointmentApp',
        theme: AppTheme(
          selectedColor: Preferences.prefsThemeColor.getInt('color') ?? changeTheme.colorValue, 
          fontFamily: Preferences.prefsThemeFont.getString('font') ?? changeFont.fontValue )
          .theme( Brightness.light
        ),
        themeMode: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
        home: Preferences.prefsSession.getBool('session') ?? false
          ? const HomeScreen()
          : const LoginScreen(), 
      ),
    );
  }
}