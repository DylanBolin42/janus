package com.example.janus

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    private val alias = "janus.sync.credentials.v1"

    private fun key(): SecretKey {
        val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (store.getKey(alias, null) as? SecretKey)?.let { return it }
        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
            init(KeyGenParameterSpec.Builder(alias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
        }.generateKey()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "janus/sync_credentials")
            .setMethodCallHandler { call, result ->
                try {
                    // Excluded from Android backup: ciphertext cannot outlive its device key.
                    val file = File(noBackupFilesDir, "sync-credentials")
                    when (call.method) {
                        "read" -> {
                            if (!file.exists()) result.success(null)
                            else {
                                val parts = file.readText().split(":")
                                val cipher = Cipher.getInstance("AES/GCM/NoPadding")
                                cipher.init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128,
                                    Base64.decode(parts[0], Base64.NO_WRAP)))
                                result.success(String(cipher.doFinal(Base64.decode(parts[1],
                                    Base64.NO_WRAP)), Charsets.UTF_8))
                            }
                        }
                        "write" -> {
                            val value = call.arguments as String
                            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
                            cipher.init(Cipher.ENCRYPT_MODE, key())
                            val encoded = Base64.encodeToString(cipher.iv, Base64.NO_WRAP) + ":" +
                                Base64.encodeToString(cipher.doFinal(value.toByteArray(Charsets.UTF_8)),
                                    Base64.NO_WRAP)
                            val temporary = File(noBackupFilesDir, "sync-credentials.tmp")
                            temporary.writeText(encoded)
                            check(temporary.renameTo(file))
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (_: Exception) {
                    // Never send exception details, plaintext or credentials over error messages.
                    result.error("secure_storage", "Secure credential storage failed", null)
                }
            }
    }
}
