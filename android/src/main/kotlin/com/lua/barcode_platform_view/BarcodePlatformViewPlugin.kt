package com.lua.barcode_platform_view

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

object BarcodePlatformViewPlugin {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "barcodescanner", BarcodeScanFactory(registrar))
    }
}