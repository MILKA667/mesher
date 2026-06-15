import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/byte_format.dart';
import '../../../../domain/models/file_transfer.dart';
import '../../../widgets/mono_text.dart';

class FileCard extends StatelessWidget {
  const FileCard({super.key, required this.file});

  final FileTransfer file;

  Color get _stateColor => switch (file.state) {
        TransferState.active => kAccent,
        TransferState.seeding => kGood,
        TransferState.done => kWarn,
        TransferState.queued || TransferState.error => kTextMuted,
      };

  String get _stateLabel => switch (file.state) {
        TransferState.active => 'DOWNLOADING',
        TransferState.seeding => 'SEEDING',
        TransferState.done => 'COMPLETE',
        TransferState.queued => 'QUEUED',
        TransferState.error => 'ERROR',
      };

  static _FileKind _kindFromName(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if ({'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'}.contains(ext)) {
      return _FileKind.image;
    }
    if ({'pdf', 'doc', 'docx', 'txt', 'md', 'odt'}.contains(ext)) {
      return _FileKind.doc;
    }
    return _FileKind.archive;
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor;
    final isUpload = file.direction == TransferDirection.upload;
    final hash = file.infoHash != null
        ? file.infoHash!.substring(0, file.infoHash!.length.clamp(0, 8))
        : '——';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLine),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FilePreview(kind: _kindFromName(file.name)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            file.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isUpload ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: isUpload ? kGood : kAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    MonoText(
                      '${formatBytes(file.sizeBytes)} · ${file.peerCount} PEERS · #$hash',
                      fontSize: 10,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StateChip(label: _stateLabel, color: stateColor),
                        const SizedBox(width: 8),
                        if (file.state == TransferState.active &&
                            file.speedBytesPerSec > 0)
                          MonoText(
                            formatSpeed(file.speedBytesPerSec),
                            fontSize: 10,
                            color: kAccent,
                          ),
                        if (file.state == TransferState.seeding &&
                            file.speedBytesPerSec > 0)
                          MonoText(
                            '↑ ${formatSpeed(file.speedBytesPerSec)}',
                            fontSize: 10,
                            color: kGood,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: file.progressPercent / 100,
              minHeight: 4,
              backgroundColor: const Color(0xFF0A1216),
              valueColor: AlwaysStoppedAnimation<Color>(stateColor),
            ),
          ),
          if (file.state != TransferState.queued) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PeerPips(active: file.peerCount),
                MonoText('${file.progressPercent}%', fontSize: 10),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum _FileKind { image, doc, archive }

class _FilePreview extends StatelessWidget {
  const _FilePreview({required this.kind});
  final _FileKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == _FileKind.image) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A3A4A), Color(0xFF1A5B6E)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kLine2),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, size: 26, color: kAccent),
      );
    }
    if (kind == _FileKind.doc) {
      return Container(
        width: 54,
        height: 54,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: kCard2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kLine2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [0.9, 0.7, 0.85, 0.5].map((w) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: FractionallySizedBox(
                widthFactor: w,
                child: const SizedBox(
                  height: 2,
                  child: ColoredBox(color: kTextMuted),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    // archive
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kLine2),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        children: List.generate(
          4,
          (i) => Container(
            decoration: BoxDecoration(
              color: i.isOdd
                  ? kAccent.withValues(alpha: 0.13)
                  : kGood.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: MonoText(label, fontSize: 9, color: color),
    );
  }
}

class _PeerPips extends StatelessWidget {
  const _PeerPips({required this.active});
  final int active;

  @override
  Widget build(BuildContext context) {
    final count = active.clamp(0, 8);
    return Row(
      children: List.generate(8, (i) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: i < count
                ? kAccent.withValues(alpha: 0.85 - i * 0.07)
                : kTextDim.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
