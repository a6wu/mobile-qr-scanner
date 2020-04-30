import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/services/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
  QRViewController _controller;

  ///SERVICES
  BarcodeService _barcodeService;

  void onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_qrText != scanData) {
        _qrText = scanData;
        _timeScanned = DateTime.now().millisecondsSinceEpoch;
        _submitState = submit_btn_active;
        notifyListeners();
      }
    });
  }

  Future<Map<String, dynamic>> createData() async {
    final pattern = RegExp('[BGJMU]');
    var pid = "";
    if (_userDataProvider.authenticationModel.ucsdaffiliation
        .contains(pattern)) {
      pid = _userDataProvider.authenticationModel.pid;
    }
    return {
      'userId': await _userDataProvider.getUsernameFromDevice(),
      'barcode': _qrText,
      'uscdaffiliation': _userDataProvider.authenticationModel.ucsdaffiliation,
      'scannedDate': _timeScanned.toString(),
      'pid': pid
    };
  }

  void submitBarcode() async {
    if (_submitState != submit_btn_inactive) {
      _isLoading = true;
      _submitState = submit_btn_inactive;
      notifyListeners();
      var tempData = await createData();
      var headers = {
        "Content-Type": "application/json",
        'Authorization':
            'Bearer ${_userDataProvider.authenticationModel.accessToken}'
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

  void disposeController() {
    _controller.dispose();
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
