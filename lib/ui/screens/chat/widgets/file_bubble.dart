import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/byte_format.dart';
import '../../../../domain/models/message.dart';
import '../../../widgets/mono_text.dart';

class FileBubble extends StatelessWidget {
  const FileBubble({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isOutgoing;
    final fileName = message.fileName ?? 'file';
    final size = message.fileSizeBytes != null
        ? formatBytes(message.fileSizeBytes!)
        : '—';
    final time =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
          minWidth: 240,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: kAccent.withValues(alpha: 0.2)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.folder_zip_outlined,
                        size: 18, color: kAccent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        MonoText('$size · TORRENT', fontSize: 11),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 4,
                  backgroundColor: Color(0xFF0A1216),
                  valueColor: AlwaysStoppedAnimation<Color>(kGood),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MonoText('COMPLETE', fontSize: 10, color: kGood),
                  MonoText(time, fontSize: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
