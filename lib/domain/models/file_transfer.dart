enum TransferDirection { download, upload }

enum TransferState { queued, active, seeding, done, error }

class FileTransfer {
  const FileTransfer({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.direction,
    required this.state,
    this.progressPercent = 0,
    this.peerCount = 0,
    this.speedBytesPerSec = 0,
    this.infoHash,
  });

  final String id;
  final String name;
  final int sizeBytes;
  final TransferDirection direction;
  final TransferState state;
  final int progressPercent;
  final int peerCount;
  final int speedBytesPerSec;
  final String? infoHash;
}
