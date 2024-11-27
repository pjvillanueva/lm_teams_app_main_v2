class LoginData {
  final String email;
  final String password;
  final String expiry;

  LoginData(
      {required this.email, required this.password, required this.expiry});

  LoginData.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        password = json['password'],
        expiry = json['expiry'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'expiry': expiry,
      };
}
