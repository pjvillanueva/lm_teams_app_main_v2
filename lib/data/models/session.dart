import 'package:equatable/equatable.dart';

class Session extends Equatable {
  const Session({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.expiresDate,
  });

  final String id;
  final String accountId;
  final String userId;
  final DateTime? expiresDate;

  @override
  List<Object?> get props => [id, accountId, userId, expiresDate];

  bool get hasExpired {
    if (expiresDate == null) return true;
    return expiresDate!.isBefore(DateTime.now());
  }

  Session.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        accountId = json['accountId'],
        userId = json['userId'],
        expiresDate = json['expiresDate'] != null ? DateTime.parse(json['expiresDate']) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'userId': userId,
        'expiresDate': expiresDate?.toIso8601String(),
      };
}
