package com.example.mesher.platform.bluetooth

import android.bluetooth.*
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.io.ByteArrayOutputStream
import java.util.UUID
import java.util.concurrent.atomic.AtomicBoolean

class BleGattServer(
    private val context: Context,
    private val onReceive: (nodeId: String, data: ByteArray) -> Unit
) {
    companion object {
        val SERVICE_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-1234567890ab")
        val TX_CHAR_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-1234567890ac")
        val RX_CHAR_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-1234567890ad")
        private const val TAG = "BleGattServer"
    }

    private val btManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private var gattServer: BluetoothGattServer? = null
    private val clients = mutableMapOf<String, BleGattClient>()
    private val mainHandler = Handler(Looper.getMainLooper())

    private val receiveBuffers = mutableMapOf<String, ByteArrayOutputStream>()

    private val serverCallback = object : BluetoothGattServerCallback() {

        override fun onConnectionStateChange(
            device: BluetoothDevice, status: Int, newState: Int
        ) {
            if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                receiveBuffers.remove(device.address)
                Log.d(TAG, "Remote disconnected ${device.address}, buffer cleared")
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice, requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean, responseNeeded: Boolean,
            offset: Int, value: ByteArray
        ) {

            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
            if (characteristic.uuid != RX_CHAR_UUID || value.isEmpty()) return

            val addr = device.address
            val buf = receiveBuffers.getOrPut(addr) { ByteArrayOutputStream() }
            buf.write(value)
            val bytes = buf.toByteArray()

            var pos = 0
            while (pos + 4 <= bytes.size) {
                val msgLen = ((bytes[pos].toInt() and 0xFF) shl 24) or
                             ((bytes[pos + 1].toInt() and 0xFF) shl 16) or
                             ((bytes[pos + 2].toInt() and 0xFF) shl 8) or
                             (bytes[pos + 3].toInt() and 0xFF)
                if (msgLen <= 0 || msgLen > 1_000_000) {
                    Log.w(TAG, "Bad frame length $msgLen from $addr, clearing buffer")
                    buf.reset()
                    return
                }
                if (pos + 4 + msgLen > bytes.size) break
                val msg = bytes.copyOfRange(pos + 4, pos + 4 + msgLen)
                Log.d(TAG, "Reassembled ${msg.size} bytes from $addr")
                mainHandler.post { onReceive(addr, msg) }
                pos += 4 + msgLen
            }

            buf.reset()
            if (pos < bytes.size) buf.write(bytes, pos, bytes.size - pos)
        }
    }

    fun start() {
        val server = btManager.openGattServer(context, serverCallback) ?: return
        gattServer = server

        val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        val rxChar = BluetoothGattCharacteristic(
            RX_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )
        val txChar = BluetoothGattCharacteristic(
            TX_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        service.addCharacteristic(rxChar)
        service.addCharacteristic(txChar)
        server.addService(service)
    }

    fun connect(nodeId: String, device: BluetoothDevice, callback: (Boolean) -> Unit) {
        val existing = clients[nodeId]
        if (existing?.isConnected == true) { callback(true); return }
        Log.d(TAG, "Connecting GATT to $nodeId")
        val callbackOnce = AtomicBoolean(false)
        val client = BleGattClient(
            context, device,
            onConnected = {
                Log.d(TAG, "GATT connected to $nodeId")
                if (callbackOnce.compareAndSet(false, true)) callback(true)
            },
            onDisconnected = {
                Log.d(TAG, "GATT disconnected from $nodeId")
                clients.remove(nodeId)
                if (callbackOnce.compareAndSet(false, true)) callback(false)
            }
        )
        clients[nodeId] = client
        client.connect()
    }

    fun disconnect(nodeId: String) {
        clients.remove(nodeId)?.close()
    }

    fun send(nodeId: String, data: ByteArray, callback: (Boolean) -> Unit) {
        val client = clients[nodeId]
        if (client == null || !client.isConnected) {
            Log.e(TAG, "send to $nodeId failed — no GATT client (connected=${client?.isConnected})")
            callback(false); return
        }
        Log.d(TAG, "send to $nodeId ${data.size} bytes")
        client.send(data, callback)
    }

    fun dispose() {
        clients.values.forEach { it.close() }
        clients.clear()
        gattServer?.close()
        gattServer = null
    }
}
