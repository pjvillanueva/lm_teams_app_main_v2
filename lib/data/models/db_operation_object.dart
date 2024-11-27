class IDBOperationObject<T> {
  String table;
  T? options;
  dynamic data;

  IDBOperationObject({required this.table, this.options, this.data});

  Map<String, dynamic> toJson() => {
        'table': table,
        'options': options,
        'data': data,
      };

  @override
  String toString() => "IDBOperationObject: table: $table, options: $options, data: $data";
}

class IDBReadOptions {
  String? id;
  List<String>? select;
  Map<String, dynamic>? where;
  bool? firstOnly;

  IDBReadOptions({this.id, this.select, this.where, this.firstOnly});

  Map<String, dynamic> toJson() => {
        'id': id,
        'select': select,
        'where': where,
        'firstOnly': firstOnly,
      };

  @override
  String toString() =>
      "IDBReadOptions: id: $id, select: $select, where: $where, firstOnly: $firstOnly";
}

class DbReadRequest extends IDBOperationObject<IDBReadOptions> {
  DbReadRequest(String table, IDBReadOptions? options) : super(table: table, options: options);
}
