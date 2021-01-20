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

  void verifyBarcodeScanning(BarcodeResult result) {
    scannedCodes.add(result.data);
    // currently scanning 3 consecutive times
    if (scannedCodes.length < 3) {
      _controller.resumeBarcodeScanning();
    } else {
      String firstScan = scannedCodes.first;
      // if all scans are not the same, need to go into error state
      // otherwise, continue to handle normally
      if (scannedCodes.every((element) => element == firstScan)) {
        // ACCEPT STATE
        handleBarcodeResult(result);
      } else {
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
        errorText =
            "Submission failed due to barcode already scanned. Please scan another barcode.";
        _isDuplicate = true;
        notifyListeners();
      } else if (_barcodeService.error.contains(ErrorConstants.invalidMedia)) {
        errorText = "Barcode is not valid. Please scan another barcode.";
        _isValidBarcode = false;
        notifyListeners();
      }
      //empty the scanned codes after every attempt to upload
      scannedCodes.clear();

      notifyListeners();
    }
  }
}
