import 'package:flutter_test/flutter_test.dart';
import 'package:mesher/core/utils/byte_format.dart';

void main() {
  group('formatBytes', () {
    test('bytes', () => expect(formatBytes(512), '512 B'));
    test('kilobytes', () => expect(formatBytes(1536), '1.5 KB'));
    test('megabytes', () => expect(formatBytes(50_585_600), '48.2 MB'));
  });

  group('formatSpeed', () {
    test('appends /s', () => expect(formatSpeed(1024), '1.0 KB/s'));
  });
}
