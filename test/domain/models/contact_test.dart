import 'package:flutter_test/flutter_test.dart';
import 'package:mesher/domain/models/contact.dart';

void main() {
  const contact = Contact(
    id: '1',
    name: 'Eli Park',
    nodeId: '7F2AE4',
  );

  test('copyWith updates only given fields', () {
    final updated = contact.copyWith(isOnline: true, signalLevel: 3);
    expect(updated.isOnline, true);
    expect(updated.signalLevel, 3);
    expect(updated.name, contact.name);
    expect(updated.nodeId, contact.nodeId);
  });
}
