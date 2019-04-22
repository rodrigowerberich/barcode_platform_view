package com.lua.barcode_platform_view

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.view.View
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.zxing.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformView
import me.dm7.barcodescanner.zxing.ZXingScannerView

class FlutterBarcodeScan @SuppressLint("SetJavaScriptEnabled")
internal constructor(internal var context: Context, internal var registrar: Registrar, id: Int) : PlatformView, MethodCallHandler, ZXingScannerView.ResultHandler, PluginRegistry.RequestPermissionsResultListener {

    private var scannerView: me.dm7.barcodescanner.zxing.ZXingScannerView
    private var channel: MethodChannel
    private var result = ""

    companion object {
        val REQUEST_TAKE_PHOTO_CAMERA_PERMISSION = 100
    }

    init {
        scannerView = getScannerView(registrar)

        channel = MethodChannel(registrar.messenger(), "barcodescanner_$id")

        channel.setMethodCallHandler(this)

        registrar.addRequestPermissionsResultListener(this);

    }

    override fun getView(): View {
        return scannerView
    }

    override fun dispose() {}

    private fun startCamera() {
        scannerView.setResultHandler(this)
        if (!requestCameraAccessIfNecessary()) {
            scannerView.startCamera()
        }
    }

    private fun stopCamera() {
        scannerView.stopCamera()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startCamera" -> {
                startCamera()
                result.success(null)
            }
            "stopCamera" -> {
                stopCamera()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun handleResult(rawResult: Result?) {
        result = rawResult.toString()
        channel.invokeMethod("valueScanned", result)
    }

    private fun getScannerView(registrar: Registrar): me.dm7.barcodescanner.zxing.ZXingScannerView {
        val scannerView = ZXingScannerView(registrar.context())
        scannerView.setAutoFocus(true)
        scannerView.setAspectTolerance(0.5f)
        return scannerView
    }

    private fun requestCameraAccessIfNecessary(): Boolean {
        val array = arrayOf(Manifest.permission.CAMERA)
        if (ContextCompat
                        .checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {

            ActivityCompat.requestPermissions(registrar.activity(), array,
                    REQUEST_TAKE_PHOTO_CAMERA_PERMISSION)
            return true
        }
        return false
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,grantResults: IntArray): Boolean {
        when (requestCode) {
            REQUEST_TAKE_PHOTO_CAMERA_PERMISSION -> {
                if (PermissionUtil.verifyPermissions(grantResults)) {
                    scannerView.startCamera()
                    return true
                }
                else {
                    channel.invokeMethod("permissionDenied", null)
                }
            }
        }
        return false
    }

}

object PermissionUtil {

    /**
     * Check that all given permissions have been granted by verifying that each entry in the
     * given array is of the value [PackageManager.PERMISSION_GRANTED].

     * @see Activity.onRequestPermissionsResult
     */
    fun verifyPermissions(grantResults: IntArray): Boolean {
        // At least one result must be checked.
        if (grantResults.size < 1) {
            return false
        }

        // Verify that each required permission has been granted, otherwise return false.
        for (result in grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                return false
            }
        }
        return true
    }
}