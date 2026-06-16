import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/models/message.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/circle_button.dart';
import '../chat_controller.dart';

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

  Future<void> _attachFile() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;

    final file = File(path);
    final fileName = p.basename(path);
    final size = await file.length();

    // Persist a chat-side message so the user sees the file appear immediately.
    final msg = Message(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      kind: MessageKind.file,
      timestamp: DateTime.now(),
      isOutgoing: true,
      fileName: fileName,
      fileSizeBytes: size,
      filePath: path,
      status: MessageStatus.sending,
    );
    await ref.read(chatRepoProvider).saveMessage(msg);

    messenger?.showSnackBar(const SnackBar(
      content: Text('Отправка файла…'),
      backgroundColor: Color(0xFF10161C),
      duration: Duration(seconds: 1),
    ));

    try {
      await ref
          .read(fileTransferServiceProvider)
          .sendFile(widget.chatId, path);
      await ref
          .read(appDatabaseProvider)
          .updateMessageStatus(msg.id, MessageStatus.sent.index);
    } catch (e) {
      messenger?.showSnackBar(SnackBar(
        content: Text('Не удалось отправить файл: $e'),
        backgroundColor: const Color(0xFF10161C),
      ));
    }
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
            tooltip: 'Прикрепить файл',
            onPressed: _attachFile,
            icon: const Icon(Icons.attach_file, color: kTextMuted, size: 22),
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
                  hintText: 'Message',
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
