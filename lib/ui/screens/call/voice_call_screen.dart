import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../services/voice_call_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/avatar.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({
    super.key,
    required this.peerId,
    this.peerName,
    this.isIncoming = false,
  });

  final String peerId;
  final String? peerName;
  final bool isIncoming;

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  VoiceCallState _state = VoiceCallState.idle;
  StreamSubscription? _stateSub;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _muted = false;
  bool _speaker = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final svc = ref.read(voiceCallServiceProvider);
    _stateSub = svc.stateStream.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
      if (s == VoiceCallState.active && _timer == null) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() => _elapsed += const Duration(seconds: 1));
        });
      }
      if (s == VoiceCallState.ended) {
        _timer?.cancel();
        if (mounted) Navigator.of(context).maybePop();
      }
    });

    if (widget.isIncoming) {
      await svc.acceptCall();
    } else {
      await svc.startCall(widget.peerId, peerName: widget.peerName);
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _hangup() async {
    await ref.read(voiceCallServiceProvider).hangup();
  }

  Future<void> _toggleMute() async {
    await ref.read(voiceCallServiceProvider).toggleMute();
    setState(() => _muted = !_muted);
  }

  Future<void> _toggleSpeaker() async {
    await ref.read(voiceCallServiceProvider).toggleSpeaker();
    setState(() => _speaker = !_speaker);
  }

  String get _stateLabel => switch (_state) {
        VoiceCallState.dialing => 'Вызов…',
        VoiceCallState.ringing => 'Входящий…',
        VoiceCallState.active => _formatDuration(_elapsed),
        VoiceCallState.ended => 'Завершён',
        VoiceCallState.idle => '',
      };

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.peerName ?? widget.peerId;
    return Scaffold(
      backgroundColor: const Color(0xFF03161D),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Avatar(name: name, size: 132, online: _state == VoiceCallState.active),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(
                color: kText,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _stateLabel,
              style: const TextStyle(
                  color: kTextMuted,
                  fontSize: 14,
                  fontFamily: 'JetBrainsMono'),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(
                  icon: _muted ? Icons.mic_off : Icons.mic_outlined,
                  active: _muted,
                  onTap: _toggleMute,
                ),
                const SizedBox(width: 22),
                _RoundButton(
                  icon: Icons.call_end,
                  color: kDanger,
                  size: 72,
                  onTap: _hangup,
                ),
                const SizedBox(width: 22),
                _RoundButton(
                  icon: _speaker ? Icons.volume_up : Icons.hearing_outlined,
                  active: _speaker,
                  onTap: _toggleSpeaker,
                ),
              ],
            ),
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    this.color,
    this.active = false,
    this.size = 64,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = color ??
        (active
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.10));
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: size * 0.42),
        ),
      ),
    );
  }
}
