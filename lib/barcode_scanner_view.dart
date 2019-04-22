import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

typedef void BarcodeScannerControllerCodeReadCallback(String code);

class BarcodeScannerController{
  MethodChannel _channel;
  BarcodeScannerControllerCodeReadCallback _codeReadCallback;

  BarcodeScannerController.init(int id) {
    _channel = new MethodChannel('barcodescanner_$id');
    _channel.setMethodCallHandler((methodCall){
      switch(methodCall.method){
        case "permissionDenied":{
          break;
        }
        case "valueScanned":{
          var valueScanned = methodCall.arguments;
          print(valueScanned);
          if(_codeReadCallback != null) {
            _codeReadCallback(valueScanned);
          }
          break;
        }
      }
    });
  }

  void addBarcodeScannerReadCallback(BarcodeScannerControllerCodeReadCallback codeReadCallback){
    _codeReadCallback = codeReadCallback;
  }

  Future<void> startCamera() async => await _channel.invokeMethod('startCamera');
  Future<void> stopCamera() async => await _channel.invokeMethod('stopCamera');
}

typedef void BarcodeScannerViewCreatedCallback(
    BarcodeScannerController controller);


class BarcodeScannerView extends StatefulWidget {
  final BarcodeScannerViewCreatedCallback onScannerCreated;

  BarcodeScannerView({
    Key key,
    @required this.onScannerCreated,
  });

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScannerView> {
  @override
  Widget build(BuildContext context) {
    final TargetPlatform defaultTargetPlatform = Theme.of(context).platform;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'barcodescanner',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'barcodescanner',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return new Text(
        '$defaultTargetPlatform is not yet supported by this plugin');
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onScannerCreated == null){
      return;
    }
    widget.onScannerCreated(new BarcodeScannerController.init(id));
  }
}

