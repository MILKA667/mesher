/// Formats a raw hex node ID (e.g. "7F2AE4") to display form "7F2A·E4".
String formatNodeId(String raw) {
  final clean = raw.toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
  if (clean.length < 6) return clean;
  return '${clean.substring(0, 4)}·${clean.substring(4, 6)}';
}

/// Shortened node ID for display in limited space.
String shortNodeId(String raw) {
  final full = formatNodeId(raw);
  if (full.length > 7) return full.substring(0, 7);
  return full;
}
