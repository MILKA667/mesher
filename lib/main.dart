import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: kBg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MeshLinkApp());
}

class MeshLinkApp extends StatelessWidget {
  const MeshLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeshLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
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
        ),
        iconTheme: const IconThemeData(color: kTextMuted),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const MeshApp(),
    );
  }
}
