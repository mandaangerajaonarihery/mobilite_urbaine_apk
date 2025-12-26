import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:all_pnud/screens/onboarding_screen.dart';
import 'package:all_pnud/providers/notification_provider.dart';
import 'package:all_pnud/providers/auth_provider.dart';
import 'package:all_pnud/providers/theme_provider.dart';
import 'package:all_pnud/providers/locale_provider.dart';
import 'package:all_pnud/router/app_router.dart';
import 'package:all_pnud/theme/app_theme.dart';
import 'package:all_pnud/l10n/app_localizations.dart';

// 🔑 Clé globale pour ScaffoldMessenger (SnackBars)
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyAppStarter());
}

class MyAppStarter extends StatelessWidget {
  const MyAppStarter({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider(const Locale('en'))),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  bool _showOnboarding = true; // affiche onboarding au lancement

  @override
  void initState() {
    super.initState();

    // GoRouter configuré normalement, sans navigatorKey
    _router = AppRouter.getRouter(
      themeProvider: ThemeProvider(),
      localeProvider: LocaleProvider(const Locale('en')),
    );
  }

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        if (_showOnboarding) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Portail PNUD',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: OnboardingPage(
              onFinished: _finishOnboarding,
            ),
          );
        }

        // Après onboarding, app principale avec GoRouter
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          scaffoldMessengerKey: rootScaffoldMessengerKey, // ✅ notifications
          title: 'Portail PNUD',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeAnimationDuration: Duration.zero,
          themeAnimationCurve: Curves.linear,
        );
      },
    );
  }
}
