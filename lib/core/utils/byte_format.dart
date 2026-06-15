/// Formats byte count to human-readable string: "48.2 MB", "1.1 KB".
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// Formats bytes-per-second to "4.2 MB/s".
String formatSpeed(int bytesPerSec) => '${formatBytes(bytesPerSec)}/s';
