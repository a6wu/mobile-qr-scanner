import 'package:backtoschool/constants.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/services/barcode.dart';
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
  bool isBloodScreen = false;
  bool isCovidTest = false;
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
  int scannerError;
  PermissionStatus cameraPermissionsStatus = PermissionStatus.undetermined;
  ScanditController _controller;
  List<String> scannedCodes = new List<String>();

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

  void initState() {
    _licenseKey = 'SCANDIT_NATIVE_LICENSE_PH';
    scannerError = LocalizationErrors.other;
  }

  void setDefaultStates() {
    scannedCodes.clear();
    _hasScanned = false;
    hasSubmitted = false;
    _didError = false;
    _successfulSubmission = false;
    isLoading = false;
    _isDuplicate = false;
    _isValidBarcode = true;
    notifyListeners();
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

  void verifyBarcodeScanning(BarcodeResult result) {
    scannedCodes.add(result.data);
    // currently scanning 3 consecutive times
    if (scannedCodes.length < 3) {
      print('Scan ' + scannedCodes.length.toString() + '/3 completed');
      _controller.resumeBarcodeScanning();
    } else {
      print('Scan 3/3 completed');
      String firstScan = scannedCodes.first;
      // if all scans are not the same, need to go into error state
      // otherwise, continue to handle normally
      if (scannedCodes.every((element) => element == firstScan)) {
        print('Scanned Codes Match (x3): TRUE');
        // ACCEPT STATE
        handleBarcodeResult(result);
      } else {
        print('Scanned Codes Match (x3): FALSE');
        // REJECT STATE
        _hasScanned = true;
        _didError = true;
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> handleBarcodeResult(BarcodeResult result) async {
    _hasScanned = true;
    _barcode = result.data;
    scannedCodes.clear();

    // regex for blood test kit scanning
    RegExp bloodScreenTest = RegExp(r'^UCSDNAS');
    isBloodScreen = bloodScreenTest.hasMatch(_barcode);
    print('isBloodScreen: ${isBloodScreen}');

    var data = createUserData();
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${accessToken}'
    };
    isLoading = true;
    notifyListeners();

    print('Submitting Scanned Code: ' + _barcode);
    var results = await _barcodeService.uploadResults(headers, data);

    if (results) {
      print('Submission: SUCCESS');
      isLoading = false;
      _didError = false;
      _successfulSubmission = true;
      notifyListeners();
    } else {
      print('Submission: FAILED');
      _successfulSubmission = false;
      _didError = true;
      isLoading = false;
      if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
        await _userDataProvider.silentLogin();
      } else if (_barcodeService.error
          .contains(ErrorConstants.duplicateRecord)) {
        scannerError = LocalizationErrors.duplicate;
        _isDuplicate = true;
        notifyListeners();
      } else if (_barcodeService.error.contains(ErrorConstants.invalidMedia)) {
        scannerError = LocalizationErrors.invalid;
        _isValidBarcode = false;
        notifyListeners();
      }
      notifyListeners();
    }
  }
}
