import 'package:backtoschool/constants.dart';
import 'package:backtoschool/services/barcode.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerDataProvider extends ChangeNotifier {
  ScannerDataProvider() {
    ///DEFAULT STATES
    isLoading = false;

    ///INITIALIZE SERVICES
    _barcodeService = BarcodeService();
  }

  bool _hasScanned;
  bool hasSubmitted;
  bool _didError;
  String _message = '';

  String _licenseKey;
  BarcodeService _barcodeService;
  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
  var ucsdAffiliation = "";
  var accessToken = "";
  String _barcode;
  bool isLoading;
  bool _isDuplicate;
  bool _successfulSubmission;
  bool _isValidBarcode;
  String errorText;
  PermissionStatus cameraPermissionsStatus = PermissionStatus.undetermined;
  ScanditController _controller;

  /// Simple setters and getters
  set controller(ScanditController value) {
    _controller = value;
  }

  set message(String value) {
    _message = value;
  }

  String get barcode => _barcode;
  String get message => _message;
  bool get didError => _didError;
  bool get hasScanned => _hasScanned;
  String get licenseKey => _licenseKey;
  bool get isDuplicate => _isDuplicate;
  bool get isValidBarcode => _isValidBarcode;
  bool get successfulSubmission => _successfulSubmission;
  ScannerDataProvider _scannerDataProvider;

  void initState() {
    _licenseKey = 'SCANDIT_NATIVE_LICENSE_PH';
    errorText = "Something went wrong, please try again.";
  }

  void setDefaultStates() {
    _hasScanned = false;
    hasSubmitted = false;
    _didError = false;
    _successfulSubmission = false;
    isLoading = false;
    _isDuplicate = false;
    _isValidBarcode = true;
    notifyListeners();
  }

  void restoreDefaults() {
    _hasScanned = false;
    hasSubmitted = false;
    _didError = false;
    _successfulSubmission = false;
    isLoading = false;
    _isDuplicate = false;
    _isValidBarcode = true;
  }

  Future requestCameraPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (cameraPermissionsStatus != status) {
      cameraPermissionsStatus = status;
    }
  }

  Map<String, dynamic> createUserData() {
    ucsdAffiliation = _userDataProvider.authenticationModel.ucsdaffiliation;
    accessToken = _userDataProvider.authenticationModel.accessToken;
    return {'barcode': _barcode, 'ucsdaffiliation': ucsdAffiliation};
  }

  Future<void> handleBarcodeResult(BarcodeResult result) async {
    _hasScanned = true;
    _barcode = result.data;
    var data = createUserData();
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${accessToken}'
    };
    isLoading = true;
    notifyListeners();
    var results = await _barcodeService.uploadResults(headers, data);

    if (results) {
      isLoading = false;
      _didError = false;
      _successfulSubmission = true;
      notifyListeners();
    } else {
      print(_barcodeService.error);
      print("error constant: " + ErrorConstants.duplicateRecord);
      _successfulSubmission = false;
      _didError = true;
      isLoading = false;
      if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
        await _userDataProvider.silentLogin();
      } else if (_barcodeService.error
          .contains(ErrorConstants.duplicateRecord)) {
        print("in correct if");
        errorText =
            "Submission failed due to barcode already scanned. Please scan another barcode.";
        _isDuplicate = true;
        notifyListeners();
      } else if (_barcodeService.error.contains(ErrorConstants.invalidMedia)) {
        errorText = "Barcode is not valid. Please scan another barcode.";
        _isValidBarcode = false;
        notifyListeners();
      }
      //_submitted = true;

      notifyListeners();
    }
  }
}
