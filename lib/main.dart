import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/design_system.dart';
import 'models/models.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/services.dart';

// ---------------------------------------------------------------------------
// App entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Mobile Ads initialisation ──────────────────────────────────────────
  await AdService.initialize();

  // ── Notification Service initialisation ─────────────────────────────────
  final notificationService = NotificationService();
  await notificationService.init();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ── Hive initialisation ────────────────────────────────────────────────
  await Hive.initFlutter();

  // Register Hive type adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(MoodEntryAdapter());

  // Open boxes before the app renders
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<MoodEntry>('mood_entries');
  await Hive.openBox('settings');

  // Initialise premium status from SharedPreferences
  final premiumService = PremiumService();
  await premiumService.checkPremiumStatus();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

  runApp(AscendApp(
    premiumService: premiumService,
    showOnboarding: !onboardingComplete,
  ));
}

// ---------------------------------------------------------------------------
// Root widget
// ---------------------------------------------------------------------------

class AscendApp extends StatelessWidget {
  final PremiumService premiumService;
  final bool showOnboarding;

  const AscendApp({
    super.key,
    required this.premiumService,
    this.showOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitService()),
        ChangeNotifierProvider(create: (_) => MoodService()),
        ChangeNotifierProvider.value(value: premiumService),
        ChangeNotifierProxyProvider<PremiumService, AdService>(
          create: (context) => AdService(premiumService: premiumService),
          update: (_, premium, adService) => adService ?? AdService(premiumService: premium),
        ),
        ChangeNotifierProvider(
          create: (context) => PurchaseService(premiumService: premiumService),
        ),
        Provider.value(value: NotificationService()),
      ],
      child: MaterialApp(
        title: 'Ascend',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: showOnboarding ? const OnboardingScreen() : const AppShell(),
      ),
    );
  }

  // ── Theme built from design system tokens ───────────────────────────────
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      // Colours
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm / 2,
        ),
      ),

      // Elevated buttons (primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.buttonLarge,
        ),
      ),

      // Outlined buttons (secondary CTA)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.navLabelActive,
        unselectedLabelStyle: AppTypography.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circleBorder,
        ),
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
