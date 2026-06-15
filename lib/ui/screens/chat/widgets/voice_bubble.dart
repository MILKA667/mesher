import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/models/message.dart';
import '../../../widgets/mono_text.dart';

class VoiceBubble extends StatelessWidget {
  const VoiceBubble({super.key, required this.message});
  final Message message;

  /// Deterministic pseudo-random waveform derived from message ID.
  List<double> _waveform() {
    final seed = message.id.hashCode;
    final rng = Random(seed);
    return List.generate(23, (_) => 0.15 + rng.nextDouble() * 0.85);
  }

  static String _dur(int? seconds) {
    if (seconds == null) return '0:00';
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isMe = message.isOutgoing;
    final waveform = _waveform();
    final bg = isMe ? kAccent.withValues(alpha: 0.13) : kCard;
    final border = isMe ? kAccent.withValues(alpha: 0.25) : kLine;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                      color: kAccent, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.play_arrow,
                      size: 18, color: Color(0xFF001218)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(waveform.length, (i) {
                        final active = i < 8;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 1),
                            child: FractionallySizedBox(
                              heightFactor: waveform[i].clamp(0.1, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: active ? kAccent : kTextMuted,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                MonoText(_dur(message.durationSeconds), fontSize: 10),
              ],
            ),
            const SizedBox(height: 4),
            MonoText(_time(message.timestamp),
                fontSize: 9, color: kTextDim),
          ],
        ),
      ),
    );
  }
}
