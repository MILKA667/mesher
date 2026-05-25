import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/mesh_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: MeshAppBar(
        title: 'Profile',
        actions: [
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
