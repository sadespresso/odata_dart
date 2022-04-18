import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart';
import 'package:odata_dart/odata/query.dart';

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

  /// Request Uri
  final Uri uri;

  /// The request sent to the server
  final Request request;

  /// The query used to make the request
  final Query query;

  const ODataResponse({required this.uri, required this.request, required this.query, required this.json, this.context, this.data, this.response, this.statusCode});
}

class ODataCollectionResponse<T> extends ODataResponse {
  final int? count;

  final BuiltList<T>? collectionData;

  const ODataCollectionResponse({
    required JSON json,
    required Uri uri,
    required Request request,
    required CollectionQuery query,
    String? context,
    Response? response,
    int? statusCode,
    this.count,
    this.collectionData,
  }) : super(
          json: json,
          uri: uri,
          context: context,
          statusCode: statusCode,
          data: null,
          request: request,
          query: query,
        );
}
