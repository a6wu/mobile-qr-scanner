import 'package:dio/dio.dart';

import 'network.dart';
class BarcodeService {
  BarcodeService();
  bool _isLoading;
  String _error;

  final String _endpoint =
      'https://api-qa.ucsd.edu:8243/scandata/2.0.0/scanData';

  Future<bool> uploadResults(
      Map<String, String> headers, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    try {
      final response =
          await authorizedPost(_endpoint, headers, body);
      print("ACTUAL RESULTS " + response.toString());
      if (response != null) {
        _isLoading = false;
        return true;
      } else {
        throw (response.toString());
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    return false;
  }

  String get error => _error;
  bool get isLoading => _isLoading;
  Future<dynamic> authorizedPost(
      String url, Map<String, String> headers, dynamic body) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = 20000;
    dio.options.receiveTimeout = 20000;
    dio.options.headers = headers;
    final _response = await dio.post(url, data: body);
    if (_response.statusCode == 200 || _response.statusCode == 201) {
      // If server returns an OK response, return the body
      return _response.data;
    } else if (_response.statusCode == 400) {
      // If that response was not OK, throw an error.
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 401) {
      throw Exception(ErrorConstants.authorizedPostErrors +
          ErrorConstants.invalidBearerToken);
    } else if (_response.statusCode == 404) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else if (_response.statusCode == 500) {
      String message = _response.data['message'] ?? '';
      throw Exception(ErrorConstants.authorizedPostErrors + message);
    } else {
      throw Exception(ErrorConstants.authorizedPostErrors + 'unknown error');
    }
  }
}

class ErrorConstants {
  static const authorizedPostErrors = 'Failed to upload data: ';
  static const invalidBearerToken = 'Invalid bearer token';
}
