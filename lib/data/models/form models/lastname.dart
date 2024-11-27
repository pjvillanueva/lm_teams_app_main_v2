import 'package:formz/formz.dart';

enum LastnameValidationError { empty }

class LastName extends FormzInput<String, LastnameValidationError> {
  const LastName.pure() : super.pure('');
  const LastName.dirty([String value = '']) : super.dirty(value);

  @override
  LastnameValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : LastnameValidationError.empty;
  }
}
