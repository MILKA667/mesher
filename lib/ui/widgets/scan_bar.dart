import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Animated scan sweep bar showing peer positions on a linear range.
class ScanBar extends StatefulWidget {
  const ScanBar({super.key, this.peerPositions = const []});

  /// Normalized positions 0.0–1.0 for each peer dot.
  final List<double> peerPositions;

  @override
  State<ScanBar> createState() => _ScanBarState();
}

class _ScanBarState extends State<ScanBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScanPainter(
              progress: _ctrl.value,
              peers: widget.peerPositions,
            ),
          );
        },
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({required this.progress, required this.peers});

  final double progress;
  final List<double> peers;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;

    // base line
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()
        ..color = kAccent.withValues(alpha: 0.25)
        ..strokeWidth = 2,
    );

    // peer dots
    for (var i = 0; i < peers.length; i++) {
      final x = peers[i] * size.width;
      canvas.drawCircle(
        Offset(x, midY),
        5,
        Paint()..color = kAccent.withValues(alpha: 0.85 - i * 0.06),
      );
    }

    // sweep
    final sweepX = progress * (size.width + 36) - 36;
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          kAccent.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sweepX, 0, 36, size.height));
    canvas.drawRect(
      Rect.fromLTWH(sweepX, 0, 36, size.height),
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) =>
      old.progress != progress || old.peers != peers;
}
