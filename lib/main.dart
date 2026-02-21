import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Initialise settings
  final settingsService = SettingsService();
  await settingsService.init();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

  runApp(AscendApp(
    premiumService: premiumService,
    settingsService: settingsService,
    showOnboarding: !onboardingComplete,
  ));
}

// ---------------------------------------------------------------------------
// Root widget
// ---------------------------------------------------------------------------

class AscendApp extends StatelessWidget {
  final PremiumService premiumService;
  final SettingsService settingsService;
  final bool showOnboarding;

  const AscendApp({
    super.key,
    required this.premiumService,
    required this.settingsService,
    this.showOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitService()),
        ChangeNotifierProvider(create: (_) => MoodService()),
        ChangeNotifierProvider.value(value: premiumService),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProxyProvider<PremiumService, AdService>(
          create: (context) => AdService(premiumService: premiumService),
          update: (_, premium, adService) => adService ?? AdService(premiumService: premium),
        ),
        ChangeNotifierProvider(
          create: (context) => PurchaseService(premiumService: premiumService),
        ),
        Provider.value(value: NotificationService()),
        ChangeNotifierProxyProvider2<HabitService, MoodService, StatsService>(
          create: (context) => StatsService(
            habitService: context.read<HabitService>(),
            moodService: context.read<MoodService>(),
          ),
          update: (context, habit, mood, stats) => 
            stats ?? StatsService(habitService: habit, moodService: mood),
        ),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Ascend',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(isDark: false),
            darkTheme: _buildTheme(isDark: true),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: showOnboarding ? const OnboardingScreen() : const AppShell(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({required bool isDark}) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      // Colours
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: isDark ? const Color(0xFF1F2937) : AppColors.surface,
        error: AppColors.error,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF111827) : AppColors.background,

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF111827) : AppColors.background,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      
      dividerColor: isDark ? Colors.white10 : AppColors.divider,

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1F2937) : AppColors.surface,
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
          foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          side: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
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
        fillColor: isDark ? const Color(0xFF374151) : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: BorderSide(color: isDark ? Colors.white10 : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBorder,
          borderSide: BorderSide(color: isDark ? Colors.white10 : AppColors.border),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1F2937) : AppColors.navBar,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.navLabelActive,
        unselectedLabelStyle: AppTypography.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white10 : AppColors.divider,
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
