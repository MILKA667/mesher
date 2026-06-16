package com.example.mesher.platform.bluetooth

import android.bluetooth.*
import android.content.Context
import android.os.Handler
import android.os.Looper

/** GATT client: connects to a remote peer's GATT server and writes data to its RX characteristic. */
class BleGattClient(
    private val context: Context,
    private val device: BluetoothDevice,
    private val onConnected: () -> Unit,
    private val onDisconnected: () -> Unit,
) {
    private var gatt: BluetoothGatt? = null
    private var rxCharacteristic: BluetoothGattCharacteristic? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    var isConnected = false
        private set

    // Negotiated payload size (ATT MTU minus 3-byte ATT header). Default is conservative.
    private var chunkSize = 20

    // Write queue: each element is one chunk. pendingCallback is called when queue drains.
    private val writeQueue = ArrayDeque<ByteArray>()
    private var pendingCallback: ((Boolean) -> Unit)? = null

    private val callback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> gatt.discoverServices()
                BluetoothProfile.STATE_DISCONNECTED -> {
                    isConnected = false
                    mainHandler.post {
                        writeQueue.clear()
                        pendingCallback?.invoke(false)
                        pendingCallback = null
                        onDisconnected()
                    }
                }
            }
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status != BluetoothGatt.GATT_SUCCESS) { close(); return }
            val service = gatt.getService(BleGattServer.SERVICE_UUID)
            if (service == null) { close(); return }
            rxCharacteristic = service.getCharacteristic(BleGattServer.RX_CHAR_UUID)
            isConnected = true
            mainHandler.post { onConnected() }
            // Request larger MTU as a background optimization (does not block send).
            gatt.requestMtu(512)
        }

        override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                chunkSize = mtu - 3
            }
            // isConnected already set in onServicesDiscovered
        }

        override fun onCharacteristicWrite(
            gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, status: Int
        ) {
            mainHandler.post {
                if (status != BluetoothGatt.GATT_SUCCESS) {
                    writeQueue.clear()
                    pendingCallback?.invoke(false)
                    pendingCallback = null
                    return@post
                }
                writeQueue.removeFirstOrNull() // chunk confirmed sent
                if (writeQueue.isEmpty()) {
                    pendingCallback?.invoke(true)
                    pendingCallback = null
                } else {
                    drainWrite()
                }
            }
        }
    }

    fun connect() {
        gatt = device.connectGatt(context, false, callback, BluetoothDevice.TRANSPORT_LE)
    }

    /** Send [data], calling [callback] when all bytes are delivered (or on failure).
     *
     *  Wire format: [4-byte big-endian length][data bytes], then split into MTU chunks.
     *  The receiver reassembles chunks before handing the message to Flutter.
     */
    fun send(data: ByteArray, callback: (Boolean) -> Unit) {
        mainHandler.post {
            if (!isConnected || rxCharacteristic == null) { callback(false); return@post }
            // Prepend 4-byte big-endian length header (matches WifiDirectSocket framing).
            val len = data.size
            val framed = ByteArray(4 + len).also { buf ->
                buf[0] = (len shr 24).toByte()
                buf[1] = (len shr 16).toByte()
                buf[2] = (len shr 8).toByte()
                buf[3] = len.toByte()
                System.arraycopy(data, 0, buf, 4, len)
            }
            val chunkSz = chunkSize.coerceAtLeast(20)
            var offset = 0
            while (offset < framed.size) {
                writeQueue.add(framed.sliceArray(offset until minOf(offset + chunkSz, framed.size)))
                offset += chunkSz
            }
            pendingCallback = callback
            drainWrite()
        }
    }

    @Suppress("DEPRECATION")
    private fun drainWrite() {
        val chunk = writeQueue.firstOrNull() ?: return
        val char = rxCharacteristic ?: return
        char.value = chunk
        char.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
        gatt?.writeCharacteristic(char)
    }

    fun close() {
        isConnected = false
        gatt?.disconnect()
        gatt?.close()
        gatt = null
    }
}
