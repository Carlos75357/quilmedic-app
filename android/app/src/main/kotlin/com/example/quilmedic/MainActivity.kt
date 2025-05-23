package com.example.quilmedic

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register the Datalogic scanner plugin
        flutterEngine.plugins.add(DatalogicScannerPlugin())
    }
}
