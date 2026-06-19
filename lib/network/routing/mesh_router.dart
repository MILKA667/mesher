import 'dart:async';
import '../transport/transport.dart';
import '../protocol/packet.dart';
import '../protocol/packet_codec.dart';

abstract interface class MeshRouter {
  void addTransport(Transport transport);
  void removeTransport(Transport transport);
  Future<void> route(Packet packet);
  Stream<Packet> get incomingPackets;
  String? nextHopFor(String destinationNodeId);
}

class FloodRouter implements MeshRouter {
  FloodRouter(this._codec);
  final PacketCodec _codec;

  final _transports = <Transport>[];
  final _incomingController = StreamController<Packet>.broadcast();
  final _seen = <String>{};
  final _subs = <StreamSubscription>[];

  @override
  void addTransport(Transport transport) {
    _transports.add(transport);
    final sub = transport.received.listen((event) {
      final (senderAddr, bytes) = event;
      try {
        final packet = _codec.decode(bytes);
        final key = '${packet.senderId}:${packet.nonce}';
        if (!_seen.contains(key)) {

          if (_seen.length >= 1000) {
            _seen.removeAll(_seen.take(500).toList());
          }
          _seen.add(key);

          transport.registerSender(packet.senderId, senderAddr);
          _incomingController.add(packet);
        }
      } catch (_) {

      }
    });
    _subs.add(sub);
  }

  @override
  void removeTransport(Transport transport) {
    final idx = _transports.indexOf(transport);
    if (idx >= 0) {
      _transports.removeAt(idx);
      _subs[idx].cancel();
      _subs.removeAt(idx);
    }
  }

  @override
  Future<void> route(Packet packet) async {
    final bytes = _codec.encode(packet);
    final recipientId = packet.recipientId;

    if (recipientId != null) {
      for (final transport in _transports) {
        if (transport.isConnected(recipientId) ||
            transport.knownPeers.contains(recipientId)) {
          await transport.send(recipientId, bytes);
          return;
        }
      }
    }

    for (final transport in _transports) {
      for (final nodeId in transport.knownPeers) {
        if (nodeId != packet.senderId) {
          try {
            await transport.send(nodeId, bytes);
          } catch (_) {}
        }
      }
    }
  }

  @override
  Stream<Packet> get incomingPackets => _incomingController.stream;

  @override
  String? nextHopFor(String destinationNodeId) {
    for (final transport in _transports) {
      if (transport.isConnected(destinationNodeId)) return destinationNodeId;
    }
    return null;
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _incomingController.close();
  }
}
