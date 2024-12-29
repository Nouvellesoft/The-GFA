package com.nouvellesoft.thegfa

import android.os.Bundle
import android.view.ViewGroup
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Install the splash screen
        installSplashScreen()
        super.onCreate(savedInstanceState)

        // Initialize the splash screen
        val splashView = SplashView(this)
        val splashViewInstance = splashView.createSplashView()
        addContentView(splashViewInstance, ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ))

        splashView.transitionToFlutter {
            // Your logic after splash screen transition
            runOnUiThread {
                (splashViewInstance.parent as ViewGroup).removeView(splashViewInstance)
                // Transition to Flutter UI is automatically handled
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("demo_native_view", DemoNativeViewFactory())
    }
}