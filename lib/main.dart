import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'ui/providers/app_providers.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlay);
  runApp(const ProviderScope(child: MeshLinkApp()));
}

class MeshLinkApp extends ConsumerStatefulWidget {
  const MeshLinkApp({super.key});

  @override
  ConsumerState<MeshLinkApp> createState() => _MeshLinkAppState();
}

class _MeshLinkAppState extends ConsumerState<MeshLinkApp> {
  // null = still checking, false = onboarding needed, true = go to main app
  bool? _identityReady;

  @override
  void initState() {
    super.initState();
    _checkIdentity();
  }

  Future<void> _checkIdentity() async {
    final storage = ref.read(secureStorageProvider);
    final nick = await storage.read('profile_nickname');
    if (mounted) {
      setState(() => _identityReady = nick != null && nick.trim().isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeshLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: switch (_identityReady) {
        null => const _SplashScreen(),
        true => const MeshApp(),
        false => const OnboardingScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000E14),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Color(0xFF00D8FF),
          ),
        ),
      ),
    );
  }
}
