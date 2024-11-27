class ForgotPasswordData {
  const ForgotPasswordData({required this.userID, required this.newPassword});
  final String userID;
  final String newPassword;

  ForgotPasswordData.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        newPassword = json['newPassword'];

  Map<String, dynamic> toJson() =>
      {'userID': userID, 'newPassword': newPassword};
}
