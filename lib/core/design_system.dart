import 'package:flutter/material.dart';

// =============================================================================
// ASCEND DESIGN SYSTEM
// Extracted from 5 Visily UI screens:
//   • Home, Add Habit, Habit Detail, Mood Check-in, Stats
// =============================================================================

// -----------------------------------------------------------------------------
// COLORS
// -----------------------------------------------------------------------------

class AppColors {
  AppColors._();

  // ── Brand / Primary ──────────────────────────────────────────────────────
  /// Main brand purple-blue used for buttons, active states, icons, FAB,
  /// navigation highlights, chart bars, calendar dots.
  static const Color primary = Color(0xFF5B5FEF);

  /// Lighter tint used for selected mood tiles, streak circles, toggle chips.
  static const Color primaryLight = Color(0xFF8B8EF5);

  /// Very light tint used for card highlights, progress-card background,
  /// selected-mood tile background, habit-detail header card.
  static const Color primarySurface = Color(0xFFEEEFFC);

  /// Darker shade for pressed / active states.
  static const Color primaryDark = Color(0xFF4A4EDC);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Scaffold / page background (light grey).
  static const Color background = Color(0xFFF9FAFB);

  /// Card & surface background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Bottom navigation bar background.
  static const Color navBar = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Primary heading text – "Hello, Alex!", "Statistics", "Progress Report".
  static const Color textPrimary = Color(0xFF1A1D26);

  /// Secondary / body text – descriptions, subtitles, timestamps.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary / muted labels – category tags, placeholders.
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// Text shown on primary-colored surfaces (buttons, chips).
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Completed / success checkmark, "Completed" badges.
  static const Color success = Color(0xFF22C55E);

  /// Missed calendar days, error indicators.
  static const Color error = Color(0xFFEF4444);

  /// Coral / salmon used for missed-day dots and color-identity option.
  static const Color coral = Color(0xFFEF7B7B);

  /// Warning / attention accents.
  static const Color warning = Color(0xFFF59E0B);

  // ── Habit Color Identity Options ─────────────────────────────────────────
  /// Selectable colors shown in "Add Habit → Color Identity" palette.
  static const Color habitIndigo = Color(0xFF5B5FEF);
  static const Color habitBlue = Color(0xFF6E8AFA);
  static const Color habitCoral = Color(0xFFEF7B7B);
  static const Color habitLavender = Color(0xFFC4B5FD);
  static const Color habitMint = Color(0xFF86EFAC);

  // ── Borders & Dividers ───────────────────────────────────────────────────
  /// Subtle card border / separator lines.
  static const Color border = Color(0xFFE5E7EB);

  /// Divider between sections (slightly lighter).
  static const Color divider = Color(0xFFF3F4F6);

  // ── Miscellaneous ────────────────────────────────────────────────────────
  /// Unchecked circle / empty checkbox ring.
  static const Color unchecked = Color(0xFFD1D5DB);

  /// Inactive streak day / unselected chip background.
  static const Color chipInactive = Color(0xFFF3F4F6);

  /// Streak day text when inactive.
  static const Color chipInactiveText = Color(0xFF9CA3AF);

  /// Progress bar track (unfilled portion).
  static const Color progressTrack = Color(0xFFE0E1F6);

  /// Bar chart background track.
  static const Color chartTrack = Color(0xFFEEEFFC);

  /// Insight card subtle tinted backgrounds.
  static const Color insightBlueBg = Color(0xFFEEEFFC);
  static const Color insightPeachBg = Color(0xFFFEF0EC);
  static const Color insightGreenBg = Color(0xFFECFDF5);

  /// History Log banner gradient start & end.
  static const Color bannerStart = Color(0xFF5B5FEF);
  static const Color bannerEnd = Color(0xFF8B8EF5);
}

// -----------------------------------------------------------------------------
// TYPOGRAPHY
// -----------------------------------------------------------------------------

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Inter';

  // ── Display / Hero ───────────────────────────────────────────────────────
  /// "40%" large percentage on Home daily-progress card.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.primary,
  );

  // ── Headlines ────────────────────────────────────────────────────────────
  /// "Hello, Alex! 👋", "Progress Report" – main page headings.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// "Daily Progress", "How are you, Alex?", "Statistics".
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// "History", "Insights", "Completion Rate", section sub-heads.
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  // ── Titles ───────────────────────────────────────────────────────────────
  /// Habit name in list – "Morning Meditation", "Read 20 Pages".
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Bottom-sheet titles, smaller section labels.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  /// Primary body text – card descriptions, motivational quote.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Secondary body – "You've finished 2 of 5 habits", insight subtexts.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Tertiary body – timestamps "07:30 AM", "Achieved in August".
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  // ── Labels & Captions ────────────────────────────────────────────────────
  /// Category tags "MINDFULNESS • 10M", "ACTIVE HABITS", "DAILY INSIGHTS".
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
  );

  /// Small caps – "DAY STREAK", "BEST STREAK", day-of-week headers.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.6,
    color: AppColors.textTertiary,
  );

  /// Tiny labels – calendar dates, streak-day numbers.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textTertiary,
  );

  // ── Buttons ──────────────────────────────────────────────────────────────
  /// Primary button text – "Create Habit →", "Mark for Today", "Log Check-in".
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textOnPrimary,
  );

  /// Secondary / outline button – "Cancel", "Skip for now", "Edit List".
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.primary,
  );

  /// Chip / tag text – "Mon", "Weekly", "Filter".
  static const TextStyle chip = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textOnPrimary,
  );

  // ── Stats / Metrics ──────────────────────────────────────────────────────
  /// Big stat numbers – "12 days", "88%", "4.2", "142".
  static const TextStyle statLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Smaller stat numbers – "+12%", "+4% from last month".
  static const TextStyle statSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.success,
  );

  // ── Navigation ───────────────────────────────────────────────────────────
  /// Bottom nav label – "Home", "Stats", "Mood".
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textTertiary,
  );

  /// Active nav label.
  static const TextStyle navLabelActive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.primary,
  );

  // ── Badges ───────────────────────────────────────────────────────────────
  /// Status badges – "Completed", "Skipped".
  static const TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textOnPrimary,
  );
}

// -----------------------------------------------------------------------------
// SPACING
// -----------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  /// 4px – micro spacing (icon–text inline gap).
  static const double xs = 4;

  /// 8px – tight spacing (between tag elements, inner card padding).
  static const double sm = 8;

  /// 12px – compact spacing (list-item internal gaps).
  static const double md = 12;

  /// 16px – standard spacing (page horizontal padding, card padding,
  /// gap between list items, section spacing).
  static const double lg = 16;

  /// 20px – relaxed spacing (between major sections).
  static const double xl = 20;

  /// 24px – generous spacing (top/bottom page padding, large section gaps).
  static const double xxl = 24;

  /// 32px – extra-large (hero section spacing, card-to-section gaps).
  static const double xxxl = 32;

  /// 48px – page-level vertical gutters.
  static const double huge = 48;

  // ── Semantic aliases ─────────────────────────────────────────────────────
  /// Horizontal padding for all page content.
  static const double pageHorizontal = 16;

  /// Vertical padding at top of scrollable pages.
  static const double pageTop = 16;

  /// Internal padding within cards.
  static const double cardPadding = 16;

  /// Gap between stacked cards / list items.
  static const double cardGap = 12;

  /// Space between section header and its content.
  static const double sectionGap = 16;

  /// Bottom nav bar height.
  static const double navBarHeight = 64;

  /// FAB inset from bottom-right.
  static const double fabInset = 24;
}

// -----------------------------------------------------------------------------
// BORDER RADIUS
// -----------------------------------------------------------------------------

class AppRadius {
  AppRadius._();

  /// 4px – tiny radius (badges, inline tags).
  static const double xs = 4;

  /// 8px – small radius (input fields, chips, inner elements).
  static const double sm = 8;

  /// 12px – standard card radius (habit cards, insight cards, calendar cards).
  static const double md = 12;

  /// 16px – larger card radius (progress card, mood selection card,
  /// daily-progress card, stat cards).
  static const double lg = 16;

  /// 24px – pill radius for buttons ("Create Habit", "Mark for Today",
  /// "Log Check-in"), day chips, toggle pills.
  static const double xl = 24;

  /// 100px – full circle (FAB, avatar, streak dots, calendar day circles,
  /// checkboxes, mood emoji circles).
  static const double full = 100;

  // ── Semantic aliases ─────────────────────────────────────────────────────
  static const double card = 12;
  static const double cardLarge = 16;
  static const double button = 24;
  static const double chip = 24;
  static const double input = 8;
  static const double badge = 4;
  static const double circle = 100;

  // ── BorderRadius objects (convenience) ───────────────────────────────────
  static final BorderRadius cardBorder = BorderRadius.circular(card);
  static final BorderRadius cardLargeBorder = BorderRadius.circular(cardLarge);
  static final BorderRadius buttonBorder = BorderRadius.circular(button);
  static final BorderRadius chipBorder = BorderRadius.circular(chip);
  static final BorderRadius inputBorder = BorderRadius.circular(input);
  static final BorderRadius badgeBorder = BorderRadius.circular(badge);
  static final BorderRadius circleBorder = BorderRadius.circular(circle);
}

// -----------------------------------------------------------------------------
// SHADOWS
// -----------------------------------------------------------------------------

class AppShadows {
  AppShadows._();

  /// Subtle card shadow – habit cards, insight cards, activity log rows.
  /// Very soft, barely visible – matches Visily's clean, minimal aesthetic.
  static const List<BoxShadow> cardSm = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Standard card shadow – progress card, mood-selection tile, stat cards.
  static const List<BoxShadow> cardMd = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Elevated shadow – FAB, bottom sheet, sticky nav bar.
  static const List<BoxShadow> cardLg = [
    BoxShadow(
      color: Color(0x14000000), // ~8% opacity
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Bottom navigation bar shadow (upward soft shadow).
  static const List<BoxShadow> navBar = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  /// Selected / active state shadow with primary color glow
  /// (e.g. selected mood tile, color identity option).
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x335B5FEF), // primary at ~20% opacity
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// No shadow – flat elements.
  static const List<BoxShadow> none = [];
}

// -----------------------------------------------------------------------------
// COMPONENT TOKENS (optional higher-level presets)
// -----------------------------------------------------------------------------

class AppComponents {
  AppComponents._();

  // ── Buttons ──────────────────────────────────────────────────────────────
  /// Height of primary action buttons ("Create Habit →", "Log Check-in").
  static const double buttonHeight = 52;

  /// Height of secondary / outline buttons ("Cancel", "Skip for now").
  static const double buttonHeightSmall = 44;

  // ── Cards ────────────────────────────────────────────────────────────────
  /// Min height of habit list cards.
  static const double habitCardMinHeight = 72;

  /// Height of the daily-progress card on Home.
  static const double progressCardHeight = 100;

  // ── Icons ────────────────────────────────────────────────────────────────
  /// Standard icon size in cards / list items.
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;

  /// Circular icon container size (habit streak counter, mood emoji).
  static const double iconContainerSm = 40;
  static const double iconContainerMd = 48;
  static const double iconContainerLg = 56;

  // ── Checkbox / Toggle ────────────────────────────────────────────────────
  /// Circular checkbox size on habit cards.
  static const double checkboxSize = 28;

  // ── Calendar ─────────────────────────────────────────────────────────────
  /// Calendar day circle diameter.
  static const double calendarDaySize = 36;

  // ── Weekly Streak ────────────────────────────────────────────────────────
  /// Streak day circle diameter on Home.
  static const double streakDaySize = 32;

  // ── Progress Bar ─────────────────────────────────────────────────────────
  /// Height of the linear progress bar.
  static const double progressBarHeight = 8;

  // ── Bottom Navigation ────────────────────────────────────────────────────
  /// Bottom nav icon size.
  static const double navIconSize = 24;

  // ── FAB ──────────────────────────────────────────────────────────────────
  /// Floating action button diameter.
  static const double fabSize = 56;

  // ── Mood Grid ────────────────────────────────────────────────────────────
  /// Mood option tile size (Mood Check-in grid).
  static const double moodTileSize = 88;

  // ── Insight Cards ────────────────────────────────────────────────────────
  /// Insight stat card min height (Stats screen).
  static const double insightCardMinHeight = 120;

  // ── Dividers ─────────────────────────────────────────────────────────────
  /// Horizontal divider thickness.
  static const double dividerThickness = 1;

  // ── Bar Chart ────────────────────────────────────────────────────────────
  /// Width of individual chart bars (Stats screen).
  static const double chartBarWidth = 28;
}
