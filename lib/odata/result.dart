import 'package:http/http.dart';

typedef JSON = Map<String, dynamic>;

class ODataResponse<T> {
  /// @odata.context
  final String? context;

  /// Response data
  final T? data;

  /// Response json.
  ///
  /// Will be empty map the body isn't valid JSON
  final JSON json;

  /// Raw response
  final Response? response;

  /// Response status code
  final int? statusCode;

  /// Full path of the sent request
  final String path;

  ODataResponse({required this.json, this.context, this.data, this.response, this.statusCode, required this.path});
}
