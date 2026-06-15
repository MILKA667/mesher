import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/theme/colors.dart';
import '../../../services/call_manager.dart';
import '../../providers/app_providers.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.peerId,
    this.peerName,
    this.isIncoming = false,
  });

  final String peerId;
  final String? peerName;
  final bool isIncoming;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  CallState _state = CallState.idle;
  bool _micMuted = false;
  bool _camOff = false;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final manager = ref.read(callManagerProvider);
    await manager.init();

    _stateSub = manager.stateStream.listen((s) {
      if (mounted) setState(() => _state = s);
      if (s == CallState.ended && mounted) Navigator.of(context).pop();
    });

    if (widget.isIncoming) {
      await manager.acceptPendingCall();
    } else {
      await manager.startCall(widget.peerId);
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _end() async {
    await ref.read(callManagerProvider).endCall();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(callManagerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen)
            SizedBox.expand(
              child: RTCVideoView(
                manager.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
            // Local video (picture-in-picture)
            Positioned(
              top: 72,
              right: 14,
              width: 90,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RTCVideoView(
                  manager.localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
            // Top bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.peerName ?? widget.peerId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _stateLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Call controls
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallButton(
                      icon: _micMuted ? Icons.mic_off : Icons.mic_outlined,
                      active: _micMuted,
                      onPressed: () => setState(() => _micMuted = !_micMuted),
                    ),
                    const SizedBox(width: 18),
                    _CallButton(
                      icon: Icons.call_end,
                      color: kDanger,
                      size: 68,
                      onPressed: _end,
                    ),
                    const SizedBox(width: 18),
                    _CallButton(
                      icon: _camOff
                          ? Icons.videocam_off_outlined
                          : Icons.videocam_outlined,
                      active: _camOff,
                      onPressed: () => setState(() => _camOff = !_camOff),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _stateLabel => switch (_state) {
        CallState.calling => 'Вызов…',
        CallState.incoming => 'Входящий…',
        CallState.connected => 'Подключено',
        CallState.ended => 'Завершён',
        CallState.idle => '',
      };
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.active = false,
    this.size = 60,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = color ??
        (active
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.12));
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: size * 0.43),
        ),
      ),
    );
  }
}
