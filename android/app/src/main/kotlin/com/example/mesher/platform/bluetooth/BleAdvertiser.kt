package com.example.mesher.platform.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.ParcelUuid
import android.util.Log

class BleAdvertiser(private val context: Context) {

    companion object {
        private const val TAG = "BleAdvertiser"

        private const val MFG_ID = 0xFFFF
    }

    private val manager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val adapter: BluetoothAdapter? get() = manager.adapter
    private var advertising = false

    private val callback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            advertising = true
            Log.d(TAG, "Advertising started OK")
        }
        override fun onStartFailure(errorCode: Int) {
            advertising = false
            Log.e(TAG, "Advertising failed, errorCode=$errorCode")
        }
    }

    fun startAdvertising(nodeIdBytes: ByteArray, nickname: String) {
        if (advertising) return
        val bleAdvertiser = adapter?.bluetoothLeAdvertiser
        if (bleAdvertiser == null) {
            Log.e(TAG, "bluetoothLeAdvertiser is null — BLE advertising not supported or permission missing")
            return
        }
        val nicknameBytes = nickname.toByteArray(Charsets.UTF_8).let {
            if (it.size > 19) it.sliceArray(0 until 19) else it
        }
        val payload = nodeIdBytes + nicknameBytes

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()
        val advData = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .setIncludeTxPowerLevel(false)
            .addServiceUuid(ParcelUuid(BleScanner.MESH_SERVICE_UUID))
            .build()
        val scanResponse = AdvertiseData.Builder()
            .addManufacturerData(MFG_ID, payload)
            .build()
        Log.d(TAG, "Advertising nodeId=${nodeIdBytes.joinToString("") { "%02X".format(it) }} nick=$nickname")
        bleAdvertiser.startAdvertising(settings, advData, scanResponse, callback)
    }

    fun stopAdvertising() {
        if (!advertising) return
        adapter?.bluetoothLeAdvertiser?.stopAdvertising(callback)
        advertising = false
        Log.d(TAG, "Advertising stopped")
    }
}
