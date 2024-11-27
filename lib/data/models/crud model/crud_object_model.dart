class CrudObject {
  const CrudObject({required this.collection, this.filter, this.data});

  final String collection;
  final Map<String, dynamic>? filter;
  final dynamic data;

  CrudObject.fromJson(Map<String, dynamic> json)
      : collection = json['collection'],
        filter = json['filter'],
        data = json['data'];

  Map<String, dynamic> toJson() => {'collection': collection, 'filter': filter, 'data': data};

  @override
  String toString() => 'CrudObject (collection: $collection, filter: $filter, data: $data)';
}
