import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utils/image_resize.dart';
import '../../providers/app_providers.dart';
import '../../widgets/avatar.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/top_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodeIdAsync = ref.watch(keyManagerInitProvider);
    final nodeId = nodeIdAsync.valueOrNull ?? '——·——';
    final ownAsync = ref.watch(ownProfileProvider);
    final nickname = ownAsync.valueOrNull?.nickname ??
        (nodeId.length >= 4 ? 'Node-${nodeId.substring(0, 4)}' : 'Node');
    final avatarBytes = ownAsync.valueOrNull?.avatar;
    final usersAsync = ref.watch(nearbyUsersProvider);
    final peerCount = usersAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Профиль'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
        children: [
          _IdentityCard(
            nodeId: nodeId,
            nickname: nickname,
            avatarBytes: avatarBytes,
            peerCount: peerCount,
            onEditAvatar: () => _pickAvatar(context, ref),
            onRemoveAvatar:
                avatarBytes != null ? () => _removeAvatar(context, ref) : null,
            onEditName: () => _editNickname(context, ref, nickname),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('СТАТИСТИКА'),
          const SizedBox(height: 10),
          const _StatsGrid(),
          const SizedBox(height: 24),
          const _SectionLabel('ТРАНСПОРТ'),
          const SizedBox(height: 10),
          const _BluetoothCard(),
          const SizedBox(height: 24),
          const _SectionLabel('ИДЕНТИФИКАТОР'),
          const SizedBox(height: 10),
          _NodeIdCard(nodeId: nodeId),
          const SizedBox(height: 24),
          const _SectionLabel('О ПРИЛОЖЕНИИ'),
          const SizedBox(height: 10),
          const _AboutCard(),
          const SizedBox(height: 24),
          const _SectionLabel('ОПАСНАЯ ЗОНА'),
          const SizedBox(height: 10),
          _DangerCard(onReset: () => _confirmReset(context, ref)),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;
    try {
      final bytes = await File(path).readAsBytes();
      final resized = resizeForAvatar(bytes);
      if (resized == null) {
        messenger?.showSnackBar(const SnackBar(
          content: Text('Не удалось обработать изображение'),
          backgroundColor: Color(0xFF10161C),
        ));
        return;
      }
      await ref.read(discoveryServiceProvider).updateOwnProfile(avatar: resized);
      ref.invalidate(ownProfileProvider);
      messenger?.showSnackBar(const SnackBar(
        content: Text('Фото обновлено'),
        backgroundColor: Color(0xFF10161C),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      messenger?.showSnackBar(SnackBar(
        content: Text('Ошибка: $e'),
        backgroundColor: const Color(0xFF10161C),
      ));
    }
  }

  Future<void> _removeAvatar(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Удалить фото?', style: TextStyle(color: kText)),
        content: const Text(
          'Аватар вернётся к инициалам.',
          style: TextStyle(color: kTextMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref
        .read(discoveryServiceProvider)
        .updateOwnProfile(avatar: Uint8List(0));
    ref.invalidate(ownProfileProvider);
  }

  Future<void> _editNickname(
      BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Никнейм', style: TextStyle(color: kText)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          style: const TextStyle(color: kText),
          decoration: const InputDecoration(
            hintText: 'Как тебя видят рядом',
            hintStyle: TextStyle(color: kTextMuted),
            counterStyle: TextStyle(color: kTextDim, fontSize: 10),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Отмена', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Сохранить', style: TextStyle(color: kAccent)),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == current) return;
    await ref
        .read(discoveryServiceProvider)
        .updateOwnProfile(nickname: newName);
    ref.invalidate(ownProfileProvider);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Сбросить личность?',
            style: TextStyle(color: kText)),
        content: const Text(
          'ID устройства, никнейм и фото будут удалены. История чатов '
          'тоже исчезнет. Действие необратимо.',
          style: TextStyle(color: kTextMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Сбросить', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref.read(secureStorageProvider).deleteAll();
    messenger?.showSnackBar(const SnackBar(
      content: Text('Личность сброшена. Перезапусти приложение.'),
      backgroundColor: Color(0xFF10161C),
    ));
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
            letterSpacing: 1.2,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      );
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.nodeId,
    required this.nickname,
    required this.avatarBytes,
    required this.peerCount,
    required this.onEditAvatar,
    required this.onRemoveAvatar,
    required this.onEditName,
  });

  final String nodeId;
  final String nickname;
  final Uint8List? avatarBytes;
  final int peerCount;
  final VoidCallback onEditAvatar;
  final VoidCallback? onRemoveAvatar;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onEditAvatar,
            onLongPress: onRemoveAvatar,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(
                  name: nickname,
                  size: 80,
                  online: true,
                  avatarBytes: avatarBytes,
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: kCard, width: 2),
                    ),
                    child: const Icon(Icons.photo_camera_outlined,
                        size: 14, color: Color(0xFF001218)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onEditName,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          nickname,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: kText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_outlined,
                          size: 14, color: kTextMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                MonoText('#$nodeId', fontSize: 11),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _IdentityChip(
                      icon: Icons.bluetooth,
                      color: const Color(0xFF5AD7FF),
                      label: 'BLE',
                    ),
                    const SizedBox(width: 6),
                    _IdentityChip(
                      icon: Icons.people_outline,
                      color: kAccent,
                      label: '$peerCount рядом',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityChip extends StatelessWidget {
  const _IdentityChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatsStreamProvider).valueOrNull ?? const [];
    final nearby = ref.watch(nearbyUsersProvider).valueOrNull ?? const [];

    final unread =
        chats.fold<int>(0, (sum, c) => sum + c.unreadCount);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: [
        _StatTile(
          icon: Icons.chat_bubble_outline,
          value: chats.length.toString(),
          label: 'чатов',
          accent: kAccent,
        ),
        _StatTile(
          icon: Icons.notifications_active_outlined,
          value: unread.toString(),
          label: 'непрочитанных',
          accent: kWarn,
        ),
        _StatTile(
          icon: Icons.people_outline,
          value: nearby.length.toString(),
          label: 'пиров рядом',
          accent: const Color(0xFF5AD7FF),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kText,
                  fontFamily: 'JetBrainsMono',
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: kTextMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BluetoothCard extends StatelessWidget {
  const _BluetoothCard();

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF5AD7FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bluetooth, color: activeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bluetooth LE',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kText)),
                SizedBox(height: 2),
                Text('Активен · радиус до 50 м',
                    style: TextStyle(fontSize: 11, color: kTextMuted)),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: activeColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _NodeIdCard extends StatelessWidget {
  const _NodeIdCard({required this.nodeId});
  final String nodeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fingerprint, size: 16, color: kAccent),
              const SizedBox(width: 8),
              const Text(
                'ID узла',
                style: TextStyle(
                  fontSize: 12,
                  color: kTextMuted,
                  fontFamily: 'JetBrainsMono',
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Скопировать',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: nodeId));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Идентификатор скопирован'),
                    backgroundColor: Color(0xFF10161C),
                    duration: Duration(seconds: 1),
                  ));
                },
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: const Icon(Icons.copy_rounded,
                    size: 16, color: kTextMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            _formatHex(nodeId),
            style: const TextStyle(
              fontSize: 14,
              color: kText,
              fontFamily: 'JetBrainsMono',
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Уникальный 16-символьный код устройства. Покажи его другому пиру, '
            'чтобы он точно знал, что добавляет тебя.',
            style: TextStyle(fontSize: 11, color: kTextDim, height: 1.5),
          ),
        ],
      ),
    );
  }

  static String _formatHex(String hex) {
    final buf = StringBuffer();
    for (var i = 0; i < hex.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' · ');
      buf.write(hex[i]);
    }
    return buf.toString();
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Column(
        children: const [
          _AboutRow(
            icon: Icons.cloud_off_outlined,
            color: Color(0xFF5AD7FF),
            title: 'Без серверов',
            subtitle: 'Только peer-to-peer через BLE-меш',
          ),
          _Divider(),
          _AboutRow(
            icon: Icons.bolt_outlined,
            color: kGood,
            title: 'Работает без интернета',
            subtitle: 'Сеть строится из ближайших устройств',
          ),
          _Divider(),
          _AboutRow(
            icon: Icons.tag_faces_outlined,
            color: kAccent,
            title: 'MeshLink 1.1.0',
            subtitle: 'Открытый протокол, проверяемый код',
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: kText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: kTextMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: kLine);
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kDanger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDanger.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kDanger.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: kDanger, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Сбросить личность',
                    style: TextStyle(
                        color: kText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text(
                  'Удалит ID, никнейм и фото. История исчезнет.',
                  style: TextStyle(color: kTextMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(
                backgroundColor: kDanger.withValues(alpha: 0.15)),
            child: const Text('Сброс',
                style: TextStyle(
                    color: kDanger,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.4)),
          ),
        ],
      ),
    );
  }
}
