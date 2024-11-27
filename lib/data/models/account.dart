import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];

  Account.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  static const empty = Account(id: '-', name: '-');

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  String toString() => "Account( id: $id, name: $name )";
}
