package com.dapi.androidsamplewebview

import android.net.Uri
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_webview.*
import java.util.HashMap

class WebViewActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_webview)


        // Initialize Connect URl
        val connectConfigurationLink = HashMap<String, String>()
        connectConfigurationLink.put("appKey" , "c1606405091dc6f0f0b9ab34dec5f9c404042bcef7ceafa4c2527074947cb5d0")
        connectConfigurationLink.put("environment", "sandbox")
        connectConfigurationLink.put("redirectUri", "https://google.com")
        connectConfigurationLink.put("baseUrl" , "https://connect.dapi.co")

        // Generate the Connect initialization URL based off of the configuration options.
        val connectUrl = generateConnectInitializationUrl(connectConfigurationLink)

        // Modify Webview settings - all of these settings may not be applicable or necessary for your integration.
        val webSettings = dapiwebview.settings
        webSettings.javaScriptEnabled = true
        webSettings.domStorageEnabled = true
        webSettings.cacheMode = WebSettings.LOAD_NO_CACHE
        WebView.setWebContentsDebuggingEnabled(true)

        // Override the Webview's handler for redirects
        // Connect communicates success and failure (analogous to the web's onSuccess and onFailure callbacks) via redirects.
        dapiwebview.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                // Parse the URL to determine if it's a special Connect redirect or a request
                // Handle connect redirects and open traditional pages directly in the user's
                // preferred browser.
                Log.d("ConnectLogs", url)
                val parsedUri = Uri.parse(url)

                if (parsedUri.scheme == "dapiconnect") {
                    val action = parsedUri.host
                    val data = parseConnectUriData(parsedUri)

                    if (action == "connected") {

                        //TODO take this access_code after successful connection and exchange it for an access_token

                        Log.d("ConnectLogs", " Access Code: $data['access_code']")

                        finish()
                    } else if (action == "exit") {
                        //TODO exit Webview when this is called and continue to app

                        finish()
                    } else if (action == "event") {

                        // The event action is fired as the user moves through the Dapi Connect
                        Log.d("ConnectLogs", "Event name: $data['event_name']")

                    } else if (action == "error") {

                        // The error action is fired wheneever an error happened
                        // either wrong configuration params or wrong username/password

                        Log.d("ConnectLogs", "Error Happened!")
                        Log.d("ConnectLogs", "Error type: $data['error_type']")
                        Log.d("ConnectLogs", "Error Message: $data['error_message'']")

                    } else {
                        Log.d("ConnectLogs ", action!!)
                    }
                    return true
                } else return parsedUri.scheme == "https" || parsedUri.scheme == "http"
            }
        }

        Log.d("ConnectLogs", "Connect URL: $connectUrl")

        dapiwebview.loadUrl(connectUrl.toString())

    }


    // Generate a Dapi Connect initialization URL based on a set of configuration options
    // You need to append isWebview and isMobile to render the connect in webview format
    fun generateConnectInitializationUrl(configurationOptions: HashMap<String, String>): Uri {
        val builder = Uri.parse(configurationOptions["baseUrl"])
            .buildUpon()
            .appendQueryParameter("isWebview", "true")
            .appendQueryParameter("isMobile", "true")
        for (key in configurationOptions.keys) {
            if (key != "baseUrl") {
                builder.appendQueryParameter(key, configurationOptions[key])
            }
        }
        return builder.build()
    }

    // Parse a Connect URL query string into a HashMap
    fun parseConnectUriData(uri: Uri): HashMap<String, String> {
        val data = HashMap<String, String>()
        for (key in uri.queryParameterNames) {
            if(!uri.getQueryParameter(key).isNullOrEmpty()){
                data.put(key, uri.getQueryParameter(key)!!)
            } else {
                data.put(key, "null")
            }

        }
        return data
    }
}