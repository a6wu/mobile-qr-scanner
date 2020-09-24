import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/services/barcode_service.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../constants.dart';

class BarcodeDataProvider extends ChangeNotifier {
  BarcodeDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _barcodeService = BarcodeService();
    _cameraState = front_camera;
    _submitState = submit_btn_active;
    _qrText = "";
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  String _qrText;

  int _timeScanned;
  String _cameraState;
  String _submitState;

  ///MODELS
  UserDataProvider _userDataProvider;
  BarcodeScanner _controller;

  ///SERVICES
  BarcodeService _barcodeService;

  var ucsdAffiliation = "";
  var accessToken = "";
  // Future<void> onQRViewCreated(BarcodeScanner controller) async {
  //   ucsdAffiliation = _userDataProvider.authenticationModel.ucsdaffiliation;
  //   accessToken = _userDataProvider.authenticationModel.accessToken;
  //   // print("Access token: " + _userDataProvider.authenticationModel.accessToken);
  //   // this._controller = controller;
  //   var result = await BarcodeScanner.scan();

  //   controller.scannedDataStream.listen((scanData) {
  //     if (_qrText != scanData) {
  //       _qrText = scanData;
  //       _timeScanned = DateTime.now().millisecondsSinceEpoch;
  //       _submitState = submit_btn_active;
  //       notifyListeners();
  //     }
  //   });
  // }

  Map<String, dynamic> createData() {
    return {
      'barcode': _qrText,
      'ucsdaffiliation': ucsdAffiliation,
    };
  }

  void submitBarcode() async {
    if (_submitState != submit_btn_inactive) {
      _isLoading = true;
      _submitState = submit_btn_inactive;
      notifyListeners();
      var tempData = createData();
      var headers = {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken'
      };
      var results = await _barcodeService.uploadResults(headers, tempData);
      if (results) {
        _submitState = submit_btn_received;
      } else {
        _submitState = subit_btn_try_again;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  String get qrText => _qrText;
  String get cameraState => _cameraState;
  String get submitState => _submitState;

  ///Setters
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }
}
