import 'package:formz/formz.dart';

enum OrganisationValidationError { empty }

class Organisation extends FormzInput<String, OrganisationValidationError> {
  const Organisation.pure() : super.pure('');
  const Organisation.dirty([String value = '']) : super.dirty(value);

  @override
  OrganisationValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : OrganisationValidationError.empty;
  }
}
