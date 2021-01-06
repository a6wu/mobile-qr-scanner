import 'package:backtoschool/models/authentication_model.dart';
import 'package:backtoschool/services/network.dart';

class AuthenticationService {
  AuthenticationService();
  String _error;
  AuthenticationModel _data;
  DateTime _lastUpdated;

  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint =
      'https://c12cf2xke8.execute-api.us-west-2.amazonaws.com/prod/v1.1/access-profile';

  final String AUTH_SERVICE_API_KEY =
      'QmmsvmHsyu5QnOrmaZay468MSBRjGIYDaW2S9iMd';

  final String refreshTokenEndpoint =
      'https://c12cf2xke8.execute-api.us-west-2.amazonaws.com/prod/v1.1/access-profile/refresh';

  Future<bool> login(String base64EncodedWithEncryptedPassword) async {
    _error = null;
    try {
      final Map<String, String> authServiceHeaders = {
        'x-api-key': AUTH_SERVICE_API_KEY,
        'Authorization': base64EncodedWithEncryptedPassword,
      };

      /// fetch data
      var response = await _networkHelper.authorizedPost(
          endpoint, authServiceHeaders, null);

      /// parse data
      final authenticationModel = AuthenticationModel.fromJson(response);
      _data = authenticationModel;
      _lastUpdated = DateTime.now();
      return true;
    } catch (e) {
      ///TODO: handle errors thrown by the network class for different types of error responses
      _error = e.toString();
      print("authentication error:" + _error);
      return false;
    }
  }

//  Future<bool> refreshAccessToken(String refreshToken) async {
//    _error = null;
//    final tokenHeaders = {'refresh_token': refreshToken};
//    try {
//      var response = await _networkHelper.authorizedPost(
//          refreshTokenEndpoint, tokenHeaders, null);
//      if (response['error'] != null) {
//        throw (response['error']);
//      }
//      final authenticationModel = AuthenticationModel.fromJson(response);
//      _data = authenticationModel;
//      _lastUpdated = DateTime.now();
//      return true;
//    } catch (e) {
//      ///TODO: check to see if error returned means the refresh token is expired
//      ///if refresh token is expired then try to reauthenticate using login method
//      _error = e.toString();
//      return false;
//    }
//  }

  DateTime get lastUpdated => _lastUpdated;
  AuthenticationModel get data => _data;
  String get error => _error;
  NetworkHelper get availabilityService => _networkHelper;
}
