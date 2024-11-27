import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';
import 'package:lm_teams_app/data/models/user%20model/user_update.dart';

// ignore: must_be_immutable
class User extends Equatable {
  User({
    required this.id,
    this.accountId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.mobile,
    this.image,
    this.emailConfirmed = false,
  });

  String id;
  String? accountId;
  String email;
  String firstName;
  String lastName;
  String? mobile;
  ImageObject? image;
  bool emailConfirmed;

  String get name {
    return "$firstName $lastName";
  }

  get initials {
    try {
      var initials = firstName[0] + (lastName.isNotEmpty ? lastName[0] : "");
      return initials.toUpperCase();
    } catch (e) {
      return 'UN';
    }
  }

  static final empty = User(
      id: '-',
      firstName: '-',
      lastName: '-',
      email: '-',
      mobile: '-',
      image: null,
      emailConfirmed: false);

  User updatedUser(UserUpdate update) {
    return User(
        id: id,
        firstName: update.firstName ?? firstName,
        lastName: update.lastName ?? lastName,
        email: update.email ?? email,
        mobile: update.mobile ?? mobile,
        image: update.image ?? image);
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email, mobile, image, emailConfirmed];

  @override
  String toString() =>
      'User (id : $id, firstName : $firstName, lastName: $lastName, email : $email, mobile: $mobile,image: $image, emailConfirmed: $emailConfirmed)';

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        accountId = json['_accountId'],
        email = json['email'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        mobile = json['mobile'],
        image = _decodeImageObject(json['image']),
        emailConfirmed = json['emailConfirmed'];

  Map<String, dynamic> toJson() => {
        'id': id,
        '_accountId': accountId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'image': image,
        'emailConfirmed': emailConfirmed
      };
}

ImageObject? _decodeImageObject(dynamic object) {
  try {
    if (object == null) return null;
    if (object is ImageObject) return object;
    if (object is String) {
      return ImageObject.fromJson(jsonDecode(object));
    }
    return ImageObject.fromJson(object);
  } catch (e) {
    return null;
  }
}
