import 'package:flutter_test/flutter_test.dart';
import 'package:mesher/core/utils/hex.dart';

void main() {
  group('formatNodeId', () {
    test('formats 6-char hex with dot separator', () {
      expect(formatNodeId('7F2AE4'), '7F2A·E4');
    });

    test('uppercases input', () {
      expect(formatNodeId('7f2ae4'), '7F2A·E4');
    });

    test('strips non-hex characters', () {
      expect(formatNodeId('7F2A·E4'), '7F2A·E4');
    });
  });
}
