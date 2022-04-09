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

  ExpandQueryField? _expand;

  ExpandQueryField(String field) : super(field);

  ExpandQueryField compute(String expression) {
    _compute = expression;

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
    _expand = expandQueryField;

    return this;
  }

  ExpandQueryField orderby(OrderyByField orderyByField) {
    _orderby = {..._orderby, orderyByField}.toList();

    return this;
  }
}

extension ToOrderyByField on String {
  OrderyByField get asc => OrderyByField.asc(this);
  OrderyByField get desc => OrderyByField.desc(this);
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
