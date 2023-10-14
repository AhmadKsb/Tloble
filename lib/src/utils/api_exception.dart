class APIException implements Exception {
  static APIException generic = APIException(
    'generic_error',
    'An error has occurred, please try again later.',
  );
  static APIException certificatePinning = APIException(
    'certificate_pinning_error',
    'An error has occurred, please try again later.',
  );
  static APIException connection = APIException(
    'internet_error',
    'Please check your internet connection',
  );

  static String? get genericError => generic.toString();

  /// * A code returned from the API.
  String? code;

  int? statusCode;

  /// A message returned from the API.
  String? message;

  /// A detailed message returned from the API.
  String? details;

  APIException(
    this.code,
    this.message,
  );

  APIException.fromJson(Map<String, dynamic> json, [int? statusCode]) {
    Map<String, dynamic> _json = json;
    if (json.containsKey("error")) {
      /// Integration error format
      /// ```json
      /// {
      ///   "error": {
      ///     "code": "sochitel_4",
      ///     "message": "Invalid amount",
      ///     "status": 500
      ///   }
      /// }
      /// ```
      _json = json['error'];
    }
    code = _json['code'];
    message = _json['message'];
    details = _json['details'];
    this.statusCode = statusCode;
    if (message == null || message == '') {
      message = 'An error has occurred.';
    }
  }

  @override
  String toString() => message ?? "";

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is APIException &&
        o.code == code &&
        o.message == message &&
        o.statusCode == statusCode &&
        o.details == details;
  }

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ statusCode.hashCode ^ details.hashCode;
}

abstract class APIErrorCode {
  static final invalidSecondFactor = 'invalid_second_factor';
}
