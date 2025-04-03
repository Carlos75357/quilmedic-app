package com.example.quilmedic

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception

// Import Datalogic SDK classes if available
// If these imports fail, the plugin will gracefully fall back to keyboard mode
// import com.datalogic.decode.BarcodeManager
// import com.datalogic.decode.DecodeException
// import com.datalogic.decode.ReadListener
// import com.datalogic.decode.configuration.ScannerProperties
// import com.datalogic.device.ErrorManager

class DatalogicScannerPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    
    // Datalogic SDK objects
    private var barcodeManager: Any? = null
    private var readListener: Any? = null
    private var isDatalogicAvailable = false

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.quilmedic/datalogic_scanner")
        channel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.quilmedic/datalogic_scanner_events")
        eventChannel.setStreamHandler(this)
        
        // Check if Datalogic SDK is available
        try {
            val datalogicClass = Class.forName("com.datalogic.decode.BarcodeManager")
            isDatalogicAvailable = true
            Log.d("DatalogicScanner", "Datalogic SDK is available")
        } catch (e: Exception) {
            isDatalogicAvailable = false
            Log.d("DatalogicScanner", "Datalogic SDK is not available: ${e.message}")
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isDatalogicScannerAvailable" -> {
                result.success(isDatalogicAvailable)
            }
            "initScanner" -> {
                if (isDatalogicAvailable) {
                    try {
                        initDatalogicScanner()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", "Failed to initialize scanner: ${e.message}", null)
                    }
                } else {
                    result.error("NOT_AVAILABLE", "Datalogic SDK is not available", null)
                }
            }
            "disposeScanner" -> {
                if (isDatalogicAvailable) {
                    try {
                        disposeDatalogicScanner()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("DISPOSE_ERROR", "Failed to dispose scanner: ${e.message}", null)
                    }
                } else {
                    result.success(false)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initDatalogicScanner() {
        if (!isDatalogicAvailable) return
        
        try {
            // Use reflection to create BarcodeManager and ReadListener
            // This allows the code to compile even if Datalogic SDK is not available
            val barcodeManagerClass = Class.forName("com.datalogic.decode.BarcodeManager")
            barcodeManager = barcodeManagerClass.getConstructor(Context::class.java).newInstance(context)
            
            // Create ReadListener using anonymous class
            val readListenerClass = Class.forName("com.datalogic.decode.ReadListener")
            val readListenerImpl = object : java.lang.Object(), java.lang.reflect.InvocationHandler {
                override fun invoke(proxy: Any, method: java.lang.reflect.Method, args: Array<out Any>?): Any? {
                    if (method.name == "onRead") {
                        val barcodeData = args?.get(0)
                        // Extract barcode text using reflection
                        val getText = barcodeData?.javaClass?.getMethod("getText")
                        val barcodeText = getText?.invoke(barcodeData) as? String
                        
                        if (barcodeText != null) {
                            eventSink?.success(barcodeText)
                        }
                    }
                    return null
                }
            }
            
            readListener = java.lang.reflect.Proxy.newProxyInstance(
                readListenerClass.classLoader,
                arrayOf(readListenerClass),
                readListenerImpl
            )
            
            // Add the listener to the barcode manager
            val addMethod = barcodeManagerClass.getMethod("addReadListener", readListenerClass)
            addMethod.invoke(barcodeManager, readListener)
            
            Log.d("DatalogicScanner", "Datalogic scanner initialized successfully")
        } catch (e: Exception) {
            Log.e("DatalogicScanner", "Error initializing Datalogic scanner: ${e.message}")
            throw e
        }
    }

    private fun disposeDatalogicScanner() {
        if (!isDatalogicAvailable || barcodeManager == null || readListener == null) return
        
        try {
            // Remove the listener from the barcode manager
            val barcodeManagerClass = barcodeManager?.javaClass
            val readListenerClass = Class.forName("com.datalogic.decode.ReadListener")
            val removeMethod = barcodeManagerClass?.getMethod("removeReadListener", readListenerClass)
            removeMethod?.invoke(barcodeManager, readListener)
            
            barcodeManager = null
            readListener = null
            
            Log.d("DatalogicScanner", "Datalogic scanner disposed successfully")
        } catch (e: Exception) {
            Log.e("DatalogicScanner", "Error disposing Datalogic scanner: ${e.message}")
            throw e
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        disposeDatalogicScanner()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
