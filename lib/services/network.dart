import 'dart:async';

import 'package:dio/dio.dart';

class NetworkHelper {
  ///TODO: inside each service that file place a switch statement to handle all
  ///TODO: different errors thrown by the Dio client DioErrorType.RESPONSE
  const NetworkHelper();

  Future<dynamic> authorizedPost(
      String url, Map<String, String> headers, dynamic body) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = 20000;
    dio.options.receiveTimeout = 20000;
    dio.options.headers = headers;
    try {
      final _response = await dio.post(url, data: body);
      if (_response.statusCode == 200) {
        // If server returns an OK response, return the body
        return _response.data;
      } else {
        ///TODO: log this as a bug because the response was bad
        // If that response was not OK, throw an error.
        throw Exception('Failed to upload data: ' + _response.data);
      }
    } on TimeoutException catch (e) {
      // Display an alert, no internet
    } catch (err) {
      print(err);
      return null;
    }
  }
}
