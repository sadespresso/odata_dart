extension ToQueryField on String {
  QueryField get toQueryField => QueryField(this);
}

class QueryField {
  final String field;

  const QueryField(this.field);

  @override
  String toString() => field;
}

class ExpandQueryField extends QueryField {
  // $filter, $select, $orderby, $skip, $top, $count, $search

  String? _compute;

  int? _levels;
  bool _levelMax = false;

  List<OrderyByField> _orderby = [];

  List<ExpandQueryField> _expand = [];

  List<String> _select = [];
  bool _selectAll = false;

  ExpandQueryField(String field) : super(field);

  ExpandQueryField compute(String expression) {
    _compute = expression;

    return this;
  }

  ExpandQueryField select(String fields) {
    if (_selectAll) {
      throw Exception("[OData Helper] Defining fields to select when 'selectAll' is enabled is useless");
    }

    fields = fields.replaceAll(RegExp(r"\s"), "");

    if (!RegExp(r"^[a-zA-z_0-9,]*$").hasMatch(fields)) {
      throw Exception("[OData Helper] select fields can only have letters, numbers and underscore");
    }

    return selectList(fields.split(","));
  }

  ExpandQueryField selectList(Iterable<String> fields) {
    if (_selectAll) {
      throw Exception("[OData Helper] Defining fields to select when 'selectAll' is enabled is useless");
    }

    _select = {..._select, ...fields}.toList();

    return this;
  }

  ExpandQueryField selectAll() {
    _selectAll = true;

    return this;
  }

  ExpandQueryField level(int i) {
    if (_levelMax) {
      throw Exception("[OData Helper] [ExpandQueryField] Setting level when levelMax is true is useless");
    }

    _levels = i;

    return this;
  }

  ExpandQueryField levelMax() {
    _levelMax = true;

    return this;
  }

  ExpandQueryField expand(ExpandQueryField expandQueryField) {
    _expand = [..._expand, expandQueryField];

    return this;
  }

  ExpandQueryField orderby(OrderyByField orderyByField) {
    _orderby = {..._orderby, orderyByField}.toList();

    return this;
  }

  @override
  String toString() {
    List<String> queries = [];

    if (_orderby.isNotEmpty) {
      queries.add(r"$orderby=" + queries.join(", "));
    }

    if (_levelMax) {
      queries.add(r"$levels=max");
    } else if (_levels != null) {
      queries.add(r"$levels=" + _levels.toString());
    }

    if (_selectAll) {
      queries.add(r"$select=*");
    } else if (_select.isNotEmpty) {
      queries.add(r"$select=" + _select.join(","));
    }

    if (queries.isEmpty) {
      return field;
    }

    if (_expand.isNotEmpty) {
      queries.add(r"$expand=" + _expand.join(","));
    }

    if (_compute != null && _compute!.isNotEmpty) {
      queries.add(r"$compute=" + _compute!);
    }

    return "$field(${queries.join(';')})";
  }
}

extension ToOrderyByField on String {
  OrderyByField get asc => OrderyByField.asc(this);
  OrderyByField get desc => OrderyByField.desc(this);
}

extension ToExpandQueryField on String {
  ExpandQueryField expand() {
    return ExpandQueryField(this);
  }
}

enum OrderyByFieldType {
  asc,
  desc,
}

class OrderyByField extends QueryField {
  final OrderyByFieldType type;

  const OrderyByField.asc(String field)
      : type = OrderyByFieldType.asc,
        super(field);
  const OrderyByField.desc(String field)
      : type = OrderyByFieldType.desc,
        super(field);

  @override
  String toString() {
    return "${super.toString()} ${type.name}";
  }
}
