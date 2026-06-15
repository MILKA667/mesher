import 'package:drift/drift.dart';
import '../../domain/models/contact.dart';
import '../local/database/app_database.dart';

abstract interface class PeerRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(Contact contact);
  Future<void> removeContact(String contactId);
}

class PeerRepositoryImpl implements PeerRepository {
  PeerRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Future<List<Contact>> getContacts() async {
    final rows = await _db.select(_db.contacts).get();
    return rows.map(AppDatabase.contactFromRow).toList();
  }

  @override
  Future<void> addContact(Contact c) => _db.upsertContact(
        ContactsCompanion.insert(
          id: c.id,
          name: c.name,
          nodeId: c.nodeId,
          publicKey: Uint8List(0),
          mode: Value(c.mode.index),
          signalLevel: Value(c.signalLevel),
          isOnline: Value(c.isOnline),
          distanceMeters: Value(c.distanceMeters),
        ),
      );

  @override
  Future<void> removeContact(String contactId) => _db.deleteContact(contactId);
}
