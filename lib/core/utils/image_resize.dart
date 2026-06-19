import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List? resizeForAvatar(
  Uint8List bytes, {
  int maxSize = 128,
  int quality = 75,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  final minSide =
      decoded.width < decoded.height ? decoded.width : decoded.height;
  final x = (decoded.width - minSide) ~/ 2;
  final y = (decoded.height - minSide) ~/ 2;
  final square = img.copyCrop(decoded,
      x: x, y: y, width: minSide, height: minSide);
  final resized = square.width > maxSize
      ? img.copyResize(square, width: maxSize, height: maxSize)
      : square;
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}
