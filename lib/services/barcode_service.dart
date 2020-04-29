import 'package:backtoschool/services/network.dart';

class BarcodeService {
  BarcodeService();
  bool _isLoading;
  String _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String _endpoint =
      'https://s8htpmldd3.execute-api.us-west-2.amazonaws.com/dev/barcodeV2';

  Future<bool> uploadResults(
      Map<String, String> headers, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    try {
      final response =
          await _networkHelper.authorizedPost(_endpoint, headers, body);
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
}
