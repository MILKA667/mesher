import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/mesh_app_bar.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: MeshAppBar(
        title: 'Nearby',
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: kTextMuted),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: kTextMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: const SizedBox.expand(),
    );
  }
}
