package com.lat.lat_hdr_transcoder

import android.content.Context
import android.media.MediaExtractor
import android.media.MediaFeature
import android.media.MediaFormat
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.FileProvider
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.transformer.*
import androidx.media3.transformer.TransformationRequest.HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_MEDIACODEC
import androidx.media3.transformer.TransformationRequest.HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_OPEN_GL
import androidx.media3.transformer.Transformer.PROGRESS_STATE_NOT_STARTED

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** LatHdrTranscoderPlugin */
class LatHdrTranscoderPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        const val TAG = "LatHdrTranscoderPlugin"
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private fun log(value: String) {
        Log.d(TAG, value)
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "lat_hdr_transcoder")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        log("${call.method}, ${call.arguments}")
        when (call.method) {
            "isHDR" -> {
                val path = call.argument<String?>("path")
                if (path == null) {
                    TranscodeErrorType.InvalidArgs.occurs(result)
                    return
                }

                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                    TranscodeErrorType.NotSupportVersion.occurs(result)
                    return
                }
                isHDR(path, result)
            }
            "transcode" -> {
                val path = call.argument<String?>("path")
                if (path == null) {
                    TranscodeErrorType.InvalidArgs.occurs(result)
                    return
                }
                transcoding(path, result)
            }
            else -> result.notImplemented()
        }
    }


    @RequiresApi(Build.VERSION_CODES.N)
    private fun isHDR(path: String, @NonNull result: Result) {
        val inputUri = uriFromFilePath(path)
        val item = MediaItem.fromUri(inputUri)

        val extractor = MediaExtractor()
        extractor.setDataSource(path)
        val trackLength = extractor.trackCount - 1;
        log("track count: $trackLength")

        var isHdr = false
        for (i in 0..trackLength) {
            val format = extractor.getTrackFormat(i)

            var colorStandard: Int = -1
            var colorTransfer: Int = -1
            if (format.containsKey(MediaFormat.KEY_COLOR_STANDARD)) {
                colorStandard = format.getInteger(MediaFormat.KEY_COLOR_STANDARD)
                log("color standard: result: $colorStandard == ${MediaFormat.COLOR_STANDARD_BT2020}")
            }

            if (format.containsKey(MediaFormat.KEY_COLOR_TRANSFER)) {
                colorTransfer = format.getInteger(MediaFormat.KEY_COLOR_TRANSFER)
                log("color transfer: result: $colorTransfer == ${MediaFormat.COLOR_TRANSFER_ST2084} || ${MediaFormat.COLOR_TRANSFER_HLG}")
            }

            if (colorStandard == MediaFormat.COLOR_STANDARD_BT2020 &&
                (colorTransfer == MediaFormat.COLOR_TRANSFER_ST2084 || colorTransfer == MediaFormat.COLOR_TRANSFER_HLG)
            ) {
                isHdr = true
                break
            }
        }

        result.success(isHdr)
    }

    private fun transcoding(path: String, @NonNull result: Result) {
        val inputUri = uriFromFilePath(path)
        val outputPath = createOutputPath(path)
        log("input: $path")
        log("output: $outputPath")
        deleteFile(outputPath)

        val request = TransformationRequest.Builder()
            .setVideoMimeType(MimeTypes.VIDEO_H264)
            .setHdrMode(hdrToneMap())
            .build()

        val transformerOnListener = object : Transformer.Listener {
            override fun onError(
                composition: Composition,
                exportResult: ExportResult,
                exportException: ExportException
            ) {
                log("${exportException.errorCode} ${exportException.errorCodeName}")
                TranscodeErrorType.FailedTranscode.occurs(result, exportException.errorCodeName)
            }

            override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                log("completed: $outputPath")
                result.success(outputPath)
            }
        }

        val transformer = Transformer.Builder(context)
            .setTransformationRequest(request)
            .addListener(transformerOnListener)
            .build()

        transformer.start(MediaItem.fromUri(inputUri), outputPath)

        var currentProgress = 0.0
        val progressHolder = ProgressHolder()
        val mainHandler = Handler(context.mainLooper)
        mainHandler.post(object : Runnable {
            override fun run() {
                val state = transformer.getProgress(progressHolder)
                if (state != PROGRESS_STATE_NOT_STARTED) {
                    val current = progressHolder.progress * 0.01
                    if (current != currentProgress) {
                        currentProgress = current
                        log("$currentProgress")
                    }
                    mainHandler.postDelayed(this,  /* delayMillis = */16)
                }
            }
        })

    }

    private fun hdrToneMap(): Int {
        return if (Build.VERSION.SDK_INT >= 33) {
            HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_MEDIACODEC
        } else {
            HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_OPEN_GL
        }
    }

    private fun createOutputPath(path: String): String {
        val uri = Uri.parse(path)
        val fileName = uri.lastPathSegment // 파일 이름 추출
        val newFileName =
            "${fileName?.substringBeforeLast(".")}_sdr.${fileName?.substringAfterLast(".")}"

        val tempDir = context.cacheDir
        val sdrDir = File(tempDir, "sdr")
        if (!sdrDir.exists()) {
            sdrDir.mkdir()
        }
        return sdrDir.absolutePath + "/" + newFileName
    }

    private fun deleteFile(path: String) {
        val file = File(path)
        file.exists().let {
            if (it) {
                file.delete()
            }
        }
    }

    private fun uriFromFilePath(path: String): Uri {
        return FileProvider.getUriForFile(context, context.packageName, File(path))
    }

}
