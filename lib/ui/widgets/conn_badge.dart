import 'package:flutter/material.dart';
import '../../domain/models/contact.dart';

class ConnBadge extends StatelessWidget {
  const ConnBadge({super.key, required this.mode, this.size = 12});

  final ConnectionMode mode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.bluetooth,
      size: size,
      color: const Color(0xFF5AD7FF),
    );
  }
}
