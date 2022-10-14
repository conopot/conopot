package com.soma.conopot

import com.example.conopot.ListTileNativeAdFactory
import com.google.android.ads.mediationtestsuite.MediationTestSuite
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mediationTestChannel"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // TODO: Register the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine, "listTile", ListTileNativeAdFactory(context))
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when 
                     {
            call.method == "launchMediationTestSuiteForAdMob" -> result.success(launchMediationTestSuiteForAdMob())
                      }
            }
    }

    fun launchMediationTestSuiteForAdMob() : Long{
            MediationTestSuite.launch(this, "ca-app-pub-7139143792782560~5110735880")
            return 1L;
        }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // TODO: Unregister the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }
}
