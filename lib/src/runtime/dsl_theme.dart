// lib/src/runtime/dsl_theme.dart

import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

/// DSL 主题配置
///
/// 提供 DSL 专用的主题扩展和配置
class DSLTheme {
  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// 自定义主题
  static ThemeData customTheme({
    required Color seedColor,
    Brightness brightness = Brightness.light,
    TextStyle? headlineStyle,
    TextStyle? bodyStyle,
    bool useMaterial3 = true,
    double cardElevation = 2,
    double buttonElevation = 0,
    double borderRadius = 8,
  }) {
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      textTheme: TextTheme(
        displayLarge: headlineStyle?.copyWith(fontSize: 57),
        displayMedium: headlineStyle?.copyWith(fontSize: 45),
        displaySmall: headlineStyle?.copyWith(fontSize: 36),
        headlineLarge: headlineStyle?.copyWith(fontSize: 32),
        headlineMedium: headlineStyle?.copyWith(fontSize: 28),
        headlineSmall: headlineStyle?.copyWith(fontSize: 24),
        titleLarge: headlineStyle?.copyWith(fontSize: 22),
        titleMedium: bodyStyle?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: bodyStyle?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: bodyStyle?.copyWith(fontSize: 16),
        bodyMedium: bodyStyle?.copyWith(fontSize: 14),
        bodySmall: bodyStyle?.copyWith(fontSize: 12),
        labelLarge: bodyStyle?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: bodyStyle?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: bodyStyle?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFFF5F5F5)
            : const Color(0xFF1E1E1E),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// 获取 DSL 主题扩展
  static DSLThemeExtension? of(BuildContext context) {
    return Theme.of(context).extension<DSLThemeExtension>();
  }
}

/// DSL 主题扩展
class DSLThemeExtension extends ThemeExtension<DSLThemeExtension> {
  final Color? primaryGradientStart;
  final Color? primaryGradientEnd;
  final double? defaultPadding;
  final double? defaultRadius;
  final Duration? animationDuration;

  const DSLThemeExtension({
    this.primaryGradientStart,
    this.primaryGradientEnd,
    this.defaultPadding,
    this.defaultRadius,
    this.animationDuration,
  });

  @override
  DSLThemeExtension copyWith({
    Color? primaryGradientStart,
    Color? primaryGradientEnd,
    double? defaultPadding,
    double? defaultRadius,
    Duration? animationDuration,
  }) {
    return DSLThemeExtension(
      primaryGradientStart: primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      defaultRadius: defaultRadius ?? this.defaultRadius,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  @override
  DSLThemeExtension lerp(ThemeExtension<DSLThemeExtension>? other, double t) {
    if (other is! DSLThemeExtension) return this;
    return DSLThemeExtension(
      primaryGradientStart: Color.lerp(
        primaryGradientStart,
        other.primaryGradientStart,
        t,
      ),
      primaryGradientEnd: Color.lerp(
        primaryGradientEnd,
        other.primaryGradientEnd,
        t,
      ),
      defaultPadding: lerpDouble(defaultPadding, other.defaultPadding, t),
      defaultRadius: lerpDouble(defaultRadius, other.defaultRadius, t),
      animationDuration: Duration(
        milliseconds:
            lerpDouble(
              animationDuration?.inMilliseconds ?? 200,
              other.animationDuration?.inMilliseconds ?? 200,
              t,
            )?.round() ??
            200,
      ),
    );
  }
}

/// DSL 主题扩展助手
extension DSLThemeHelper on BuildContext {
  /// 获取 DSL 主题扩展
  DSLThemeExtension? get dslTheme => DSLTheme.of(this);

  /// 获取默认间距
  double get defaultPadding => dslTheme?.defaultPadding ?? 16.0;

  /// 获取默认圆角
  double get defaultRadius => dslTheme?.defaultRadius ?? 8.0;

  /// 获取动画时长
  Duration get animationDuration =>
      dslTheme?.animationDuration ?? const Duration(milliseconds: 200);
}

/// DSL 主题构建器
class DSLThemeBuilder extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;
  final bool useMaterial3;
  final Color? seedColor;
  final Brightness? brightness;
  final DSLThemeExtension? extension;

  const DSLThemeBuilder({
    super.key,
    required this.child,
    this.theme,
    this.useMaterial3 = true,
    this.seedColor,
    this.brightness,
    this.extension,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme =
        theme ??
        ThemeData(
          useMaterial3: useMaterial3,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor ?? Colors.blue,
            brightness: brightness ?? Brightness.light,
          ),
        );

    final extendedTheme = baseTheme.copyWith(
      extensions: [
        if (extension != null) extension!,
        DSLThemeExtension(
          primaryGradientStart: Colors.blue.shade300,
          primaryGradientEnd: Colors.blue.shade700,
          defaultPadding: 16,
          defaultRadius: 8,
          animationDuration: const Duration(milliseconds: 200),
        ),
      ],
    );

    return Theme(data: extendedTheme, child: child);
  }
}
