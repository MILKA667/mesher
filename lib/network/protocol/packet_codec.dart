import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'packet.dart';

abstract interface class PacketCodec {
  List<int> encode(Packet packet);
  Packet decode(List<int> bytes);
}

/// CBOR wire format: [typeIndex, senderId, recipientId|null, nonce, payload]
class CborPacketCodec implements PacketCodec {
  @override
  List<int> encode(Packet p) {
    final value = CborList([
      CborSmallInt(p.type.index),
      CborString(p.senderId),
      p.recipientId != null ? CborString(p.recipientId!) : const CborNull(),
      CborSmallInt(p.nonce),
      CborBytes(Uint8List.fromList(p.payload)),
    ]);
    return cbor.encode(value);
  }

  @override
  Packet decode(List<int> bytes) {
    final value = cbor.decode(bytes) as CborList;
    return Packet(
      type: PacketType.values[(value[0] as CborSmallInt).value],
      senderId: (value[1] as CborString).toString(),
      recipientId: value[2] is CborNull ? null : (value[2] as CborString).toString(),
      nonce: (value[3] as CborSmallInt).value,
      payload: List<int>.from((value[4] as CborBytes).bytes),
    );
  }
}
