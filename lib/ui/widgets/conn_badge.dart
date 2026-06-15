import 'package:flutter/material.dart';
import '../../domain/models/contact.dart';

/// Small icon showing connection mode (BT / WiFi / Hotspot).
class ConnBadge extends StatelessWidget {
  const ConnBadge({super.key, required this.mode, this.size = 12});

  final ConnectionMode mode;
  final double size;

  static const _colors = {
    ConnectionMode.bluetooth: Color(0xFF5AD7FF),
    ConnectionMode.wifi: Color(0xFF7CFFC4),
    ConnectionMode.hotspot: Color(0xFFFFB454),
  };

  static const _icons = {
    ConnectionMode.bluetooth: Icons.bluetooth,
    ConnectionMode.wifi: Icons.wifi,
    ConnectionMode.hotspot: Icons.wifi_tethering,
  };

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icons[mode]!,
      size: size,
      color: _colors[mode]!,
    );
  }
}
