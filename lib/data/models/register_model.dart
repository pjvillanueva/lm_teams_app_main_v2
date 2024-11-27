class RegisterData {
  final String firstName;
  final String lastName;
  final String? accountName;
  final String? accountId;
  final String roleId;
  final String email;
  final String password;
  final String password2;
  final String? mobile;
  final String remember;

  RegisterData({
    required this.firstName,
    required this.lastName,
    this.accountName,
    this.accountId,
    required this.roleId,
    required this.email,
    required this.password,
    required this.password2,
    this.mobile,
    required this.remember,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'accountName': accountName,
        'accountId': accountId,
        'roleId': roleId,
        'email': email,
        'password': password,
        'password2': password2,
        'mobile': mobile,
        'remember': remember,
      };

  @override
  String toString() =>
      "RegisterData: , accountId: $accountId, firstName: $firstName, lastName: $lastName, accountName: $accountName, roleId: $roleId, email: $email, password: $password, mobile: $mobile, remember: $remember";
}
