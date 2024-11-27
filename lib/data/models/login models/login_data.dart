class LoginData {
  final String email;
  final String password;
  final String remember;

  LoginData(
      {required this.email, required this.password, required this.remember});

  LoginData.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        password = json['password'],
        remember = json['remember'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'remember': remember,
      };

  @override
  String toString() =>
      "LoginData: email: $email, password: $password, remember: $remember";
}
