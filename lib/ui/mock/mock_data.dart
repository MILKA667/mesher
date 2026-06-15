import '../../domain/models/contact.dart';

// ─────────────────────────────────────────────────────────────
// Data classes (UI-only, не связаны с репозиториями)
// ─────────────────────────────────────────────────────────────

enum MockMsgKind { text, file, voice }

enum MockTransferState { active, seeding, queued, done }

enum MockFileKind { archive, doc, image }

class MockChatEntry {
  const MockChatEntry({
    required this.id,
    required this.name,
    required this.nodeId,
    required this.lastMsg,
    required this.time,
    required this.mode,
    required this.signal,
    this.unreadCount = 0,
    this.online = true,
    this.isGroup = false,
    this.memberCount,
    this.isTyping = false,
    this.isFile = false,
    this.isVoice = false,
    this.isSent = false,
  });

  final String id;
  final String name;
  final String nodeId;
  final String lastMsg;
  final String time;
  final ConnectionMode mode;
  final int signal;
  final int unreadCount;
  final bool online;
  final bool isGroup;
  final int? memberCount;
  final bool isTyping;
  final bool isFile;
  final bool isVoice;
  final bool isSent;
}

class MockFileMeta {
  const MockFileMeta({
    required this.name,
    required this.size,
    required this.peers,
    required this.pct,
    this.speed,
  });

  final String name;
  final String size;
  final int peers;
  final double pct;
  final String? speed;
}

class MockMessage {
  const MockMessage({
    required this.kind,
    required this.sender,
    required this.time,
    this.text,
    this.isSent = false,
    this.signal,
    this.file,
    this.waveform,
    this.voiceDur,
  });

  final MockMsgKind kind;
  final String sender; // 'me' | 'them'
  final String time;
  final String? text;
  final bool isSent;
  final int? signal;
  final MockFileMeta? file;
  final List<double>? waveform;
  final String? voiceDur;

  bool get isMe => sender == 'me';
}

class MockPeer {
  const MockPeer({
    required this.name,
    required this.nodeId,
    required this.dist,
    required this.mode,
    required this.signal,
    required this.status,
    this.battery,
    this.isKnown = true,
  });

  final String name;
  final String nodeId;
  final int dist;
  final ConnectionMode mode;
  final int signal;
  final String status;
  final int? battery;
  final bool isKnown;
}

class MockFileItem {
  const MockFileItem({
    required this.id,
    required this.name,
    required this.kind,
    required this.size,
    required this.isUpload,
    required this.state,
    required this.pct,
    required this.peers,
    required this.hash,
    this.speed,
    this.eta,
  });

  final String id;
  final String name;
  final MockFileKind kind;
  final String size;
  final bool isUpload;
  final MockTransferState state;
  final int pct;
  final int peers;
  final String hash;
  final String? speed;
  final String? eta;
}

// ─────────────────────────────────────────────────────────────
// Mock instances
// ─────────────────────────────────────────────────────────────

const kMockChats = <MockChatEntry>[
  MockChatEntry(
    id: 'lab',
    name: 'Mesh Lab',
    nodeId: 'AB12CD',
    lastMsg: 'Anya: pushed the new build, 12 peers seeding',
    time: '09:42',
    mode: ConnectionMode.wifi,
    signal: 4,
    unreadCount: 2,
    online: true,
    isGroup: true,
    memberCount: 7,
  ),
  MockChatEntry(
    id: 'eli',
    name: 'Eli Park',
    nodeId: '7F2AE4',
    lastMsg: 'screen-share starting in 2 min',
    time: '09:36',
    mode: ConnectionMode.wifi,
    signal: 3,
    unreadCount: 1,
    online: true,
  ),
  MockChatEntry(
    id: 'kara',
    name: 'Kara Vance',
    nodeId: '2D88F0',
    lastMsg: 'sent 4 files · 312 MB',
    time: '09:11',
    mode: ConnectionMode.bluetooth,
    signal: 2,
    online: true,
    isFile: true,
  ),
  MockChatEntry(
    id: 'rio',
    name: 'Rio Tanaka',
    nodeId: '5B17A9',
    lastMsg: '',
    time: '08:54',
    mode: ConnectionMode.hotspot,
    signal: 4,
    online: true,
    isTyping: true,
  ),
  MockChatEntry(
    id: 'sun',
    name: 'Sun Okafor',
    nodeId: 'C3E0F1',
    lastMsg: 'noted, will mirror tonight',
    time: 'Вчера',
    mode: ConnectionMode.wifi,
    signal: 3,
    online: false,
    isSent: true,
  ),
  MockChatEntry(
    id: 'mira',
    name: 'Mira Holm',
    nodeId: 'F3C077',
    lastMsg: 'voice · 0:48',
    time: 'Вчера',
    mode: ConnectionMode.bluetooth,
    signal: 1,
    online: false,
    isVoice: true,
  ),
  MockChatEntry(
    id: 'block42',
    name: 'Block 42 ★',
    nodeId: 'E9A001',
    lastMsg: '14 nodes online · 3 new',
    time: 'Пн',
    mode: ConnectionMode.wifi,
    signal: 4,
    online: true,
    isGroup: true,
    memberCount: 14,
  ),
  MockChatEntry(
    id: 'jay',
    name: 'Jay Romero',
    nodeId: '9C0DB1',
    lastMsg: 'thanks!',
    time: 'Вс',
    mode: ConnectionMode.wifi,
    signal: 0,
    online: false,
    isSent: true,
  ),
];

const kMockMessages = <MockMessage>[
  MockMessage(
    kind: MockMsgKind.text,
    sender: 'them',
    time: '09:30',
    text: 'we testing the mesh tonight?',
    signal: 4,
  ),
  MockMessage(
    kind: MockMsgKind.text,
    sender: 'me',
    time: '09:31',
    text: 'yeah. I\'ve got 8 peers in range already',
  ),
  MockMessage(
    kind: MockMsgKind.text,
    sender: 'me',
    time: '09:31',
    text: 'gonna seed the dataset',
    isSent: true,
  ),
  MockMessage(
    kind: MockMsgKind.file,
    sender: 'them',
    time: '09:34',
    file: MockFileMeta(
      name: 'mesh-build-0.7.4.tar.gz',
      size: '48.2 MB',
      peers: 6,
      pct: 0.62,
      speed: '4.2 MB/s',
    ),
  ),
  MockMessage(
    kind: MockMsgKind.text,
    sender: 'them',
    time: '09:36',
    text: 'ok pulling. screen-share starting in 2 min — wanna jump on?',
    signal: 3,
  ),
  MockMessage(
    kind: MockMsgKind.voice,
    sender: 'me',
    time: '09:37',
    isSent: true,
    voiceDur: '0:14',
    waveform: [
      0.3, 0.6, 0.4, 0.8, 0.5, 0.9, 0.6, 0.4,
      0.7, 0.5, 0.6, 0.3, 0.5, 0.7, 0.4, 0.6,
      0.3, 0.4, 0.7, 0.5, 0.6, 0.4, 0.3,
    ],
  ),
  MockMessage(
    kind: MockMsgKind.text,
    sender: 'them',
    time: '09:38',
    text: 'cool. radar shows you at 24m through the wall',
    signal: 3,
  ),
];

const kMockPeers = <MockPeer>[
  MockPeer(
    name: 'Anya Volkov',
    nodeId: '9C0DB1',
    dist: 4,
    mode: ConnectionMode.bluetooth,
    signal: 4,
    status: 'In range · paired',
    battery: 84,
    isKnown: true,
  ),
  MockPeer(
    name: 'Eli Park',
    nodeId: '7F2AE4',
    dist: 24,
    mode: ConnectionMode.wifi,
    signal: 3,
    status: 'Through wall',
    battery: 62,
    isKnown: true,
  ),
  MockPeer(
    name: 'Kara Vance',
    nodeId: '2D88F0',
    dist: 38,
    mode: ConnectionMode.wifi,
    signal: 2,
    status: 'Sharing 4 files',
    battery: 41,
    isKnown: true,
  ),
  MockPeer(
    name: 'Node-9F2C',
    nodeId: '9F2C11',
    dist: 46,
    mode: ConnectionMode.hotspot,
    signal: 3,
    status: 'Hotspot · open',
    isKnown: false,
  ),
  MockPeer(
    name: 'Rio Tanaka',
    nodeId: '5B17A9',
    dist: 62,
    mode: ConnectionMode.wifi,
    signal: 2,
    status: 'Public broadcast',
    battery: 55,
    isKnown: true,
  ),
  MockPeer(
    name: 'Mira Holm',
    nodeId: 'F3C077',
    dist: 88,
    mode: ConnectionMode.bluetooth,
    signal: 1,
    status: 'Edge of range',
    battery: 23,
    isKnown: true,
  ),
  MockPeer(
    name: 'Anon-7842',
    nodeId: '7842DE',
    dist: 120,
    mode: ConnectionMode.wifi,
    signal: 1,
    status: 'Anonymous · relay',
    isKnown: false,
  ),
];

const kMockFiles = <MockFileItem>[
  MockFileItem(
    id: 'f1',
    name: 'Mesh_Build_0.7.4.tar.gz',
    kind: MockFileKind.archive,
    size: '48.2 MB',
    isUpload: false,
    state: MockTransferState.active,
    pct: 62,
    peers: 6,
    hash: 'd3e8a1',
    speed: '4.2 MB/s',
    eta: '7s',
  ),
  MockFileItem(
    id: 'f2',
    name: 'Field_Recordings.zip',
    kind: MockFileKind.archive,
    size: '312 MB',
    isUpload: true,
    state: MockTransferState.seeding,
    pct: 100,
    peers: 4,
    hash: '7f0c44',
    speed: '1.8 MB/s',
  ),
  MockFileItem(
    id: 'f3',
    name: 'Map_Sector_42.geojson',
    kind: MockFileKind.doc,
    size: '1.1 MB',
    isUpload: false,
    state: MockTransferState.queued,
    pct: 0,
    peers: 2,
    hash: 'a1b9d2',
  ),
  MockFileItem(
    id: 'f4',
    name: 'IMG_4421.heic',
    kind: MockFileKind.image,
    size: '8.4 MB',
    isUpload: false,
    state: MockTransferState.done,
    pct: 100,
    peers: 0,
    hash: 'b22f0e',
  ),
  MockFileItem(
    id: 'f5',
    name: 'Operation_Notes.md',
    kind: MockFileKind.doc,
    size: '14 KB',
    isUpload: true,
    state: MockTransferState.seeding,
    pct: 100,
    peers: 9,
    hash: 'e6c1aa',
    speed: '~24 KB/s',
  ),
];
