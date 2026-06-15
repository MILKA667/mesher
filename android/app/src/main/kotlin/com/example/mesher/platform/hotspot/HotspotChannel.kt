package com.example.mesher.platform.hotspot

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class HotspotChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "meshlink/hotspot"
    }

    private val methodChannel = MethodChannel(messenger, CHANNEL_NAME)
    private val rxEventChannel = EventChannel(messenger, "$CHANNEL_NAME/rx")

    private var rxSink: EventChannel.EventSink? = null

    private val server = HotspotServer(context) { nodeId, data ->
        rxSink?.success(mapOf("nodeId" to nodeId, "data" to data))
    }

    init {
        methodChannel.setMethodCallHandler(this)
        rxEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) { rxSink = sink }
            override fun onCancel(args: Any?) { rxSink = null }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startHotspot" -> { server.start(); result.success(null) }
            "stopHotspot"  -> { server.stop();  result.success(null) }
            "send"         -> {
                val nodeId = call.argument<String>("nodeId") ?: return result.error("ARG", "nodeId missing", null)
                val data   = call.argument<ByteArray>("data")  ?: return result.error("ARG", "data missing", null)
                server.send(nodeId, data)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        server.stop()
    }
}
