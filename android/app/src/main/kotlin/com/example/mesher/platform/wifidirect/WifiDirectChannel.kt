package com.example.mesher.platform.wifidirect

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WifiDirectChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "meshlink/wifidirect"
    }

    private val methodChannel    = MethodChannel(messenger, CHANNEL_NAME)
    private val peerEventChannel = EventChannel(messenger, "$CHANNEL_NAME/peers")
    private val rxEventChannel   = EventChannel(messenger, "$CHANNEL_NAME/rx")

    private var peerSink: EventChannel.EventSink? = null
    private var rxSink:   EventChannel.EventSink? = null

    // nodeIdBytes is set via the "setNodeId" method call before startScan.
    private var nodeIdBytes: ByteArray = ByteArray(8)

    private val manager by lazy {
        WifiDirectManager(
            context,
            nodeIdBytes,
            onPeer = { map -> peerSink?.success(map) },
            onReceive = { nodeId, data ->
                rxSink?.success(mapOf("nodeId" to nodeId, "data" to data))
            }
        )
    }

    init {
        methodChannel.setMethodCallHandler(this)

        peerEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) { peerSink = sink }
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
            "startScan"  -> { manager.startDiscovery(); result.success(null) }
            "stopScan"   -> { manager.stopDiscovery(); result.success(null) }
            "connect"    -> {
                val address = call.argument<String>("address")
                    ?: return result.error("ARG", "address missing", null)
                manager.connect(address) { ok ->
                    if (ok) result.success(null) else result.error("WIFI", "connect failed", null)
                }
            }
            "disconnect" -> {
                val address = call.argument<String>("address")
                    ?: return result.error("ARG", "address missing", null)
                manager.disconnect(address)
                result.success(null)
            }
            "send" -> {
                val nodeId = call.argument<String>("nodeId")
                    ?: return result.error("ARG", "nodeId missing", null)
                val data = call.argument<ByteArray>("data")
                    ?: return result.error("ARG", "data missing", null)
                manager.send(nodeId, data)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        manager.dispose()
    }
}
