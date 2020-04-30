import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/services/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import '../constants.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  var qrText = "";
  var submitState = submit_btn_inactive;
  var cameraState = front_camera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  UserDataProvider _userDataProvider;
  int timeScanned;

  @override
  void didChangeDependencies() {
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
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
              children: qrText.isNotEmpty
                  ? <Widget>[
                      Text("$qrText"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(8.0),
                            child: FlatButton(
                              onPressed: () {
                                if (controller != null) {
                                  if (_isSubmitActive(submitState)) {
                                    // state should reset only after
                                    // POST to API returns as success or failure

                                  } else {
                                    setState(() {
                                      // ... Sending
                                      submitState = submit_btn_active;
                                      submitBarcode(qrText);
                                    });
                                  }
                                }
                              },
                              child: Text(submitState,
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

  Future<Map<String, dynamic>> createData() async {
    final pattern = RegExp('[BGJMU]');
    var pid;
    if (_userDataProvider.authenticationModel.ucsdaffiliation
        .contains(pattern)) {
      pid = _userDataProvider.authenticationModel.pid;
    }
    return {
      'userId': await _userDataProvider.getUsernameFromDevice(),
      'barcode': qrText,
      'uscdaffiliation': _userDataProvider.authenticationModel.ucsdaffiliation,
      'scannedDate': timeScanned,
      'pid': pid
    };
  }

  submitBarcode(qrText) async {
    var barcodeService = BarcodeService();
    var tempData = await createData();
    print(tempData);
    var results = await barcodeService
        .uploadResults({"Content-Type": "application/json"}, tempData);

    if (results) {
      setState(() {
        submitState = "Received";
      });
    } else {
      setState(() {
        submitState = "Try again";
      });
    }
  }

  _isSubmitActive(String current) {
    return submit_btn_active == current;
  }

  _isBackCamera(String current) {
    return back_camera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        timeScanned = DateTime.now().millisecondsSinceEpoch;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
