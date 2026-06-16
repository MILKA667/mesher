package com.example.mesher

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.mesher.platform.bluetooth.BluetoothChannel
import com.example.mesher.platform.foreground.ForegroundChannel
import com.example.mesher.platform.voice.VoiceChannel

class MainActivity : FlutterActivity() {

    private var bluetoothChannel: BluetoothChannel? = null
    private var foregroundChannel: ForegroundChannel? = null
    private var voiceChannel: VoiceChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        bluetoothChannel  = BluetoothChannel(this, messenger)
        foregroundChannel = ForegroundChannel(this, messenger)
        voiceChannel      = VoiceChannel(this, messenger)
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
            perms += Manifest.permission.POST_NOTIFICATIONS
        }

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
        foregroundChannel?.dispose()
        voiceChannel?.dispose()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        private const val REQ_PERMISSIONS = 1001
    }
}
