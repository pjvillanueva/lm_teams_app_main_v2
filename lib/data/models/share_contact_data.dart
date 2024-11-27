class ShareContactData {
  ShareContactData({required this.userID, required this.contactID});

  final String userID;
  final String contactID;

  Map<String, dynamic> toJson() => {'userID': userID, 'contactID': contactID};
}
