package com.lua.barcode_platform_view

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

import io.flutter.plugin.common.PluginRegistry.Registrar

class BarcodeScanFactory(private val mPluginRegistrar: Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(p0: Context?, p1: Int, p2: Any?): PlatformView {
        return FlutterBarcodeScan(p0!!, mPluginRegistrar, p1)
    }
}