import 'packet.dart';
import 'packet_codec.dart';

abstract interface class MessageProtocol {
  Future<void> sendPacket(String nodeId, Packet packet);
  Stream<Packet> get incomingPackets;
  PacketCodec get codec;
}
