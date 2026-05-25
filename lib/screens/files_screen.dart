import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/mesh_app_bar.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: MeshAppBar(
        title: 'Swarm',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kTextMuted),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0x2200D8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4400D8FF)),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: kAccent),
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: const SizedBox.expand(),
    );
  }
}
