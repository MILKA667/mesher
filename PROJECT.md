# mesher — Project Reference

> Offline P2P mesh messenger: Bluetooth BLE + WiFi Direct + Hotspot relay.  
> Crypto: Ed25519 identity, X25519 ECDH, AES-256-GCM.  
> No server, no internet required.

---

## Quick start

```bash
flutter pub get
dart run build_runner build      # regenerate Drift DB code after schema changes
flutter analyze                  # должно быть No issues found
flutter run                      # запуск на подключённом Android-устройстве
```

---

## Architecture principle

**Dart owns logic. Kotlin is a thin hardware bridge.**

```
Kotlin (platform channels)          Dart (everything else)
──────────────────────────          ─────────────────────────────────────────
BleScanner → raw advertisements  →  BluetoothTransport → parse, RSSI→distance
WifiDirectManager → raw events   →  WifiDirectTransport → connect logic
HotspotServer → raw TCP frames   →  HotspotTransport → routing
                                     ↓
                                  FloodRouter (loop-prevention via seen set)
                                     ↓
                                  MeshServiceImpl (orchestrator)
                                     ↓ encrypt/decrypt
                                  KeyManagerImpl (Ed25519) + MessageCryptoImpl (AES-GCM)
                                  SessionManagerImpl (X25519 ECDH handshake)
                                     ↓
                                  ChatRepositoryImpl (Drift SQLite)
                                     ↓
                                  Riverpod providers → screen controllers → UI
```

---

## Platform channels

| Channel | Direction | Purpose |
|---------|-----------|---------|
| `meshlink/bluetooth` | Dart→Kotlin | start/stop/connect/send BLE |
| `meshlink/bluetooth/peers` | Kotlin→Dart | EventChannel: discovered peer advertisements |
| `meshlink/bluetooth/rx` | Kotlin→Dart | EventChannel: received BLE data frames |
| `meshlink/wifidirect` | Dart→Kotlin | start/stop/connect/send WiFi Direct |
| `meshlink/wifidirect/peers` | Kotlin→Dart | EventChannel: discovered WiFi Direct peers |
| `meshlink/wifidirect/rx` | Kotlin→Dart | EventChannel: received WiFi Direct frames |
| `meshlink/hotspot` | Dart→Kotlin | start/stop hotspot AP |
| `meshlink/hotspot/rx` | Kotlin→Dart | EventChannel: received TCP frames from clients |
| `meshlink/foreground` | Dart→Kotlin | start/stop foreground service |

Peer advertisement map (BLE): `{nodeId: String, rssi: int, advData: Uint8List}`  
RX frame map: `{nodeId: String, data: Uint8List}`

---

## Key files

```
lib/
├── main.dart                         ProviderScope entry point
├── app.dart                          IndexedStack + BottomNav (4 tabs)
│
├── core/
│   ├── theme/colors.dart             kBg(#06080A), kAccent(#00D8FF), kCard, kText…
│   ├── constants.dart                channel name strings
│   └── utils/byte_format.dart        formatBytes(), formatSpeed()
│
├── domain/models/
│   ├── contact.dart                  ConnectionMode enum, Contact
│   ├── chat.dart                     Chat
│   ├── message.dart                  MessageKind/Status enums, Message
│   ├── peer.dart                     Peer (uses ConnectionMode)
│   └── file_transfer.dart            TransferDirection/State enums, FileTransfer
│
├── data/
│   ├── local/database/
│   │   ├── app_database.dart         @DriftDatabase, domain mappers (contactFromRow etc.)
│   │   ├── app_database.g.dart       GENERATED — do not edit
│   │   └── tables/                   Contacts, Chats, Messages, FileTransfers
│   ├── local/secure_storage.dart     SecureStorageImpl (flutter_secure_storage)
│   ├── local/file_storage.dart       FileStorageImpl (path_provider)
│   └── repositories/
│       ├── chat_repository.dart      ChatRepositoryImpl (Drift)
│       ├── peer_repository.dart      PeerRepositoryImpl (in-memory stream + Drift contacts)
│       └── file_repository.dart      FileRepositoryImpl (Drift)
│
├── crypto/
│   ├── key_manager.dart              KeyManagerImpl: Ed25519 identity, X25519 sessions
│   ├── message_crypto.dart           MessageCryptoImpl: AES-256-GCM
│   └── session.dart                  SessionManagerImpl: ECDH key exchange
│
├── network/
│   ├── platform/                     Dart-side EventChannel wrappers
│   ├── protocol/packet_codec.dart    CborPacketCodec (CBOR wire format)
│   ├── routing/mesh_router.dart      FloodRouter
│   └── transport/                    BluetoothTransport, WifiDirectTransport, HotspotTransport
│
├── services/
│   ├── mesh_service.dart             MeshServiceImpl: orchestrates transports+crypto+routing; callSignals stream
│   ├── call_manager.dart             CallManager: WebRTC offer/answer/ICE via callSignal packets
│   ├── file_transfer_service.dart    FileTransferService: 8 KB chunks, AES-GCM encrypted, assembly on receive
│   └── foreground_service.dart       AndroidForegroundService
│
└── ui/
    ├── providers/app_providers.dart  Full Riverpod DI graph (callManagerProvider, fileTransferServiceProvider)
    ├── mock/mock_data.dart           UI-only mock data (for visual testing, not wired to logic)
    └── screens/
        ├── chats/   ChatsScreen + ChatsNotifier (chatsNotifierProvider)
        ├── chat/    ChatScreen + ChatNotifier (chatNotifierProvider.family(chatId))
        ├── radar/   RadarScreen (nearbyPeersProvider, ConsumerStatefulWidget)
        ├── files/   FilesScreen (transfersStreamProvider, ConsumerStatefulWidget)
        ├── profile/ ProfileScreen (keyManagerInitProvider, ConsumerWidget)
        └── call/    VideoCallScreen (callManagerProvider, RTCVideoView local+remote)
```

---

## Database schema (Drift / SQLite)

Column `body` in Messages stores the text content (renamed from `text` — Drift code-gen bug with column named same as Dart built-in method).

```
Contacts   id · name · nodeId · publicKey · mode · signalLevel · isOnline · distanceMeters · createdAt
Chats      id · contactId · displayName · lastMessage · lastMessageTime · unreadCount · isGroup · memberCount
Messages   id · chatId · kind · timestamp · isOutgoing · body · filePath · fileName · fileSizeBytes · durationSeconds · status
FileTransfers  id · name · sizeBytes · direction · state · progressPercent · peerCount · speedBytesPerSec · infoHash · localPath
```

After any schema change → `dart run build_runner build`

---

## Riverpod provider graph

```
appDatabaseProvider ─────────────────────────────────┐
secureStorageProvider → keyManagerProvider ────────────┤
                      → sessionManagerProvider          │
messageCryptoProvider ──────────────────────────────────┤
btChannelProvider → btTransportProvider                 │
wifiChannelProvider → wifiTransportProvider             │
hotspotChannelProvider → hotspotTransportProvider       │
packetCodecProvider → meshRouterProvider                │
                                                        ▼
chatRepoProvider ─────── chatsStreamProvider → chatsNotifierProvider
peerRepoProvider ─────── nearbyPeersProvider
fileRepoProvider ─────── transfersStreamProvider
meshServiceProvider ───── nearbyPeers stream + callSignals stream
keyManagerInitProvider ── Future<nodeId String>
messagesStreamProvider.family(chatId) → chatNotifierProvider.family(chatId)
callManagerProvider ───── CallManager (WebRTC, uses meshRouterProvider)
fileTransferServiceProvider ── FileTransferService (uses sessions+crypto+router+fileRepo+fileStorage)
```

---

## Android permissions (AndroidManifest.xml)

- `BLUETOOTH_SCAN` (neverForLocation), `BLUETOOTH_CONNECT`, `BLUETOOTH_ADVERTISE` — Android 12+
- `BLUETOOTH`, `BLUETOOTH_ADMIN` (maxSdkVersion=30) — Android ≤11
- `ACCESS_FINE_LOCATION` — needed for WiFi Direct up to Android 12
- `NEARBY_WIFI_DEVICES` (neverForLocation) — Android 13+
- `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_CONNECTED_DEVICE` — background BLE scan
- `CAMERA`, `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS` — WebRTC video calls

MeshForegroundService: `foregroundServiceType="connectedDevice"`, runs on port :7890 (Hotspot TCP server).

---

## Known issues / TODOs

| Area | Status | Notes |
|------|--------|-------|
| BLE GATT connect/send | **Done** | `BleGattClient.kt` (new) + `BleGattServer.kt` opens real server, manages outgoing clients |
| WiFi Direct group | **Done** | `WifiDirectManager.kt` handles `CONNECTION_CHANGED` → `requestConnectionInfo` → GO starts `WifiDirectServer.kt` (TCP :7891), non-GO connects as client via `WifiDirectSocket.kt` |
| flutter_webrtc | **Done** | `CallManager` (new) handles offer/answer/ICE via `callSignal` packets; `VideoCallScreen` wired to `callManagerProvider` |
| Fonts | Open | Add TTF to `assets/fonts/`, uncomment `pubspec.yaml` fonts section |
| minSdk | **Done** | `minSdk = 21` in `app/build.gradle.kts` |
| File chunked transfer | **Done** | `FileTransferService` (new): 8 KB chunks, announce→chunks protocol, AES-GCM encrypted, assembles incoming files to disk via `FileStorage` |
| Message encryption flow | **Done** | `SessionManager.hasPendingHandshake()` added; `MeshServiceImpl` queues messages in `_pendingQueue` per peer and flushes after handshake; responder/initiator key-exchange correctly distinguished |

---

## Crypto notes

- Node identity: Ed25519 key pair, private key stored in `flutter_secure_storage` (Android Keystore backed) as base64 seed
- Node ID: first 8 bytes of Ed25519 public key, formatted as `7F2A·E4·9C0D` for display
- Session key: X25519 ECDH; each peer pair gets ephemeral key pair → 32-byte shared secret → AES-256-GCM key
- Wire format: `nonce(12 bytes) || ciphertext || mac(16 bytes)` concatenated

---

## Packet wire format (CBOR)

```
CBOR array: [typeIndex, senderId, recipientId|null, sessionId|null, payload(bytes)]
PacketType: 0=message, 1=fileChunk, 2=fileAnnounce, 3=ping, 4=pong, 5=keyExchange
```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.6.1 | State management (manual providers, no codegen) |
| drift + drift_flutter | ^2.23.1 | SQLite DB with type-safe queries |
| sqlite3_flutter_libs | ^0.5.26 | SQLite native libs |
| flutter_secure_storage | ^9.2.2 | Key storage (Android Keystore) |
| cryptography | ^2.7.0 | Ed25519, X25519, AES-256-GCM (pure Dart) |
| flutter_webrtc | ^0.12.5 | Video/audio calls |
| flutter_foreground_task | ^8.13.0 | Background BLE/WiFi scan |
| path_provider + path | ^2.1.4 | File storage paths |
| cbor | ^6.3.1 | Packet codec |
| uuid | ^4.5.1 | ID generation |
