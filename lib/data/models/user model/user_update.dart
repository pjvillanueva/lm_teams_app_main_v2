import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

class UserUpdate {
  UserUpdate({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.image,
  });
  final String id;
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  ImageObject? image;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (mobile != null) 'mobile': mobile,
        if (image != null) 'image': image
      };

  bool get hasUpdate {
    return firstName != null ||
        lastName != null ||
        email != null ||
        mobile != null ||
        image != null;
  }

  @override
  String toString() =>
      "Profile Data: firstName: $firstName, lastName: $lastName, email: $email, mobile: $mobile, image: $image,";
}
