import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/byte_format.dart';
import '../../../domain/models/file_transfer.dart';
import '../../providers/app_providers.dart';
import '../../widgets/chip.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/top_bar.dart';
import 'widgets/file_card.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  int _filter = 0; // 0=ALL 1=ACTIVE 2=SEEDING 3=DONE

  List<FileTransfer> _filtered(List<FileTransfer> all) {
    return switch (_filter) {
      1 => all.where((f) => f.state == TransferState.active).toList(),
      2 => all.where((f) => f.state == TransferState.seeding).toList(),
      3 => all.where((f) => f.state == TransferState.done).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final transfersAsync = ref.watch(transfersStreamProvider);
    final all = transfersAsync.valueOrNull ?? [];
    final files = _filtered(all);

    final activeCount = all.where((f) => f.state == TransferState.active).length;
    final seedCount = all.where((f) => f.state == TransferState.seeding).length;
    final doneCount = all.where((f) => f.state == TransferState.done).length;

    final totalDownSpeed = all
        .where((f) =>
            f.state == TransferState.active &&
            f.direction == TransferDirection.download)
        .fold(0, (sum, f) => sum + f.speedBytesPerSec);

    final totalUpSpeed = all
        .where((f) =>
            f.state == TransferState.seeding ||
            (f.state == TransferState.active &&
                f.direction == TransferDirection.upload))
        .fold(0, (sum, f) => sum + f.speedBytesPerSec);

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Swarm'),
      body: ListView(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                StatCard(
                  label: 'DOWN',
                  value: totalDownSpeed > 0 ? formatSpeed(totalDownSpeed) : '—',
                  icon: const Icon(Icons.arrow_downward),
                ),
                const SizedBox(width: 10),
                StatCard(
                  label: 'UP',
                  value: totalUpSpeed > 0 ? formatSpeed(totalUpSpeed) : '—',
                  icon: const Icon(Icons.arrow_upward),
                  valueColor: kGood,
                ),
                const SizedBox(width: 10),
                StatCard(
                  label: 'SEEDING',
                  value: '$seedCount',
                  icon: const Icon(Icons.share),
                  valueColor: kWarn,
                ),
              ],
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                MeshChip('ALL · ${all.length}',
                    active: _filter == 0,
                    onTap: () => setState(() => _filter = 0)),
                const SizedBox(width: 8),
                MeshChip(
                  'ACTIVE · $activeCount',
                  active: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
                const SizedBox(width: 8),
                MeshChip(
                  'SEEDING · $seedCount',
                  active: _filter == 2,
                  onTap: () => setState(() => _filter = 2),
                ),
                const SizedBox(width: 8),
                MeshChip(
                  'DONE · $doneCount',
                  active: _filter == 3,
                  onTap: () => setState(() => _filter = 3),
                ),
              ],
            ),
          ),
          // File cards
          if (files.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Нет передач',
                  style: TextStyle(fontSize: 13, color: kTextMuted),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: files
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FileCard(file: f),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
