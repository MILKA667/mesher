package com.example.mesher

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.mesher.platform.bluetooth.BluetoothChannel
import com.example.mesher.platform.wifidirect.WifiDirectChannel
import com.example.mesher.platform.hotspot.HotspotChannel
import com.example.mesher.platform.foreground.ForegroundChannel

class MainActivity : FlutterActivity() {

    private var bluetoothChannel: BluetoothChannel? = null
    private var wifiDirectChannel: WifiDirectChannel? = null
    private var hotspotChannel: HotspotChannel? = null
    private var foregroundChannel: ForegroundChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        bluetoothChannel  = BluetoothChannel(this, messenger)
        wifiDirectChannel = WifiDirectChannel(this, messenger)
        hotspotChannel    = HotspotChannel(this, messenger)
        foregroundChannel = ForegroundChannel(this, messenger)
        requestMeshPermissions()
    }

    private fun requestMeshPermissions() {
        val perms = mutableListOf<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            perms += Manifest.permission.BLUETOOTH_SCAN
            perms += Manifest.permission.BLUETOOTH_CONNECT
            perms += Manifest.permission.BLUETOOTH_ADVERTISE
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            perms += Manifest.permission.NEARBY_WIFI_DEVICES
            perms += Manifest.permission.POST_NOTIFICATIONS
        }

        // ACCESS_FINE_LOCATION needed for WiFi Direct on all Android versions
        perms += Manifest.permission.ACCESS_FINE_LOCATION
        perms += Manifest.permission.CAMERA
        perms += Manifest.permission.RECORD_AUDIO

        val needed = perms.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (needed.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needed.toTypedArray(), REQ_PERMISSIONS)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        bluetoothChannel?.dispose()
        wifiDirectChannel?.dispose()
        hotspotChannel?.dispose()
        foregroundChannel?.dispose()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        private const val REQ_PERMISSIONS = 1001
    }
}
