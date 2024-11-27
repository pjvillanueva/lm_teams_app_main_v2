import 'dart:convert';

class TeamInvitee {
  TeamInvitee(
      {required this.id,
      this.accountId,
      required this.teamId,
      required this.teamName,
      required this.inviterId,
      required this.inviterName,
      required this.invitationMessage,
      required this.invitationLink,
      required this.deliveryOptions,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phoneNumber,
      required this.isLeader});

  final String id;
  final String? accountId;
  final String teamId;
  final String teamName;
  final String inviterId;
  final String inviterName;
  final String invitationMessage;
  String invitationLink;
  final List? deliveryOptions;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool isLeader;

  TeamInvitee.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        accountId = json['_accountId'],
        teamId = json['teamId'],
        teamName = json['teamName'],
        inviterId = json['inviterId'],
        inviterName = json['inviterName'],
        invitationMessage = json['invitationMessage'],
        invitationLink = json['invitationLink'],
        deliveryOptions = jsonDecode(json['deliveryOptions']),
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        phoneNumber = json['phoneNumber'],
        isLeader = json['isLeader'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamId': teamId,
        'teamName': teamName,
        'inviterId': inviterId,
        'inviterName': inviterName,
        'invitationMessage': invitationMessage,
        'invitationLink': invitationLink,
        'deliveryOptions': deliveryOptions,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'isLeader': isLeader
      };

  get name {
    return "$firstName $lastName";
  }

  @override
  String toString() =>
      "Team Invitee: [ id: $id, teamId: $teamId, inviterId: $inviterId, 'inviterName: $inviterName, invitationMessage: $invitationMessage, invitationLink: $invitationLink, deliveryOptions: $deliveryOptions, firstName: $firstName, lastName: $lastName, email: $email, 'phoneNumber': $phoneNumber, isLeader: $isLeader ]";
}
