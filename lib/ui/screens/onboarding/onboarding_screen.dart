import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../ui/providers/app_providers.dart';
import '../../widgets/mono_text.dart';
import '../../../app.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createIdentity() async {
    final name = _controller.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Минимум 2 символа');
      return;
    }

    setState(() { _saving = true; _error = null; });

    final storage = ref.read(secureStorageProvider);
    await storage.write('profile_nickname', name);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MeshApp()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kAccent.withValues(alpha: 0.35)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.hub_outlined, color: kAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'MeshLink',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: kText,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Создай аккаунт',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Твоё имя увидят люди рядом.\nСоединение без интернета, напрямую.',
                style: TextStyle(fontSize: 14, color: kTextDim, height: 1.5),
              ),
              const SizedBox(height: 36),
              Container(
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _error != null
                        ? kWarn.withValues(alpha: 0.6)
                        : kLine2,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Никнейм',
                    hintStyle: TextStyle(color: kTextMuted, fontSize: 16),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _createIdentity(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                MonoText(_error!, fontSize: 11, color: kWarn),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _saving ? null : _createIdentity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _saving
                          ? kAccent.withValues(alpha: 0.5)
                          : kAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF001218),
                            ),
                          )
                        : const Text(
                            'Создать аккаунт',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF001218),
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: const MonoText(
                  'END-TO-END ENCRYPTED · NO SERVERS',
                  fontSize: 9,
                  color: kTextMuted,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
