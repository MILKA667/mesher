package com.example.mesher.platform.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import java.util.UUID

/** Scans for BLE peers advertising the MeshLink service UUID. */
class BleScanner(
    private val context: Context,
    private val onPeer: (Map<String, Any>) -> Unit
) {
    companion object {
        val MESH_SERVICE_UUID: UUID = UUID.fromString("12345678-1234-1234-1234-1234567890ab")
        private const val TAG = "BleScanner"
    }

    private val manager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val adapter: BluetoothAdapter? get() = manager.adapter
    private var scanning = false

    // Cache of discovered devices keyed by nodeId for GATT connection.
    private val deviceMap = mutableMapOf<String, BluetoothDevice>()

    private val callback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val record = result.scanRecord ?: return
            // NodeId + nickname are in manufacturer data (company ID 0xFFFF)
            val mfgData = record.getManufacturerSpecificData(0xFFFF) ?: return
            if (mfgData.size < 8) return
            val nodeId = mfgData.take(8).joinToString("") { "%02X".format(it) }
            val nickname = if (mfgData.size > 8) {
                try { String(mfgData.sliceArray(8 until mfgData.size), Charsets.UTF_8) } catch (_: Exception) { "" }
            } else ""
            Log.d(TAG, "Peer found: nodeId=$nodeId nick=$nickname rssi=${result.rssi}")
            deviceMap[nodeId] = result.device
            onPeer(mapOf("nodeId" to nodeId, "rssi" to result.rssi, "nickname" to nickname))
        }

        override fun onScanFailed(errorCode: Int) {
            Log.e(TAG, "Scan failed, errorCode=$errorCode")
            scanning = false
        }
    }

    fun start() {
        if (scanning) return
        val ble = adapter?.bluetoothLeScanner ?: run {
            Log.e(TAG, "bluetoothLeScanner is null — permission missing or BLE off")
            return
        }
        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(MESH_SERVICE_UUID)).build()
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
        ble.startScan(listOf(filter), settings, callback)
        scanning = true
        Log.d(TAG, "Scan started")
    }

    fun stop() {
        if (!scanning) return
        adapter?.bluetoothLeScanner?.stopScan(callback)
        scanning = false
    }

    fun getDevice(nodeId: String): BluetoothDevice? = deviceMap[nodeId]

    /** Register a nodeId → device mapping from an incoming GATT connection so
     *  we can GATT-connect back to this peer without waiting for a scan result. */
    fun registerDevice(nodeId: String, mac: String) {
        if (deviceMap.containsKey(nodeId)) return
        val device = adapter?.getRemoteDevice(mac) ?: return
        deviceMap[nodeId] = device
        Log.d(TAG, "Registered peer $nodeId at $mac from incoming connection")
    }
}
