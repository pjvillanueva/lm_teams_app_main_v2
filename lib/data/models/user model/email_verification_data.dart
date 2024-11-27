class EmailVerificationData {
  const EmailVerificationData({required this.userID, required this.code});
  final String userID;
  final String code;

  EmailVerificationData.fromJson(Map<String, dynamic> json)
      : userID = json['userId'],
        code = json['code'];

  Map<String, dynamic> toJson() => {'userId': userID, 'code': code};

  @override
  String toString() => "Verification Data: UserID: $userID, Code: $code";
}
