import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/mesh_app_bar.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: MeshAppBar(
        title: 'Mesh',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kTextMuted),
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
