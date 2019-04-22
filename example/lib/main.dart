
import 'package:barcode_platform_view/barcode_scanner_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcode = "Ainda nao estou lendo";

  BarcodeScannerController scannerController;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    BarcodeScannerView scannerView = new BarcodeScannerView(
      onScannerCreated: onScannerCreated,
    );

    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Barcode Scanner View Example'),
          ),
          body: new Center(
            child: new Column(
              children: <Widget>[
                new Container(
                  child: scannerView,
                  height: 300,
                  padding: const EdgeInsets.all(8.0),
                ),
                new Text(barcode),
              ],
            ),
          )),
    );
  }

  void codeRead(String code){
    barcode = code;
    setState(() { });
    scannerController.startCamera();
  }

  void onScannerCreated(scannerController){
    this.scannerController = scannerController;
    this.scannerController.startCamera();
    this.scannerController.addBarcodeScannerReadCallback(codeRead);
  }

}
