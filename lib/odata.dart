import 'package:built_collection/built_collection.dart';
import 'package:odata_dart/odata/query_options.dart';

import 'odata/query.dart';

export 'odata/query_fields.dart';
export 'odata/query_options.dart';
export 'odata/result.dart';

/// Uses HTTPS by default. You can use HTTP by setting [useHttp] to `true`
///
///
class OData {
  late final String baseUrl;

  String? _cookie;
  set cookie(String cookies) => _cookie = cookies;
  String? _bearer;
  set bearer(String token) => _bearer = token;

  /// If enabled, uses HTTP instead of HTTPS.
  final bool useHttp;

  OData(String _baseUrl, {this.useHttp = false}) {
    if (_baseUrl.contains(r"://")) {
      throw Exception("Please omit the protocol");
    } else {
      baseUrl = _baseUrl;
    }
  }

  /// [tryUseAuth] will attach Authorization information to the Headers if possible
  Query<T> single<T>(String path, {QueryOptions<T> options = const QueryOptions(), bool tryUseAuth = true}) {
    return Query<T>(
      baseUrl: baseUrl,
      options: options,
      path: path,
      cookie: tryUseAuth ? _cookie : null,
      bearer: tryUseAuth ? _bearer : null,
    );
  }

  /// [tryUseAuth] will attach Authorization information to the Headers if possible
  CollectionQuery<T> collection<T>(String path, {QueryOptions options = const QueryOptions(), bool tryUseAuth = true}) {
    return CollectionQuery<T>(
      baseUrl: baseUrl,
      path: path,
      cookie: tryUseAuth ? _cookie : null,
      bearer: tryUseAuth ? _bearer : null,
    );
  }

  void setCookie(String cookie) {
    _cookie = cookie;
  }

  void setBearer(String token) {
    _bearer = token;
  }

  Future<T?> get<T>(String path) async {
    throw UnimplementedError();
  }

  Future<BuiltList<T?>> getList<T>(String path) async {
    throw UnimplementedError();
  }
}
