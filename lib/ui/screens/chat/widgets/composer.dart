import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../widgets/circle_button.dart';
import '../chat_controller.dart';
import 'emoji_picker.dart';

class Composer extends ConsumerStatefulWidget {
  const Composer({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref
        .read(chatNotifierProvider(widget.chatId).notifier)
        .sendText(text);
  }

  Future<void> _pickEmoji() async {
    final emoji = await EmojiSheet.show(context, title: 'ВЫБЕРИ ЭМОДЗИ');
    if (emoji == null) return;
    final sel = _controller.selection;
    final start = sel.isValid ? sel.start : _controller.text.length;
    final end = sel.isValid ? sel.end : _controller.text.length;
    final newText =
        _controller.text.replaceRange(start, end, emoji);
    _controller.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kLine)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Эмодзи',
            onPressed: _pickEmoji,
            icon: const Icon(Icons.emoji_emotions_outlined,
                color: kTextMuted, size: 22),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kLine),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14, color: kText),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Сообщение',
                  hintStyle:
                      TextStyle(fontSize: 14, color: kTextMuted),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleButton(
            onPressed: _hasText ? _send : null,
            accent: _hasText,
            size: 38,
            child: const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
