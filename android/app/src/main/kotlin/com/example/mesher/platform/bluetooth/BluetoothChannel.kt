package com.example.mesher.platform.bluetooth

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BluetoothChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "meshlink/bluetooth"
    }

    private val methodChannel    = MethodChannel(messenger, CHANNEL_NAME)
    private val peerEventChannel = EventChannel(messenger, "$CHANNEL_NAME/peers")
    private val rxEventChannel   = EventChannel(messenger, "$CHANNEL_NAME/rx")

    private var peerSink: EventChannel.EventSink? = null
    private var rxSink:   EventChannel.EventSink? = null

    private var nodeIdBytes: ByteArray = ByteArray(8)
    private var nickname: String = ""

    private val scanner    = BleScanner(context) { map -> peerSink?.success(map) }
    private val advertiser = BleAdvertiser(context)
    private val gattServer = BleGattServer(context) { nodeId, data ->
        rxSink?.success(mapOf("nodeId" to nodeId, "data" to data))
    }

    init {
        methodChannel.setMethodCallHandler(this)

        peerEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                peerSink = sink
                gattServer.start()
            }
            override fun onCancel(args: Any?) { peerSink = null }
        })

        rxEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) { rxSink = sink }
            override fun onCancel(args: Any?) { rxSink = null }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setNodeId" -> {
                nodeIdBytes = call.argument<ByteArray>("nodeIdBytes") ?: ByteArray(8)
                result.success(null)
            }
            "setProfile" -> {
                nodeIdBytes = call.argument<ByteArray>("nodeIdBytes") ?: ByteArray(8)
                nickname = call.argument<String>("nickname") ?: ""
                result.success(null)
            }
            "startScan" -> {
                scanner.start()
                advertiser.startAdvertising(nodeIdBytes, nickname)
                result.success(null)
            }
            "stopScan" -> {
                scanner.stop()
                advertiser.stopAdvertising()
                result.success(null)
            }
            "connect" -> {
                val nodeId = call.argument<String>("nodeId")
                    ?: return result.error("ARG", "nodeId missing", null)
                val device = scanner.getDevice(nodeId)
                    ?: return result.error("BT", "device not yet discovered (scan first)", null)
                gattServer.connect(nodeId, device) { ok ->
                    if (ok) result.success(null)
                    else result.error("BT", "GATT connect failed", null)
                }
            }
            "disconnect" -> {
                val nodeId = call.argument<String>("nodeId")
                    ?: return result.error("ARG", "nodeId missing", null)
                gattServer.disconnect(nodeId)
                result.success(null)
            }
            "send" -> {
                val nodeId = call.argument<String>("nodeId")
                    ?: return result.error("ARG", "nodeId missing", null)
                val data = call.argument<ByteArray>("data")
                    ?: return result.error("ARG", "data missing", null)
                gattServer.send(nodeId, data) { ok ->
                    if (ok) result.success(null)
                    else result.error("BT", "send failed — not connected", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        scanner.stop()
        advertiser.stopAdvertising()
        gattServer.dispose()
    }
}
