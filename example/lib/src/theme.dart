import 'package:flutter/material.dart';

/// Colors taken from the crisp.chat marketing site, so the example feels
/// at home next to the Crisp chatbox it opens.
abstract final class CrispColors {
  /// Crisp's signature blue, used for primary actions.
  static const blue = Color(0xFF1972F5);
  static const blueDark = Color(0xFF0D66E9);
  static const blueTint = Color(0xFFE8F1FE);

  /// Deep navy of Crisp's dark hero sections and footer.
  static const navy = Color(0xFF030D26);
  static const navySurface = Color(0xFF0F1E35);
  static const navyCard = Color(0xFF242F47);

  /// Slate greys used for body text, captions, and borders.
  static const ink = Color(0xFF344055);
  static const slate = Color(0xFF5D6B98);
  static const slateLight = Color(0xFF7D89B0);
  static const border = Color(0xFFDCDFEA);
  static const borderSoft = Color(0xFFEAECF5);

  /// Light page backgrounds.
  static const canvas = Color(0xFFF8F8FC);
  static const white = Color(0xFFFCFCFD);

  /// Accent colors Crisp uses for feature illustrations.
  static const purple = Color(0xFF955CF4);
  static const orange = Color(0xFFFF6F3E);
  static const green = Color(0xFF12B76A);
  static const red = Color(0xFFF04438);
}

/// Extra colors the [ColorScheme] has no slot for.
@immutable
class CrispPalette extends ThemeExtension<CrispPalette> {
  const CrispPalette({
    required this.muted,
    required this.heroStart,
    required this.heroEnd,
    required this.success,
    required this.warning,
  });

  final Color muted;
  final Color heroStart;
  final Color heroEnd;
  final Color success;
  final Color warning;

  static const light = CrispPalette(
    muted: CrispColors.slate,
    heroStart: CrispColors.navy,
    heroEnd: Color(0xFF0B2A6B),
    success: CrispColors.green,
    warning: CrispColors.orange,
  );

  static const dark = CrispPalette(
    muted: CrispColors.slateLight,
    heroStart: Color(0xFF0B2A6B),
    heroEnd: CrispColors.blueDark,
    success: CrispColors.green,
    warning: CrispColors.orange,
  );

  @override
  CrispPalette copyWith({
    Color? muted,
    Color? heroStart,
    Color? heroEnd,
    Color? success,
    Color? warning,
  }) {
    return CrispPalette(
      muted: muted ?? this.muted,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  CrispPalette lerp(CrispPalette? other, double t) {
    if (other == null) return this;
    return CrispPalette(
      muted: Color.lerp(muted, other.muted, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension CrispThemeContext on BuildContext {
  CrispPalette get palette => Theme.of(this).extension<CrispPalette>()!;
}

abstract final class CrispTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: CrispColors.blue,
          onPrimary: Colors.white,
          primaryContainer: CrispColors.blueTint,
          onPrimaryContainer: CrispColors.blueDark,
          secondary: CrispColors.purple,
          onSecondary: Colors.white,
          secondaryContainer: CrispColors.blueTint,
          onSecondaryContainer: CrispColors.blueDark,
          tertiary: CrispColors.orange,
          onTertiary: Colors.white,
          error: CrispColors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: CrispColors.navy,
          onSurfaceVariant: CrispColors.slate,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: CrispColors.white,
          surfaceContainer: CrispColors.canvas,
          surfaceContainerHigh: CrispColors.borderSoft,
          surfaceContainerHighest: CrispColors.border,
          outline: CrispColors.border,
          outlineVariant: CrispColors.borderSoft,
        ),
        canvas: CrispColors.canvas,
        palette: CrispPalette.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF4A90FF),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF15305E),
          onPrimaryContainer: Color(0xFFCFE0FD),
          secondary: Color(0xFFB38BFA),
          onSecondary: CrispColors.navy,
          secondaryContainer: Color(0xFF15305E),
          onSecondaryContainer: Color(0xFFCFE0FD),
          tertiary: CrispColors.orange,
          onTertiary: CrispColors.navy,
          error: Color(0xFFFF7A70),
          onError: CrispColors.navy,
          surface: CrispColors.navySurface,
          onSurface: CrispColors.white,
          onSurfaceVariant: CrispColors.slateLight,
          surfaceContainerLowest: CrispColors.navy,
          surfaceContainerLow: CrispColors.navySurface,
          surfaceContainer: Color(0xFF16253F),
          surfaceContainerHigh: CrispColors.navyCard,
          surfaceContainerHighest: Color(0xFF344055),
          outline: Color(0xFF2C3A55),
          outlineVariant: Color(0xFF1F2C45),
        ),
        canvas: CrispColors.navy,
        palette: CrispPalette.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color canvas,
    required CrispPalette palette,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );
    // Material's letter spacing (up to 0.5) suits Roboto but looks loose
    // with San Francisco on Apple platforms. Crisp's own type is tight.
    final text = _tight(
      base.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
    final buttonText = text.labelLarge?.copyWith(fontWeight: FontWeight.w600);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      extensions: [palette],
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.4),
        bodySmall: text.bodySmall?.copyWith(
          color: palette.muted,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: shape,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outline),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outline),
          shape: shape,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CrispColors.navy,
        contentTextStyle: const TextStyle(color: CrispColors.white),
        shape: shape,
      ),
      listTileTheme: ListTileThemeData(
        shape: shape,
        iconColor: scheme.primary,
      ),
    );
  }

  static TextTheme _tight(TextTheme t) {
    TextStyle? z(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    return t.copyWith(
      displayLarge: z(t.displayLarge),
      displayMedium: z(t.displayMedium),
      displaySmall: z(t.displaySmall),
      headlineLarge: z(t.headlineLarge),
      headlineMedium: z(t.headlineMedium),
      headlineSmall: z(t.headlineSmall),
      titleLarge: z(t.titleLarge),
      titleMedium: z(t.titleMedium),
      titleSmall: z(t.titleSmall),
      bodyLarge: z(t.bodyLarge),
      bodyMedium: z(t.bodyMedium),
      bodySmall: z(t.bodySmall),
      labelLarge: z(t.labelLarge),
      labelMedium: z(t.labelMedium),
      labelSmall: z(t.labelSmall),
    );
  }
}
