package com.samar.webviewwithnotificationpermission

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.samar.webviewwithnotificationpermission.ui.theme.WebViewWithNotificationPermissionTheme
import java.io.BufferedReader
import java.io.InputStreamReader
import java.nio.charset.StandardCharsets
import android.Manifest
import android.os.Build
import android.os.Looper
import android.webkit.JavascriptInterface
import androidx.annotation.RequiresApi

class MainActivity : ComponentActivity() {
    private lateinit var requestPermissionLauncher: ActivityResultLauncher<String>
    private lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestPermissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestPermission()
        ) { isGranted: Boolean ->
            if (isGranted) {
                println("Notification permission granted (from Kotlin)")
                // Handle granted state in Kotlin
            } else {
                println("Notification permission denied (from Kotlin)")
                // Handle denied state in Kotlin
            }
        }
        enableEdgeToEdge()
        setContent {
            WebViewWithNotificationPermissionTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    LocalWebView()
                }
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    @Composable
    fun LocalWebView() {
        val context = LocalContext.current
        val htmlContent = remember {
            try {
                val inputStream = context.assets.open("NotificationPage.html")
                val reader = BufferedReader(InputStreamReader(inputStream, StandardCharsets.UTF_8))
                val stringBuilder = StringBuilder()
                var line: String? = reader.readLine()
                while (line != null) {
                    stringBuilder.append(line)
                    stringBuilder.append('\n')
                    line = reader.readLine()
                }
                stringBuilder.toString()
            } catch (e: Exception) {
                "<html><body><h1>Error loading local file</h1><p>${e.localizedMessage}</p></body></html>"
            }
        }

        AndroidView(
            factory = {
                WebView(it).apply {
                    webView = this
                    settings.javaScriptEnabled = true
                    webViewClient = WebViewClient()
                    addJavascriptInterface(WebAppInterface(), "Android") // Use WebAppInterface
                    loadDataWithBaseURL(
                        "file:///android_asset/",
                        htmlContent,
                        "text/html",
                        "UTF-8",
                        null
                    )
                }
            },
            update = { view ->
                view.loadDataWithBaseURL(
                    "file:///android_asset/",
                    htmlContent,
                    "text/html",
                    "UTF-8",
                    null
                )
            }
        )
    }

    inner class WebAppInterface {
        private val handler = android.os.Handler(Looper.getMainLooper()) // Use Handler

        @RequiresApi(Build.VERSION_CODES.TIRAMISU)
        @JavascriptInterface
        fun requestNotificationPermission() {
            handler.post { // Execute on the main thread
                if (ContextCompat.checkSelfPermission(
                        this@MainActivity,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    println("Notification permission already granted (from Kotlin)")
                    // Handle the case where permission is already granted
                } else {
                    requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }
            }
        }
    }
}