class QueryOptions<T> {
  /// HTTP Method. e.g. GET, PATCH, DELETE, PUT, etc..
  final String method;

  final T Function(Map<String, dynamic> json)? convert;

  /// Data to send to the server
  final Object? data;

  const QueryOptions({
    this.convert,
    this.method = "GET",
    this.data,
  });
}
