class CustomValidators {
  String? emptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    } else {
      return null;
    }
  }

  String? passwordValidator(String? newPassword) {
    if (newPassword == null || newPassword.isEmpty) {
      return "This field is required";
    } else if (!RegExp(r'^(?=.*\d)(?=.*[a-zA-Z]).{6,}$').hasMatch(newPassword)) {
      return "At least 6 characters with a letter and number";
    } else if (newPassword.length > 32) {
      return "Maximum characters is 32";
    } else {
      return null;
    }
  }

  String? confirmPasswordValidator(String? value, String? newPassword) {
    if (value == newPassword) {
      return null;
    }
    return "Password do not match";
  }

  String? codeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Verification code is required";
    } else if (value.length != 6) {
      return "Verification code must have 6 characters";
    } else {
      return null;
    }
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return "First name is required";
    } else {
      return null;
    }
  }

  String? validatePhoneNumber(String? number) {
    if (number == null || number.isEmpty) {
      return null;
    } else if (number.length < 8) {
      return "Invalid phone number";
    } else {
      return null;
    }
  }

  String? mobileValidator(String? input) {
    RegExp regExp = RegExp(r"^(?:\+88|01)?(?:\d{11}|\d{13})$");
    if (input != null && input.isNotEmpty) {
      if (!regExp.hasMatch(input)) {
        return "Invalid mobile number";
      }
    }
    return null;
  }

  String? amountValidator(String? input) {
    if (input?.isNotEmpty != true ||
        !RegExp(r'^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$').hasMatch(input!)) {
      return "Invalid double";
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    if (emailRegex.hasMatch(value)) {
      return null;
    } else {
      return "Email is not valid";
    }
  }

  String? validateNewPassword(String? newPassword, String? oldPassword) {
    if (oldPassword == null || oldPassword.isEmpty) {
      return null;
    } else {
      if (newPassword == null || newPassword.isEmpty) {
        return "New password is required";
      } else if (newPassword.length < 8) {
        return "Password should be atleast 8 characters";
      } else if (newPassword.length > 32) {
        return "Password should not be greater than 32 characters";
      } else {
        return null;
      }
    }
  }

  String? validateConfirmPassword(String? confirmPassword, String? newPassword) {
    if (newPassword != null && newPassword.isEmpty) {
      return null;
    } else if (confirmPassword != newPassword) {
      return "Password do not match";
    } else {
      return null;
    }
  }
}
