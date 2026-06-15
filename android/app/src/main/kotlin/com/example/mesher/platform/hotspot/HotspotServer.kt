package com.example.mesher.platform.hotspot

import android.content.Context
import java.io.InputStream
import java.net.ServerSocket
import java.net.Socket
import kotlin.concurrent.thread

/**
 * TCP server listening on :7890 when this device is the hotspot AP.
 * Clients (peers connected to the hotspot) connect here to exchange data.
 */
class HotspotServer(
    private val context: Context,
    private val onReceive: (nodeId: String, data: ByteArray) -> Unit
) {
    companion object { const val PORT = 7890 }

    private var serverSocket: ServerSocket? = null
    private val clients = mutableMapOf<String, Socket>()
    private var running = false

    fun start() {
        if (running) return
        running = true
        thread(isDaemon = true) {
            try {
                val ss = ServerSocket(PORT).also { serverSocket = it }
                while (running) {
                    val client = ss.accept()
                    handleClient(client)
                }
            } catch (_: Exception) {}
        }
    }

    private fun handleClient(socket: Socket) {
        thread(isDaemon = true) {
            try {
                val input: InputStream = socket.getInputStream()
                // First 8 bytes = nodeId
                val idBuf = ByteArray(8)
                input.read(idBuf)
                val nodeId = idBuf.joinToString("") { "%02X".format(it) }
                clients[nodeId] = socket
                // Read length-prefixed frames
                val lenBuf = ByteArray(4)
                while (running && !socket.isClosed) {
                    if (input.read(lenBuf) != 4) break
                    val len = ((lenBuf[0].toInt() and 0xFF) shl 24) or
                              ((lenBuf[1].toInt() and 0xFF) shl 16) or
                              ((lenBuf[2].toInt() and 0xFF) shl 8) or
                              (lenBuf[3].toInt() and 0xFF)
                    val data = ByteArray(len)
                    input.read(data)
                    onReceive(nodeId, data)
                }
            } catch (_: Exception) {} finally {
                try { socket.close() } catch (_: Exception) {}
            }
        }
    }

    fun send(nodeId: String, data: ByteArray) {
        val socket = clients[nodeId] ?: return
        try {
            val out = socket.getOutputStream()
            val lenBytes = byteArrayOf(
                (data.size shr 24).toByte(), (data.size shr 16).toByte(),
                (data.size shr 8).toByte(), data.size.toByte()
            )
            out.write(lenBytes)
            out.write(data)
            out.flush()
        } catch (_: Exception) {}
    }

    fun stop() {
        running = false
        clients.values.forEach { try { it.close() } catch (_: Exception) {} }
        clients.clear()
        try { serverSocket?.close() } catch (_: Exception) {}
        serverSocket = null
    }
}
