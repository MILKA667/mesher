import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        // fontFamily: kFontGrotesk,  // enable after adding fonts to assets/fonts/
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          secondary: kAccent,
          surface: kCard,
          onPrimary: Color(0xFF001218),
          onSecondary: Color(0xFF001218),
          onSurface: kText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kText,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: kBg,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        iconTheme: const IconThemeData(color: kTextMuted),
        dividerColor: kLine,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textTheme: const TextTheme(
          headlineMedium: MeshTextStyles.headline,
          titleMedium: MeshTextStyles.title,
          bodyMedium: MeshTextStyles.body,
          labelSmall: MeshTextStyles.label,
        ),
      );

  static const systemUiOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: kBg,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
