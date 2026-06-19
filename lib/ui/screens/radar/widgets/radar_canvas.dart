import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../domain/models/user_profile.dart';

class RadarCanvas extends StatefulWidget {
  const RadarCanvas({
    super.key,
    required this.users,
    required this.maxDistanceMeters,
    this.selectedUserId,
    this.onTapPeer,
  });

  final List<UserProfile> users;
  final int maxDistanceMeters;
  final String? selectedUserId;
  final ValueChanged<UserProfile>? onTapPeer;

  @override
  State<RadarCanvas> createState() => _RadarCanvasState();
}

class _RadarCanvasState extends State<RadarCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final side = c.maxWidth;
      return SizedBox(
        width: side,
        height: side,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            return GestureDetector(
              onTapUp: (d) => _handleTap(d.localPosition, side),
              child: CustomPaint(
                size: Size.square(side),
                painter: _RadarPainter(
                  users: widget.users,
                  maxDistance: widget.maxDistanceMeters,
                  sweepAngle: _ctrl.value * 2 * math.pi,
                  selectedUserId: widget.selectedUserId,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _handleTap(Offset pos, double side) {
    if (widget.onTapPeer == null) return;
    final center = Offset(side / 2, side / 2);
    final radius = side / 2 - 8;
    for (final u in widget.users) {
      final p = _RadarPainter.placePeer(
          u, widget.maxDistanceMeters, center, radius);
      if ((p - pos).distance <= 14) {
        widget.onTapPeer!(u);
        return;
      }
    }
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.users,
    required this.maxDistance,
    required this.sweepAngle,
    required this.selectedUserId,
  });

  final List<UserProfile> users;
  final int maxDistance;
  final double sweepAngle;
  final String? selectedUserId;

  static const _sweepArcRad = math.pi / 3;
  static const _ringCount = 4;

  static Offset placePeer(
    UserProfile u,
    int maxDistance,
    Offset center,
    double radius,
  ) {

    final clampedMax = maxDistance <= 0 ? 1 : maxDistance;
    final clamped = u.distanceMeters.clamp(0, clampedMax);

    final dFrac = 0.12 + 0.88 * (clamped / clampedMax);
    final r = radius * dFrac;

    final hash = u.userId.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0xFFFF);
    final angle = (hash / 0xFFFF) * 2 * math.pi;
    return center + Offset(math.cos(angle) * r, math.sin(angle) * r);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final ringPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (var i = 1; i <= _ringCount; i++) {
      canvas.drawCircle(center, radius * i / _ringCount, ringPaint);
    }

    final crossPaint = Paint()
      ..color = kAccent.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        crossPaint);
    canvas.drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        crossPaint);

    if (maxDistance > 0) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      for (var i = 1; i <= _ringCount; i++) {
        final d = (maxDistance * i / _ringCount).round();
        tp.text = TextSpan(
          text: '$d м',
          style: TextStyle(
            color: kAccent.withValues(alpha: 0.5),
            fontSize: 8,
            fontFamily: 'JetBrainsMono',
          ),
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(center.dx + radius * i / _ringCount - tp.width - 2,
              center.dy + 2),
        );
      }
    }

    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        sweepAngle - _sweepArcRad,
        _sweepArcRad,
        false,
      )
      ..close();
    final sweepShader = SweepGradient(
      startAngle: sweepAngle - _sweepArcRad,
      endAngle: sweepAngle,
      colors: [
        kAccent.withValues(alpha: 0.0),
        kAccent.withValues(alpha: 0.35),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(sweepPath, Paint()..shader = sweepShader);

    final edgePaint = Paint()
      ..color = kAccent.withValues(alpha: 0.85)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      center,
      center +
          Offset(math.cos(sweepAngle) * radius, math.sin(sweepAngle) * radius),
      edgePaint,
    );

    final centerGlow = Paint()
      ..color = kAccent.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 6, centerGlow);
    canvas.drawCircle(center, 4, Paint()..color = kAccent);

    for (final u in users) {
      final pos = placePeer(u, maxDistance, center, radius);
      final isSelected = selectedUserId == u.userId;

      final peerAngle = math.atan2(pos.dy - center.dy, pos.dx - center.dx);
      final delta = _angleDistance(peerAngle, sweepAngle);
      final lit = (1.0 - (delta / _sweepArcRad).clamp(0.0, 1.0));

      final base = u.isKnownContact ? kGood : kAccent;
      final dotColor = Color.lerp(
        base.withValues(alpha: 0.5),
        Colors.white,
        lit * 0.7,
      )!;

      if (lit > 0.1) {
        final pulsePaint = Paint()
          ..color = dotColor.withValues(alpha: 0.25 * lit)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(pos, 12 + 8 * lit, pulsePaint);
      }

      if (isSelected) {
        canvas.drawCircle(
          pos,
          14,
          Paint()
            ..color = base
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      canvas.drawCircle(pos, isSelected ? 8 : 6, Paint()..color = dotColor);
      canvas.drawCircle(
        pos,
        isSelected ? 8 : 6,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  static double _angleDistance(double a, double b) {
    var diff = (a - b) % (2 * math.pi);
    if (diff < 0) diff += 2 * math.pi;
    if (diff > math.pi) diff = 2 * math.pi - diff;
    return diff;
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.users != users ||
      old.sweepAngle != sweepAngle ||
      old.selectedUserId != selectedUserId ||
      old.maxDistance != maxDistance;
}
