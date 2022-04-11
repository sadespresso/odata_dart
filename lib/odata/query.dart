import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;
import 'package:odata_dart/odata/query_fields.dart';
import 'package:odata_dart/odata/query_options.dart';

import 'package:odata_dart/odata/result.dart';

abstract class QueryBase {
  final String baseUrl;

  /// Full path will be: `$baseUrl/$path`
  final String path;

  const QueryBase(this.baseUrl, this.path);

  Future<ODataResponse?> fetch();
}

class Query<T> extends QueryBase {
  final String? cookie;
  final String? bearer;

  final QueryOptions<T> options;

  List<String> _filter = [];
  List<ExpandQueryField> _expand = [];
  List<String> _select = [];
  bool _selectAll = false;

  Query({this.options = const QueryOptions(), required String baseUrl, required String path, this.cookie, this.bearer}) : super(baseUrl, path);

  JSON get headers {
    final JSON value = {};

    if (cookie != null) {
      value["Cookie"] = cookie;
    }
    if (bearer != null) {
      value["Authorization"] = "Bearer $bearer";
    }

    value["Accept-Charset"] = "utf-8";
    value["Content-Type"] = "application/json;odata=verbose";

    return value;
  }

  JSON queries() {
    final JSON value = {};

    if (_filter.isNotEmpty) {
      value["\$filter"] = _filter.join(", ");
    }

    if (_expand.isNotEmpty) {
      value["\$expand"] = _expand.join(", ");
    }

    if (_selectAll) {
      value["\$select"] = "*";
    } else if (_select.isNotEmpty) {
      value["\$select"] = _select.join(", ");
    }

    return value;
  }

  @override
  Future<ODataResponse<T>?> fetch() async {
    final http.Request req = http.Request(options.method, Uri.https(baseUrl, path, queries()));

    req.body = options.data.toString();

    headers.forEach((key, value) {
      req.headers[key] = value;
    });

    http.StreamedResponse streamedResponse = await req.send();
    http.Response r = await http.Response.fromStream(streamedResponse);

    late final T? data;
    late final JSON json;

    try {
      json = jsonDecode(r.body);

      data = options.convert(json);
    } catch (e) {
      data = null;
      try {
        json = {};
      } catch (e) {}
    }

    return ODataResponse<T>(
      path: path,
      response: r,
      json: json,
      statusCode: r.statusCode,
      context: json["@odata.context"],
    );
  }

  Query<T> select(Iterable<String> fields) {
    if (_selectAll) {
      throw Exception("[OData Helper] Defining fields to select when 'selectAll' is enabled is useless");
    }

    _select = {..._select, ...fields}.toList();

    return this;
  }

  Query<T> selectAll() {
    _selectAll = true;

    return this;
  }

  Query<T> filter(String expression) {
    _filter = {..._filter, expression}.toList();

    return this;
  }

  Query<T> expand(ExpandQueryField expandQueryField) {
    _expand = {..._expand, expandQueryField}.toList();

    return this;
  }
}

class CollectionQuery<T> extends Query {
  int? _top;
  int? _skip;
  bool _count = false;
  List<OrderyByField> _orderby = [];
  String? _search;

  CollectionQuery({required String baseUrl, required String path, String? cookie, String? bearer}) : super(baseUrl: baseUrl, path: path, bearer: bearer, cookie: cookie);

  @override
  JSON queries() {
    final JSON value = super.queries();

    if (_top != null) {
      value["\$top"] = _top!.toString();
    }

    if (_skip != null) {
      value["\$skip"] = _skip!.toString();
    }

    if (_count) {
      value["\$count"] = "true";
    }

    return value;
  }

  @override
  Future<ODataCollectionResponse<T>?> fetch() async {
    final http.Request req = http.Request(options.method, Uri.https(baseUrl, path, queries()));

    req.body = options.data.toString();

    headers.forEach((key, value) {
      req.headers[key] = value;
    });

    http.StreamedResponse streamedResponse = await req.send();
    http.Response r = await http.Response.fromStream(streamedResponse);

    late final BuiltList<T>? data;
    late final JSON json;

    try {
      json = jsonDecode(r.body);

      data = options.convert(json["value"]);
    } catch (e) {
      data = null;
      try {
        json = {};
      } catch (e) {}
    }

    return ODataCollectionResponse<T>(
      path: path,
      response: r,
      json: json,
      collectionData: data,
      count: json["@odata.count"],
      statusCode: r.statusCode,
      context: json["@odata.context"],
    );
  }

  CollectionQuery top(int i) {
    if (i.isNegative) {
      throw Exception("\$top cannot accept negative value");
    }

    _top = i;

    return this;
  }

  CollectionQuery skip(int i) {
    if (i.isNegative) {
      throw Exception("\$skip cannot accept negative value");
    }

    _skip = i;

    return this;
  }

  CollectionQuery skipAndTop({required int skip, required int top}) {
    if (skip.isNegative || top.isNegative) {
      throw Exception("Either \$skip and \$top cannot accept negative value");
    }

    _skip = skip;
    _top = top;

    return this;
  }

  CollectionQuery count() {
    _count = true;

    return this;
  }

  CollectionQuery orderby(OrderyByField orderyByField) {
    _orderby = {..._orderby, orderyByField}.toList();

    return this;
  }

  CollectionQuery search(String searchQuery) {
    _search = searchQuery;

    return this;
  }
}
