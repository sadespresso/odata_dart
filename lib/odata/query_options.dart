import 'package:built_collection/built_collection.dart';

class QueryOptions<T> {
  /// HTTP Method. e.g. GET, PATCH, DELETE, PUT, etc..
  final String method;

  /// Data to send to the server
  final Object? data;

  final T Function(Map<String, dynamic>? json)? convertor;

  T? convert(Object? value) {
    if (convertor == null) {
      throw Exception("Cannot call QueryOptions.convert when convertor is absent");
    }

    if (value == null) return null;

    return convertor!(value as Map<String, dynamic>);
  }

  const QueryOptions({
    this.convertor,
    this.method = "GET",
    this.data,
  });
}

class CollectionQueryOptions<T> extends QueryOptions {
  @override
  BuiltList<T>? convert(Object? value) {
    if (convertor == null) {
      throw Exception("Cannot call QueryOptions.convert when convertor is absent");
    }

    if (value == null) return null;

    return BuiltList.from((value as Iterable<Map<String, dynamic>>).map((e) => convertor!(e)));
  }

  const CollectionQueryOptions({
    T Function(Map<String, dynamic>? json)? convertor,
    String method = "GET",
    Object? data,
  }) : super(
          convertor: convertor,
          data: data,
          method: method,
        );
}
