import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:novopharma/generated/l10n/app_localizations.dart';

import 'package:novopharma/controllers/badge_provider.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/controllers/goal_provider.dart';
import 'package:novopharma/controllers/quiz_provider.dart';
import 'package:novopharma/controllers/rewards_controller.dart';
import 'package:novopharma/controllers/redeemed_rewards_provider.dart';
import 'package:novopharma/controllers/pluxee_redemption_provider.dart';
import 'package:novopharma/controllers/leaderboard_provider.dart';
import 'package:novopharma/controllers/sales_history_provider.dart';
import 'package:novopharma/controllers/scan_provider.dart';
import 'package:novopharma/controllers/locale_provider.dart';
import 'package:novopharma/controllers/formation_provider.dart';
import 'package:novopharma/controllers/actualite_provider.dart';
import 'package:novopharma/controllers/notification_provider.dart';
import 'package:novopharma/services/notification_service.dart';
import 'package:novopharma/firebase_options.dart';
import 'package:novopharma/navigation.dart';
import 'package:novopharma/navigation_observer.dart';
import 'package:novopharma/screens/auth_wrapper.dart';
import 'package:novopharma/theme.dart';
import 'package:novopharma/screens/dashboard_home_screen.dart';
import 'package:novopharma/screens/leaderboard_screen.dart';
import 'package:novopharma/screens/profile_screen.dart';
import 'package:novopharma/screens/goals_screen.dart';
import 'package:novopharma/screens/barcode_scanner_screen.dart';
import 'package:novopharma/screens/login_screen.dart';
import 'package:novopharma/screens/pluxee_redemption_screen.dart';
import 'package:novopharma/screens/formation_details_screen.dart';
import 'package:novopharma/models/blog_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (context) =>
              GoalProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => previous!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BadgeProvider>(
          create: (context) =>
              BadgeProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => previous!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RedeemedRewardsProvider>(
          create: (context) => RedeemedRewardsProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => previous!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PluxeeRedemptionProvider>(
          create: (context) => PluxeeRedemptionProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => previous!..update(auth),
        ),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => SalesHistoryProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => RewardsController()),
        ChangeNotifierProvider(create: (_) => FormationProvider()),
        ChangeNotifierProvider(create: (_) => ActualiteProvider()),
      ],
      child: const NovoPharmaApp(),
    ),
  );
}

class NovoPharmaApp extends StatelessWidget {
  const NovoPharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'NovoPharma Rewards',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      home: const AuthWrapper(),
      navigatorObservers: [routeObserver],
      onGenerateRoute: (settings) {
        // Handle dynamic routes for formations from notifications
        if (settings.name?.startsWith('/formation/') == true) {
          final formationId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('blogPosts')
                  .doc(formationId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Erreur')),
                    body: const Center(child: Text('Formation introuvable')),
                  );
                }
                final formation = BlogPost.fromFirestore(snapshot.data!);
                return FormationDetailsScreen(formation: formation);
              },
            ),
          );
        }
        return null;
      },
      routes: {
        '/dashboard_home': (context) => const DashboardHomeScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/goals': (context) => const GoalsScreen(),
        '/scanner': (context) => const BarcodeScannerScreen(),
        '/login': (context) => const LoginScreen(),
        '/rewards': (context) => const PluxeeRedemptionScreen(),
      },
    );
  }
}
