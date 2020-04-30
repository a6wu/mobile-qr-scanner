import 'package:backtoschool/data_provider/barcode_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: QRView(
            key: qrKey,
            onQRViewCreated:
                Provider.of<BarcodeDataProvider>(context, listen: false)
                    .onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          flex: 4,
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Provider.of<BarcodeDataProvider>(context)
                      .qrText
                      .isNotEmpty
                  ? <Widget>[
                      Text(Provider.of<BarcodeDataProvider>(context).qrText),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(8.0),
                            child: FlatButton(
                              onPressed: () => Provider.of<BarcodeDataProvider>(
                                      context,
                                      listen: false)
                                  .submitBarcode(),
                              child: Text(
                                  Provider.of<BarcodeDataProvider>(context)
                                      .submitState,
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ],
                      ),
                    ]
                  : <Widget>[Text("Please scan a test kit.")],
            ),
          ),
          flex: 1,
        )
      ],
    );
  }

  @override
  void dispose() {
    Provider.of<BarcodeDataProvider>(context).dispose();
    super.dispose();
  }
}
