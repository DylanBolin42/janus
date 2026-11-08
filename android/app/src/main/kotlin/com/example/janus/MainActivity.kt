package com.example.janus

import android.app.Activity
import android.content.Intent
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var pendingImport: MethodChannel.Result? = null
    private val importRequest = 18427
    private val maxBytes = 20L * 1024 * 1024
    private class TooLarge : Exception()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "janus/storage_import")
            .setMethodCallHandler { call, result ->
                if (call.method != "pickJson") {
                    result.notImplemented()
                } else if (pendingImport != null) {
                    result.error("already_active", "A snapshot picker is already active", null)
                } else {
                    pendingImport = result
                    try {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "application/json"
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivityForResult(intent, importRequest)
                    } catch (error: Exception) {
                        pendingImport = null
                        result.error("picker_unavailable", error.message, null)
                    }
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != importRequest) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingImport ?: return
        if (resultCode != Activity.RESULT_OK) {
            pendingImport = null
            result.success(null)
            return
        }
        val uri = data?.data
        if (uri == null) {
            pendingImport = null
            result.error("unreadable", "No document was returned", null)
            return
        }
        Thread {
            var temporary: File? = null
            try {
                // Query metadata before opening/caching the provider stream.
                val declaredSize = try { contentResolver.query(uri, arrayOf(OpenableColumns.SIZE), null, null, null)?.use { cursor ->
                    val column = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (cursor.moveToFirst() && column >= 0 && !cursor.isNull(column)) cursor.getLong(column) else null
                } } catch (_: Exception) { null }
                if (declaredSize != null && declaredSize > maxBytes) throw TooLarge()
                val target = File.createTempFile("janus_import_", ".json", cacheDir)
                temporary = target
                var total = 0L
                val input = contentResolver.openInputStream(uri) ?: throw java.io.IOException("Document is unreadable")
                input.use { source ->
                    target.outputStream().use { output ->
                        val buffer = ByteArray(8192)
                        while (true) {
                            val count = source.read(buffer)
                            if (count < 0) break
                            total += count
                            if (total > maxBytes) throw TooLarge()
                            output.write(buffer, 0, count)
                        }
                    }
                }
                val copied = target
                runOnUiThread {
                    pendingImport = null
                    result.success(mapOf("path" to copied.absolutePath, "size" to total))
                }
            } catch (error: Exception) {
                temporary?.delete()
                val code = when (error) {
                    is TooLarge -> "too_large"
                    is SecurityException -> "permission_denied"
                    else -> "unreadable"
                }
                runOnUiThread {
                    pendingImport = null
                    result.error(code, error.message, null)
                }
            }
        }.start()
    }
}
