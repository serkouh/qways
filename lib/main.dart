import 'package:qways/listgames.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/creategame.dart';
import 'package:qways/pages/home/journey.dart';
import 'package:qways/pages/profile/app_settings.dart';

import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'localization/localization.dart';
import 'pages/screens.dart';
import 'package:qways/pages/scan/scanner.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:qways/services/quiz_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<void> _initDeepLinkListener() async {
    _appLinks = AppLinks();

    // 1. Handle Initial Link (App started via link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleLink(initialUri);
      }
    } catch (e) {
      print("Deep Link Init Error: $e");
    }

    // 2. Handle Stream (Background/Foreground)
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
         _handleLink(uri);
      }
    }, onError: (err) {
      print("Deep Link Stream Error: $err");
    });
  }

  void _handleLink(Uri uri) {
    print("🔗 Received Deep Link: $uri");
    
    // Check for room param in qways://join?room=... or https://qways.app/join?room=...
    String? roomUuid = uri.queryParameters['room'];
    
    if (roomUuid != null && roomUuid.isNotEmpty) {
       _joinAndNavigate(roomUuid);
    }
  }

  Future<void> _joinAndNavigate(String roomUuid) async {
    print("🚀 Auto-joining Room: $roomUuid");
    
    // Wait for context/navigation to be ready if app just started
    await Future.delayed(const Duration(seconds: 1));

    try {
      final res = await QuizService.joinRoom(roomUuid);
      // Whether success or already joined (error: false usually), nav to room
      
      // If error (e.g. invalid room), show snippet
      if (res['error'] == true && 
          !res['message'].toString().toLowerCase().contains("already")) {
           print("❌ Join Failed: ${res['message']}");
           return;
      }
      
      // Navigate
      navigatorKey.currentState?.pushNamed(
        '/joinGame',
        arguments: {"room_uuid": roomUuid},
      );
    } catch (e) {
      print("Deep Link Join Error: $e");
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: whiteColor,
        fontFamily: "Mulish",
      ),
      home: const SplashScreen(),
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('id'),
        Locale('zh'),
        Locale('ar'),
      ],
      localizationsDelegates: [
        Localization.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocale) {
        for (var locale in supportedLocale) {
          if (locale.languageCode != deviceLocale?.languageCode) {
            return deviceLocale;
          }
        }
        return supportedLocale.first;
      },
      onGenerateRoute: routes,
    );
  }

  Route<dynamic>? routes(settings) {
    switch (settings.name) {
      case '/':
        return PageTransition(
          child: const SplashScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/onboarding':
        return PageTransition(
          child: const OnboardingScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/joinGame':
        return PageTransition(
          child: GeoQuizJourney(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/CreateGame':
        return PageTransition(
          child: CreateGeoQuizPage(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/GamesListScreen':
        return PageTransition(
          child: GamesListScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/login':
        return PageTransition(
          child: const LoginScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/register':
        return PageTransition(
          child: const RegisterScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/otp':
        return PageTransition(
          child: const OTPScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/bottombar':
        return PageTransition(
          child: const BottomNavigationScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/home':
        return PageTransition(
          child: const QuizDashboard(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/search':
        return PageTransition(
          child: const SearchScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/searchResult':
        return PageTransition(
          child: const SearchResultScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/direction':
        return PageTransition(
          child: const DirectionScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/detail':
        return PageTransition(
          child: const DetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/scan':
        return PageTransition(
          child: const ScanScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/qrScanner':
        return PageTransition(
          child: const QRScannerScreen(), // From scanner.dart
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/securityDeposit':
        return PageTransition(
          child: const SecurityDeposit(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/creditcard':
        return PageTransition(
          child: const CreditCardScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/success':
        return PageTransition(
          child: const SuccessScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/startRide':
        return PageTransition(
          child: const StartRideScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/endRide':
        return PageTransition(
          child: const EndRideScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/confirm':
        return PageTransition(
          child: const ConfirmScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/wallet':
        return PageTransition(
          child: RoomsListScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/addmoney':
        return PageTransition(
          child: const AddMoneyScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/walletSuccess':
        return PageTransition(
          child: const WalletSuccessScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/receipt':
        return PageTransition(
          child: const ReceiptScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/notification':
        return PageTransition(
          child: const NotificationScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/profile':
        return PageTransition(
          child: const ProfileScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/editProfile':
        return PageTransition(
          child: const EditProfileScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/ridehistory':
        return PageTransition(
          child: const QuizHistoryScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/referAndEarn':
        return PageTransition(
          child: const ReferAndEarnScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/language':
        return PageTransition(
          child: const LanguageScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/appSettings':
        return PageTransition(
          child: const AppSettingScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/FAQs':
        return PageTransition(
          child: const FAQsScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/termsAndCondition':
        return PageTransition(
          child: const TermsAndConditionScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/privacyPolicy':
        return PageTransition(
          child: const PrivacyPolicyScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/help':
        return PageTransition(
          child: const HelpScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      default:
        return null;
    }
  }
}
