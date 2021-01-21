const submit_btn_inactive = "Sending";
const submit_btn_try_again = "Try again";
const submit_btn_received = "Received";

const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

class ErrorConstants {
  static const authorizedPostErrors = 'Failed to upload data: ';
  static const authorizedPutErrors = 'Failed to update data: ';
  static const invalidBearerToken = 'Invalid bearer token';
  static const duplicateRecord =
      'DioError [DioErrorType.RESPONSE]: Http status error [409]';
  static const invalidMedia =
      'DioError [DioErrorType.RESPONSE]: Http status error [415]';
}

// This class of constants is to help with differentiating errors
// for localization
class LocalizationErrors {
  static const int other = 0;
  static const int duplicate = 1;
  static const int invalid = 2;
}