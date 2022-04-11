import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart';

typedef JSON = Map<String, dynamic>;

// TODO include the fucking request/query in the result.
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

  /// Request Uri
  final Uri uri;

  const ODataResponse({required this.json, this.context, this.data, this.response, this.statusCode, required this.uri});
}

class ODataCollectionResponse<T> extends ODataResponse {
  final int? count;

  final BuiltList<T>? collectionData;

  const ODataCollectionResponse({
    required JSON json,
    required Uri uri,
    this.count,
    String? context,
    this.collectionData,
    Response? response,
    int? statusCode,
  }) : super(
          json: json,
          uri: uri,
          context: context,
          statusCode: statusCode,
          data: null,
        );
}
