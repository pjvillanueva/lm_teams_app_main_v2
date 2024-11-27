class InvitationData {
  InvitationData(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.asLeader,
      required this.phoneNumber,
      required this.message,
      required this.deliveryOptions});

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool asLeader;
  final String phoneNumber;
  final String message;
  final List<String> deliveryOptions;

  @override
  String toString() =>
      "InvitationData: firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, message: $message, deliveryOptions: $deliveryOptions";
}
