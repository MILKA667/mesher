package com.example.mesher.platform.wifidirect

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.NetworkInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.WifiP2pManager.ActionListener
import java.net.Socket
import kotlin.concurrent.thread

/** Thin wrapper over WifiP2pManager. Dart logic owns everything above the socket layer. */
class WifiDirectManager(
    private val context: Context,
    private val nodeIdBytes: ByteArray,           // our 8-byte node ID for handshake
    private val onPeer: (Map<String, Any>) -> Unit,
    private val onReceive: (nodeId: String, data: ByteArray) -> Unit
) {
    private val p2pManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    private val channel = p2pManager.initialize(context, context.mainLooper, null)

    // TCP server (used when we are the group owner).
    private val server = WifiDirectServer { nodeId, data -> onReceive(nodeId, data) }

    // Outgoing sockets keyed by nodeId (non-GO device to GO).
    private val sockets = mutableMapOf<String, WifiDirectSocket>()

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context, intent: Intent) {
            when (intent.action) {
                WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> requestPeerList()
                WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                    @Suppress("DEPRECATION")
                    val networkInfo = intent.getParcelableExtra<NetworkInfo>(
                        WifiP2pManager.EXTRA_NETWORK_INFO
                    )
                    if (networkInfo?.isConnected == true) {
                        p2pManager.requestConnectionInfo(channel) { info ->
                            if (info.groupFormed) {
                                if (info.isGroupOwner) {
                                    server.start()
                                } else {
                                    val goIp = info.groupOwnerAddress?.hostAddress ?: return@requestConnectionInfo
                                    connectToGroupOwner(goIp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private val intentFilter = IntentFilter().apply {
        addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
        addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
        addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
        addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
    }

    init {
        context.registerReceiver(receiver, intentFilter)
    }

    fun startDiscovery() {
        p2pManager.discoverPeers(channel, object : ActionListener {
            override fun onSuccess() {}
            override fun onFailure(reason: Int) {}
        })
    }

    fun stopDiscovery() {
        p2pManager.stopPeerDiscovery(channel, object : ActionListener {
            override fun onSuccess() {}
            override fun onFailure(reason: Int) {}
        })
    }

    private fun requestPeerList() {
        p2pManager.requestPeers(channel) { deviceList ->
            for (device in deviceList.deviceList) reportDevice(device)
        }
    }

    private fun reportDevice(device: WifiP2pDevice) {
        // nodeId is encoded as the device name in our BLE advertisement.
        onPeer(mapOf("nodeId" to device.deviceName, "address" to device.deviceAddress))
    }

    fun connect(deviceAddress: String, callback: (Boolean) -> Unit) {
        val config = WifiP2pConfig().apply { this.deviceAddress = deviceAddress }
        p2pManager.connect(channel, config, object : ActionListener {
            override fun onSuccess() { callback(true) }
            override fun onFailure(reason: Int) { callback(false) }
        })
    }

    private fun connectToGroupOwner(goIp: String) {
        thread(isDaemon = true, name = "wifidirect-go-connect") {
            try {
                val socket = Socket(goIp, WifiDirectServer.PORT)
                val ws = WifiDirectSocket(socket, nodeIdBytes) { data ->
                    // The server sends nodeId-prefixed frames; extract or use "GO" as placeholder.
                    onReceive("GO", data)
                }
                sockets["GO"] = ws
            } catch (_: Exception) {}
        }
    }

    fun disconnect(deviceAddress: String) {
        sockets.remove(deviceAddress)?.close()
        p2pManager.removeGroup(channel, object : ActionListener {
            override fun onSuccess() {}
            override fun onFailure(reason: Int) {}
        })
    }

    fun send(nodeId: String, data: ByteArray) {
        // Try direct socket (non-GO → GO path).
        val sock = sockets[nodeId] ?: sockets["GO"]
        if (sock != null) { sock.send(data); return }
        // Group owner path: forward via TCP server.
        server.send(nodeId, data)
    }

    fun dispose() {
        context.unregisterReceiver(receiver)
        sockets.values.forEach { it.close() }
        sockets.clear()
        server.stop()
    }
}
