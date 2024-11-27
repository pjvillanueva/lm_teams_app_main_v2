// ignore_for_file: file_names
import 'package:formz/formz.dart';

enum AccountCodeValidationError { empty }

class AccountCode extends FormzInput<String, AccountCodeValidationError> {
  const AccountCode.pure() : super.pure('');
  const AccountCode.dirty([String value = '']) : super.dirty(value);

  @override
  AccountCodeValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : AccountCodeValidationError.empty;
  }
}
