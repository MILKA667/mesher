import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/byte_format.dart';
import '../../../services/swarm_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/chip.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/top_bar.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  int _filter = 0; // 0=ALL 1=AVAILABLE 2=DOWNLOADING 3=SHARING

  List<SwarmEntry> _filtered(List<SwarmEntry> all) {
    return switch (_filter) {
      1 => all
          .where((e) => !e.isLocal && e.downloadProgress == 0)
          .toList(),
      2 => all
          .where((e) =>
              !e.isLocal &&
              e.downloadProgress > 0 &&
              e.downloadProgress < 100)
          .toList(),
      3 => all.where((e) => e.isLocal).toList(),
      _ => all,
    };
  }

  Future<void> _pickAndShare() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;
    final entry = await ref.read(swarmServiceProvider).shareFile(path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(entry == null
          ? 'Не удалось добавить файл'
          : 'Файл «${entry.name}» теперь раздаётся'),
      backgroundColor: const Color(0xFF10161C),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(swarmCatalogProvider);
    final all = catalogAsync.valueOrNull ?? <SwarmEntry>[];
    final files = _filtered(all);

    final available =
        all.where((e) => !e.isLocal && e.downloadProgress == 0).length;
    final downloading = all
        .where((e) =>
            !e.isLocal &&
            e.downloadProgress > 0 &&
            e.downloadProgress < 100)
        .length;
    final sharing = all.where((e) => e.isLocal).length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Файлы'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAccent,
        foregroundColor: const Color(0xFF001218),
        onPressed: _pickAndShare,
        icon: const Icon(Icons.add),
        label: const Text('РАЗДАТЬ',
            style: TextStyle(
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ),
      body: ListView(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                MeshChip('ВСЕ · ${all.length}',
                    active: _filter == 0,
                    onTap: () => setState(() => _filter = 0)),
                const SizedBox(width: 8),
                MeshChip(
                  'ДОСТУПНО · $available',
                  active: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
                const SizedBox(width: 8),
                MeshChip(
                  'ЗАГРУЖАЕТСЯ · $downloading',
                  active: _filter == 2,
                  onTap: () => setState(() => _filter = 2),
                ),
                const SizedBox(width: 8),
                MeshChip(
                  'Я РАЗДАЮ · $sharing',
                  active: _filter == 3,
                  onTap: () => setState(() => _filter = 3),
                ),
              ],
            ),
          ),
          if (files.isEmpty)
            const _EmptySwarm()
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: files
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SwarmCard(entry: entry),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

class _EmptySwarm extends StatelessWidget {
  const _EmptySwarm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 0),
      child: Column(
        children: [
          Icon(Icons.share_outlined,
              size: 48, color: kAccent.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          const MonoText('ФАЙЛОВ ПОКА НЕТ', fontSize: 11, color: kTextMuted),
          const SizedBox(height: 6),
          const Text(
            'Подключайся к пирам через вкладку «Рядом».\n'
            'Файлы, которыми ты делишься, появятся здесь и\n'
            'станут доступны другим в mesh-сети.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kTextDim, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SwarmCard extends ConsumerWidget {
  const _SwarmCard({required this.entry});
  final SwarmEntry entry;

  Color get _stateColor {
    if (entry.isLocal) return kGood;
    if (entry.downloadProgress > 0 && entry.downloadProgress < 100) {
      return kAccent;
    }
    return kTextMuted;
  }

  String get _stateLabel {
    if (entry.isLocal) {
      return entry.downloadProgress == 100 ? 'РАЗДАЮ' : 'ОТПРАВКА';
    }
    if (entry.downloadProgress == 100) return 'ГОТОВО';
    if (entry.downloadProgress > 0) return 'ЗАГРУЗКА';
    return 'ДОСТУПЕН';
  }

  bool get _canDownload =>
      !entry.isLocal && entry.downloadProgress < 100 && entry.peerCount > 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hash = entry.infoHash.length >= 8
        ? entry.infoHash.substring(0, 8)
        : entry.infoHash;
    final color = _stateColor;
    final hasProgress = entry.downloadProgress > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  entry.isLocal
                      ? Icons.cloud_upload_outlined
                      : Icons.cloud_download_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    MonoText(
                      '${formatBytes(entry.sizeBytes)} · '
                      '${entry.peerCount} пиров · #$hash',
                      fontSize: 10,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: color.withValues(alpha: 0.25)),
                          ),
                          child: MonoText(_stateLabel,
                              fontSize: 9, color: color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_canDownload)
                IconButton(
                  icon: const Icon(Icons.download, color: kAccent),
                  tooltip: 'Скачать файл',
                  onPressed: () {
                    ref
                        .read(swarmServiceProvider)
                        .downloadFile(entry.infoHash);
                  },
                ),
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: entry.downloadProgress / 100,
                minHeight: 4,
                backgroundColor: const Color(0xFF0A1216),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MonoText('${entry.peerCount} сидеров', fontSize: 10),
                MonoText('${entry.downloadProgress}%', fontSize: 10),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
