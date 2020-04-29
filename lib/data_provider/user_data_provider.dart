import 'package:backtoschool/models/authentication_model.dart';
import 'package:backtoschool/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class UserDataProvider extends ChangeNotifier {
  UserDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _authenticationService = AuthenticationService();
    storage = FlutterSecureStorage();

    ///default authentication model and profile is needed in this class
    _authenticationModel = AuthenticationModel.fromJson({});
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  String _username;

  ///MODELS
  AuthenticationModel _authenticationModel;
  FlutterSecureStorage storage;

  ///SERVICES
  AuthenticationService _authenticationService;

  ///Update the authentication model saved in state and save the model in persistent storage
  Future updateAuthenticationModel(AuthenticationModel model) async {
    _authenticationModel = model;
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    await box.put('AuthenticationModel', model);
    _lastUpdated = DateTime.now();
  }

  ///Load data from persistent storage
  ///Will create persistent storage if  no data is found
  Future loadSavedData() async {
    Hive.registerAdapter(AuthenticationModelAdapter());
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    AuthenticationModel temp = AuthenticationModel.fromJson({});
    //check to see if we have added the authentication model into the box already
    if (box.get('AuthenticationModel') == null) {
      await box.put('AuthenticationModel', temp);
      _authenticationModel = temp;
    } else {
      temp = box.get('AuthenticationModel');
      _authenticationModel = temp;
      await refreshToken();
    }
  }

  ///Save encrypted password to device
  void saveEncryptedPasswordToDevice(String encryptedPassword) {
    storage.write(key: 'encrypted_password', value: encryptedPassword);
  }

  ///Get encrypted password that has been saved to device
  Future<String> getEncryptedPasswordFromDevice() {
    return storage.read(key: 'encrypted_password');
  }

  ///Save email to device
  void saveUsernameToDevice(String username) {
    storage.write(key: 'username', value: username);
  }

  ///Get email from device
  Future<String> getUsernameFromDevice() {
    return storage.read(key: 'username');
  }

  void deleteUsernameFromDevice() {
    storage.delete(key: 'username');
  }

  void deletePasswordFromDevice() {
    storage.delete(key: 'password');
  }

  ///Encrypt given username and password and store on device
  void encryptLoginInfo(String username, String password) {
    // TODO: import assets/public_key.txt
    final String pkString = '-----BEGIN PUBLIC KEY-----\n' +
        'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJD70ejMwsmes6ckmxkNFgKley\n' +
        'gfN/OmwwPSZcpB/f5IdTUy2gzPxZ/iugsToE+yQ+ob4evmFWhtRjNUXY+lkKUXdi\n' +
        'hqGFS5sSnu19JYhIxeYj3tGyf0Ms+I0lu/MdRLuTMdBRbCkD3kTJmTqACq+MzQ9G\n' +
        'CaCUGqS6FN1nNKARGwIDAQAB\n' +
        '-----END PUBLIC KEY-----';

    final rsaParser = RSAKeyParser();
    final pc.RSAPublicKey publicKey = rsaParser.parse(pkString);
    var cipher = OAEPEncoding(pc.AsymmetricBlockCipher('RSA'));
    pc.AsymmetricKeyParameter<pc.RSAPublicKey> keyParametersPublic =
        new pc.PublicKeyParameter(publicKey);
    cipher.init(true, keyParametersPublic);
    Uint8List output = cipher.process(utf8.encode(password));
    var base64EncodedText = base64.encode(output);
    saveUsernameToDevice(username);
    saveEncryptedPasswordToDevice(base64EncodedText);
  }

  ///logs user in with saved credentials on device
  ///if this login mechanism fails then the user is logged out
  Future silentLogin() async {
    String username = await getUsernameFromDevice();
    String encryptedPassword = await getEncryptedPasswordFromDevice();
    if (username != null && encryptedPassword != null) {
      final String base64EncodedWithEncryptedPassword =
          base64.encode(utf8.encode(username + ':' + encryptedPassword));
      if (await _authenticationService
          .login(base64EncodedWithEncryptedPassword)) {
        await updateAuthenticationModel(_authenticationService.data);
      } else {
        //logout();
        _error = _authenticationService.error;
      }
    }
  }

  ///authenticate a user given an email and password
  ///upon logging in we should make sure that users upload the correct
  ///ucsdaffiliation and classification
  void login(String username, String password) async {
    encryptLoginInfo(username, password);
    _error = null;
    _isLoading = true;
    notifyListeners();
    await silentLogin();
    _isLoading = false;
    notifyListeners();
  }

  ///Logs out user
  ///Resets all authentication data and all userProfile data
  void logout() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    updateAuthenticationModel(AuthenticationModel.fromJson({}));
    deletePasswordFromDevice();
    deleteUsernameFromDevice();
    var box = await Hive.openBox<AuthenticationModel>('AuthenticationModel');
    await box.clear();
    _isLoading = false;
    notifyListeners();
  }

  ///Uses saved refresh token to reauthenticate user
  ///Invokes [silentLogin] on failure
  ///TODO: check if we need to change the loading boolean since this is a silent login mechanism
  Future refreshToken() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    if (await _authenticationService
        .refreshAccessToken(_authenticationModel.refreshToken)) {
      /// this is only added to refresh token method because the response for the refresh token does not include
      /// pid and ucsdaffiliation fields
      if (_authenticationModel.pid != null) {
        AuthenticationModel finalModel = _authenticationService.data;
        finalModel.pid = _authenticationModel.pid;
        finalModel.ucsdaffiliation = _authenticationModel.ucsdaffiliation;
      }
      await updateAuthenticationModel(_authenticationService.data);
    } else {
      ///if the token passed from the device was empty then [_error] will be populated with 'The given refresh token was invalid'
      ///if the token passed from the device was malformed or expired then [_error] will be populated with 'invalid_grant'
      _error = _authenticationService.error;

      ///Try to use user's credentials to login again
      await silentLogin();
    }
    _isLoading = false;
    notifyListeners();
  }

  ///GETTERS FOR MODELS
  AuthenticationModel get authenticationModel => _authenticationModel;

  ///GETTERS FOR STATES
  String get error => _error;
  bool get isLoggedIn => _authenticationModel.isLoggedIn(_lastUpdated);
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
  String get username => _username;
}
