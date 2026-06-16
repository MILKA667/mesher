package com.example.mesher.platform.voice

import android.annotation.SuppressLint
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

/**
 * Thin Kotlin bridge for low-latency voice capture/playback.
 *
 *  PCM 8 kHz mono 16-bit (16 KB/s) — fits within BLE GATT throughput on
 *  modern phones (typically 10–30 KB/s with a 512-byte MTU). Frame size is
 *  exposed via [SAMPLES_PER_FRAME] so Dart can read a constant number of
 *  bytes per packet.
 *
 *  Methods (MethodChannel `meshlink/voice`):
 *    - startCapture()     → start AudioRecord, push PCM frames via EventChannel
 *    - stopCapture()
 *    - startPlayback()    → start AudioTrack
 *    - stopPlayback()
 *    - playFrame(bytes)   → enqueue a raw PCM frame for playback
 *    - setSpeakerOn(bool) → toggle earpiece vs. loudspeaker
 *
 *  EventChannel `meshlink/voice/frames` emits ByteArray PCM frames as they
 *  arrive from the microphone.
 */
class VoiceChannel(
    private val context: Context,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val SAMPLE_RATE = 8000
        // 60 ms frame @ 8 kHz mono 16-bit = 960 bytes. Larger frames mean fewer
        // BLE writes per second (16.7 fps instead of 50 fps), which keeps audio
        // intelligible inside the practical BLE GATT throughput envelope.
        const val SAMPLES_PER_FRAME = 480
        private const val TAG = "VoiceChannel"
    }

    private val methodChannel = MethodChannel(messenger, "meshlink/voice")
    private val eventChannel = EventChannel(messenger, "meshlink/voice/frames")
    private val mainHandler = Handler(Looper.getMainLooper())

    private var recorder: AudioRecord? = null
    private var captureThread: Thread? = null
    @Volatile private var capturing = false

    private var aec: AcousticEchoCanceler? = null
    private var noiseSuppressor: NoiseSuppressor? = null

    private var track: AudioTrack? = null
    @Volatile private var playing = false

    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startCapture" -> { startCapture(); result.success(null) }
            "stopCapture"  -> { stopCapture();  result.success(null) }
            "startPlayback" -> { startPlayback(); result.success(null) }
            "stopPlayback"  -> { stopPlayback();  result.success(null) }
            "playFrame" -> {
                val bytes = call.arguments as? ByteArray
                if (bytes != null) playFrame(bytes)
                result.success(null)
            }
            "setSpeakerOn" -> {
                val on = call.arguments as? Boolean ?: false
                setSpeakerOn(on)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    @SuppressLint("MissingPermission")
    private fun startCapture() {
        if (capturing) return
        // Switch the audio system into voice-call mode BEFORE creating the
        // AudioRecord. Without this, MediaRecorder.AudioSource.VOICE_COMMUNICATION
        // sometimes opens with the wrong route and the mic stays silent.
        try {
            val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            am.mode = AudioManager.MODE_IN_COMMUNICATION
        } catch (_: Exception) {}
        val minBuf = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val bufSize = maxOf(minBuf, SAMPLES_PER_FRAME * 2 * 4)
        recorder = try {
            AudioRecord(
                MediaRecorder.AudioSource.VOICE_COMMUNICATION,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufSize
            )
        } catch (e: Exception) {
            Log.e(TAG, "AudioRecord init failed", e); return
        }

        val rec = recorder ?: return
        if (rec.state != AudioRecord.STATE_INITIALIZED) {
            Log.e(TAG, "AudioRecord not initialized"); return
        }

        // Hardware echo/noise suppression if available.
        if (AcousticEchoCanceler.isAvailable()) {
            aec = AcousticEchoCanceler.create(rec.audioSessionId)?.apply { enabled = true }
        }
        if (NoiseSuppressor.isAvailable()) {
            noiseSuppressor = NoiseSuppressor.create(rec.audioSessionId)?.apply { enabled = true }
        }

        rec.startRecording()
        capturing = true

        captureThread = thread(name = "VoiceCapture", isDaemon = true) {
            val buf = ShortArray(SAMPLES_PER_FRAME)
            while (capturing) {
                val n = rec.read(buf, 0, buf.size)
                if (n <= 0) continue
                val frame = ByteArray(n * 2)
                for (i in 0 until n) {
                    val v = buf[i].toInt()
                    frame[i * 2] = (v and 0xFF).toByte()
                    frame[i * 2 + 1] = ((v shr 8) and 0xFF).toByte()
                }
                mainHandler.post { eventSink?.success(frame) }
            }
        }
    }

    private fun stopCapture() {
        capturing = false
        try { captureThread?.join(300) } catch (_: Exception) {}
        captureThread = null
        try { recorder?.stop() } catch (_: Exception) {}
        recorder?.release()
        recorder = null
        aec?.release(); aec = null
        noiseSuppressor?.release(); noiseSuppressor = null
    }

    private fun startPlayback() {
        if (playing) return
        val minBuf = AudioTrack.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val bufSize = maxOf(minBuf, SAMPLES_PER_FRAME * 2 * 8) // ~160 ms jitter buffer
        track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(SAMPLE_RATE)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setTransferMode(AudioTrack.MODE_STREAM)
            .setBufferSizeInBytes(bufSize)
            .build()

        try {
            track?.play()
            playing = true
            setSpeakerOn(false) // default to earpiece
        } catch (e: Exception) {
            Log.e(TAG, "AudioTrack start failed", e)
        }
    }

    private fun stopPlayback() {
        playing = false
        try { track?.stop() } catch (_: Exception) {}
        track?.release()
        track = null
        try {
            val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            am.mode = AudioManager.MODE_NORMAL
            am.isSpeakerphoneOn = false
        } catch (_: Exception) {}
    }

    private fun playFrame(bytes: ByteArray) {
        val t = track ?: return
        if (!playing) return
        try {
            t.write(bytes, 0, bytes.size)
        } catch (_: Exception) {}
    }

    private fun setSpeakerOn(on: Boolean) {
        try {
            val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            am.mode = AudioManager.MODE_IN_COMMUNICATION
            am.isSpeakerphoneOn = on
        } catch (_: Exception) {}
    }

    fun dispose() {
        stopCapture()
        stopPlayback()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }
}
