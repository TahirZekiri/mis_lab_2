import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'screens/categories_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/reminder_settings_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'services/auth_service.dart';
import 'services/favorites_service.dart';
import 'services/fcm_service.dart';
import 'services/meal_service.dart';
import 'services/notification_service.dart';
import 'services/reminder_settings_service.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
String? _pendingPayload;
bool _payloadCallbackScheduled = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final auth = AuthService();
  try {
    await auth.ensureSignedIn();
  } catch (_) {}

  final favorites = FavoritesService();
  await favorites.load();
  await favorites.connectToFirestore();

  final mealService = MealService();
  final notifications = NotificationService();
  final reminderSettings = ReminderSettingsService(notifications);
  await reminderSettings.load();

  Future<void> openFromPayloadNow(String payload) async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }

    if (payload == 'random') {
      try {
        final meal = await mealService.getRandomMeal();
        navigator.push(
          MaterialPageRoute(builder: (context) => RecipeDetailScreen(mealId: meal.idMeal)),
        );
      } catch (_) {}
      return;
    }

    if (payload.startsWith('meal:')) {
      final id = payload.substring('meal:'.length);
      if (id.isEmpty) return;
      navigator.push(
        MaterialPageRoute(builder: (context) => RecipeDetailScreen(mealId: id)),
      );
    }
  }

  Future<void> queuePayload(String payload) async {
    if (payload.isEmpty) return;
    _pendingPayload = payload;
    if (_payloadCallbackScheduled) return;
    _payloadCallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _payloadCallbackScheduled = false;
      final p = _pendingPayload;
      if (p == null || p.isEmpty) return;
      _pendingPayload = null;
      await openFromPayloadNow(p);
      if (_pendingPayload != null) {
        await queuePayload(_pendingPayload!);
      }
    });
  }

  await notifications.init(onPayload: queuePayload);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final fcm = FcmService(notifications);
  await fcm.init(onOpen: queuePayload);

  await reminderSettings.scheduleDaily();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: favorites),
        ChangeNotifierProvider.value(value: reminderSettings),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007AFF),
          onPrimary: Colors.white,
          secondary: Color(0xFF5856D6),
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F9),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const CategoriesScreen(),
      routes: {
        FavoritesScreen.routeName: (context) => const FavoritesScreen(),
        ReminderSettingsScreen.routeName: (context) => const ReminderSettingsScreen(),
      },
    );
  }
}
