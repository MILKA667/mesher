package com.example.mesher.platform.wifidirect

import java.io.OutputStream
import java.net.Socket
import kotlin.concurrent.thread

/**
 * TCP socket wrapping a WiFi Direct connection.
 * Used by the non-GO device to talk to the group owner's WifiDirectServer.
 */
class WifiDirectSocket(
    private val socket: Socket,
    private val nodeIdBytes: ByteArray,    // our 8-byte node ID
    private val onReceive: (data: ByteArray) -> Unit
) {
    private val out: OutputStream = socket.getOutputStream()
    @Volatile var isOpen = true
        private set

    init {
        // Send our node ID as the first 8 bytes so the server can register us.
        try {
            out.write(nodeIdBytes.take(8).toByteArray())
            out.flush()
        } catch (_: Exception) { isOpen = false }
        // Start read loop
        thread(isDaemon = true, name = "wifidirect-socket-rx") {
            try {
                val input = socket.getInputStream()
                val lenBuf = ByteArray(4)
                while (isOpen && !socket.isClosed) {
                    if (input.read(lenBuf) != 4) break
                    val len = ((lenBuf[0].toInt() and 0xFF) shl 24) or
                              ((lenBuf[1].toInt() and 0xFF) shl 16) or
                              ((lenBuf[2].toInt() and 0xFF) shl 8) or
                              (lenBuf[3].toInt() and 0xFF)
                    if (len <= 0 || len > 4_000_000) break
                    val data = ByteArray(len)
                    var got = 0
                    while (got < len) {
                        val n = input.read(data, got, len - got)
                        if (n < 0) break
                        got += n
                    }
                    onReceive(data)
                }
            } catch (_: Exception) {
            } finally {
                isOpen = false
            }
        }
    }

    fun send(data: ByteArray) {
        if (!isOpen) return
        try {
            val lenBytes = byteArrayOf(
                (data.size shr 24).toByte(),
                (data.size shr 16).toByte(),
                (data.size shr 8).toByte(),
                data.size.toByte()
            )
            synchronized(out) {
                out.write(lenBytes)
                out.write(data)
                out.flush()
            }
        } catch (_: Exception) { isOpen = false }
    }

    fun close() {
        isOpen = false
        try { socket.close() } catch (_: Exception) {}
    }
}
