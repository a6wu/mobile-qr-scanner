import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:http/http.dart' as http;
import 'package:backtoschool/app_theme.dart';

void main() => runApp(TabBarApp());

const submit_btn_active = " ... Sending";
const submit_btn_inactive = "Submit";

const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

class TabBarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: ColorPrimary,
        accentColor: lightAccentColor,
        brightness: Brightness.light,
        buttonColor: lightButtonColor,
        textTheme: lightThemeText,
        iconTheme: lightIconTheme,
        appBarTheme: lightAppBarTheme,
      ),
      darkTheme: ThemeData(
        primarySwatch: ColorPrimary,
        accentColor: darkAccentColor,
        brightness: Brightness.dark,
        buttonColor: darkButtonColor,
        textTheme: darkThemeText,
        iconTheme: darkIconTheme,
        appBarTheme: darkAppBarTheme,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.message)),
              ],
            ),
            title: Center(child: Text('Back to UCSD')),
          ),
          body: TabBarView(
            children: [
              QRViewExample(),
              Icon(Icons.directions_transit),
            ],
          ),
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                children: qrText.isNotEmpty ? <Widget>[
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
                                  submitBarcode();
                                });
                              }
                            }
                          },
                          child:
                              Text(submitState, style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ] : <Widget>[Text("Please scan a test kit.")],
              ),
            ),
            flex: 1,
          )
        ],
      ),
    );
  }

  submitBarcode() async {
    var url =
        'https://s8htpmldd3.execute-api.us-west-2.amazonaws.com/dev/barcode';
    var response = await http.post(url);
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
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
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
