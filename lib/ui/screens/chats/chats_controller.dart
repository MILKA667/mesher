import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database/app_database.dart';
import '../../../domain/models/contact.dart';
import '../../providers/app_providers.dart';
import 'chat_view_model.dart';

class ChatsState {
  const ChatsState({
    this.chats = const [],
    this.query = '',
    this.isLoading = true,
  });

  final List<ChatViewModel> chats;
  final String query;
  final bool isLoading;

  List<ChatViewModel> get filtered => query.isEmpty
      ? chats
      : chats
          .where((c) =>
              c.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();

  ChatsState copyWith({
    List<ChatViewModel>? chats,
    String? query,
    bool? isLoading,
  }) =>
      ChatsState(
        chats: chats ?? this.chats,
        query: query ?? this.query,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ChatsNotifier extends StateNotifier<ChatsState> {
  ChatsNotifier(this._db) : super(const ChatsState());
  final AppDatabase _db;

  void search(String query) => state = state.copyWith(query: query);

  Future<void> refreshChats(List<ChatRow> chatRows) async {
    final vms = await Future.wait(chatRows.map((row) async {
      final chat = AppDatabase.chatFromRow(row);
      // Join contact for mode/signal/online/nodeId
      final contactRow = await _db.findContact(chat.contactId);
      final contact = contactRow != null
          ? AppDatabase.contactFromRow(contactRow)
          : null;
      return ChatViewModel.fromChat(chat, contact: contact);
    }));
    state = state.copyWith(chats: vms, isLoading: false);
  }
}

final chatsNotifierProvider =
    StateNotifierProvider<ChatsNotifier, ChatsState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final notifier = ChatsNotifier(db);

  // Subscribe to DB stream
  db.watchChats().listen((rows) => notifier.refreshChats(rows));

  return notifier;
});

// Helper for building Contact-less ChatViewModel from domain contact
extension ContactModeHelper on Contact {
  static ConnectionMode modeOf(Contact? c) =>
      c?.mode ?? ConnectionMode.bluetooth;
}
