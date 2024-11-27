import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AppOutlinedTextFormField extends StatelessWidget {
  const AppOutlinedTextFormField(
      {Key? key,
      this.enable,
      this.readOnly,
      this.initialValue,
      this.onChanged,
      this.labelText,
      this.hintText,
      this.validator,
      this.textCapitalization,
      this.keyboardType,
      this.maxLength,
      this.maxLines,
      this.errorText,
      this.controller,
      this.width,
      this.prefixIcon,
      this.suffixIcon,
      this.filled,
      this.onTap})
      : super(key: key);

  final bool? enable;
  final bool? readOnly;
  final String? initialValue;
  final Function(String value)? onChanged;
  final String? labelText;
  final String? hintText;
  final String? Function(String? value)? validator;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final String? errorText;
  final TextEditingController? controller;
  final double? width;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool? filled;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: TextFormField(
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: keyboardType,
            enabled: enable ?? true,
            readOnly: readOnly ?? false,
            maxLength: maxLength,
            maxLines: maxLines ?? 1,
            initialValue: initialValue,
            onChanged: onChanged,
            validator: validator,
            controller: controller,
            style: TextStyle(fontSize: 16.0.spMin),
            onTap: onTap,
            decoration: InputDecoration(
                prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 24.0.spMin) : null,
                suffixIcon: suffixIcon,
                counterText: "",
                border: const OutlineInputBorder(),
                labelText: labelText,
                filled: filled,
                labelStyle: TextStyle(fontSize: 16.spMin),
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 16.0.spMin),
                alignLabelWithHint: true,
                errorText: errorText,
                errorStyle: TextStyle(fontSize: 12.0.spMin, height: 0.3.spMin),
                contentPadding: EdgeInsets.symmetric(vertical: 20.spMin, horizontal: 12.spMin))));
  }
}

class AppPasswordInput extends StatefulWidget {
  const AppPasswordInput({
    Key? key,
    this.onChange,
    required this.labelText,
    required this.hintText,
    this.enabled,
    this.validator,
    this.errorText,
    this.controller,
    this.width,
  }) : super(key: key);

  final Function(String value)? onChange;
  final String labelText;
  final String hintText;
  final bool? enabled;
  final String? Function(String? value)? validator;
  final String? errorText;
  final TextEditingController? controller;
  final double? width;

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: TextFormField(
            onChanged: widget.onChange,
            obscureText: isHidden,
            enabled: widget.enabled,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
            controller: widget.controller,
            style: TextStyle(fontSize: 16.0.spMin),
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.labelText,
                labelStyle: TextStyle(fontSize: 16.spMin),
                hintText: widget.hintText,
                hintStyle: TextStyle(fontSize: 16.0.spMin),
                errorText: widget.errorText,
                errorStyle: TextStyle(fontSize: 12.0.spMin, height: 0.3.spMin),
                contentPadding: EdgeInsets.symmetric(vertical: 20.spMin, horizontal: 12.spMin),
                suffixIcon: IconButton(
                    icon: isHidden
                        ? Icon(Icons.visibility_off, size: 24.0.spMin)
                        : Icon(Icons.visibility, size: 24.0.spMin),
                    onPressed: () {
                      setState(() {
                        isHidden = !isHidden;
                      });
                    }))));
  }
}

// ignore: must_be_immutable
class AppDropdownField extends StatelessWidget {
  AppDropdownField(
      {Key? key,
      required this.items,
      this.validator,
      this.autovalidate,
      required this.labelText,
      this.enabled,
      required this.hintText,
      this.initialValue,
      this.controller,
      this.onChanged,
      this.width,
      this.prefixIcon})
      : super(key: key);

  final List<Map<String, dynamic>>? items;
  final String? Function(String? value)? validator;
  final bool? autovalidate;
  final String? labelText;
  final bool? enabled;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  void Function(String)? onChanged;
  final double? width;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: SelectFormField(
          type: SelectFormFieldType.dropdown,
          validator: validator,
          autovalidate: autovalidate ?? false,
          enabled: enabled ?? true,
          onChanged: onChanged,
          initialValue: initialValue,
          controller: controller,
          style: TextStyle(fontSize: 16.0.spMin),
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: prefixIcon,
              suffixIcon: prefixIcon == null ? Icon(Icons.arrow_drop_down, size: 24.0.spMin) : null,
              labelText: labelText,
              labelStyle: TextStyle(fontSize: 16.spMin),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 16.0.spMin),
              contentPadding: EdgeInsets.symmetric(vertical: 20.spMin, horizontal: 12.spMin)),
          items: items,
        ));
  }
}

// ignore: must_be_immutable
class SelectAccountRoleField extends StatefulWidget {
  SelectAccountRoleField(
      {Key? key, required this.labelText, required this.selectedOption, required this.onChanged})
      : super(key: key);

  final String labelText;
  AccountRole selectedOption;
  final void Function(AccountRole) onChanged;

  @override
  State<SelectAccountRoleField> createState() => _SelectAccountRoleFieldState();
}

class _SelectAccountRoleFieldState extends State<SelectAccountRoleField> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
        width: double.infinity,
        height: width > 600 ? null : 200.0.spMin,
        child: InputDecorator(
            decoration:
                InputDecoration(labelText: widget.labelText, border: const OutlineInputBorder()),
            child: Flex(direction: width > 600 ? Axis.horizontal : Axis.vertical, children: [
              Flexible(
                  flex: 1,
                  child: CheckboxListTile(
                      value: widget.selectedOption.name == 'owner',
                      title: Text('Owner', style: TextStyle(fontSize: 16.0.spMin)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          widget.selectedOption =
                              value != null ? AccountRole.owner : AccountRole.le;
                        });
                        widget.onChanged(value != null ? AccountRole.owner : AccountRole.le);
                      })),
              Flexible(
                  flex: 1,
                  child: CheckboxListTile(
                      value: widget.selectedOption.name == 'admin',
                      title: Text('Administrator', style: TextStyle(fontSize: 16.0.spMin)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          widget.selectedOption =
                              value != null ? AccountRole.admin : AccountRole.le;
                        });
                        widget.onChanged(value != null ? AccountRole.admin : AccountRole.le);
                      })),
              Flexible(
                  flex: 1,
                  child: CheckboxListTile(
                      value: widget.selectedOption.name == 'le',
                      title: Text('Literature Evangelist', style: TextStyle(fontSize: 16.0.spMin)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          widget.selectedOption = value != null ? AccountRole.le : AccountRole.le;
                        });
                        widget.onChanged(AccountRole.le);
                      }))
            ])));
  }
}

// ignore: must_be_immutable
class AccountRoleCheckBoxField extends StatefulWidget {
  AccountRoleCheckBoxField(
      {Key? key, required this.labelText, required this.accountRole, required this.onChanged})
      : super(key: key);

  final String labelText;
  AccountRole accountRole;
  void Function(AccountRole) onChanged;

  @override
  State<AccountRoleCheckBoxField> createState() => _AccountRoleCheckBoxFieldState();
}

class _AccountRoleCheckBoxFieldState extends State<AccountRoleCheckBoxField> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
        width: double.infinity,
        height: width > 600 ? null : 200.0.spMin,
        child: InputDecorator(
            decoration:
                InputDecoration(labelText: widget.labelText, border: const OutlineInputBorder()),
            child: Flex(direction: width > 600 ? Axis.horizontal : Axis.vertical, children: [
              Flexible(
                  flex: 1,
                  child: CheckboxListTile(
                      value: widget.accountRole.name == 'owner',
                      title: Text('Owner', style: TextStyle(fontSize: 16.0.spMin)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          widget.accountRole = AccountRole.owner;
                        });
                        widget.onChanged.call(AccountRole.owner);
                      })),
              Flexible(
                  flex: 1,
                  child: CheckboxListTile(
                      value: widget.accountRole.name == 'admin',
                      title: Text('Administrator', style: TextStyle(fontSize: 16.0.spMin)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          widget.accountRole = AccountRole.admin;
                        });
                        widget.onChanged.call(AccountRole.admin);
                      })),
              Flexible(
                  flex: 1,
                  child: CheckboxListTile(
                      value: widget.accountRole.name == 'le',
                      title: Text('Literature Evangelist', style: TextStyle(fontSize: 16.0.spMin)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          widget.accountRole = AccountRole.le;
                        });
                        widget.onChanged.call(AccountRole.le);
                      }))
            ])));
  }
}

class AppOutlinedPhoneNumberInput extends StatefulWidget {
  const AppOutlinedPhoneNumberInput({
    Key? key,
    this.updateController,
    this.initialPhoneNumber,
    this.labelText,
    this.suffixIcon,
    this.isEnabled = true,
    this.isRequired = true,
  }) : super(key: key);

  final void Function(String?)? updateController;
  final String? initialPhoneNumber;
  final String? labelText;
  final Widget? suffixIcon;
  final bool isEnabled;
  final bool isRequired;

  @override
  State<AppOutlinedPhoneNumberInput> createState() => _AppOutlinedPhoneNumberInputState();
}

class _AppOutlinedPhoneNumberInputState extends State<AppOutlinedPhoneNumberInput> {
  PhoneNumber initialValue = PhoneNumber(isoCode: 'AU');

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null) {
      _parseInitialPhoneNumber(widget.initialPhoneNumber!);
    }
  }

  Future<void> _parseInitialPhoneNumber(String phoneNumber) async {
    try {
      var phoneNumberObject = await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
      setState(() {
        initialValue = phoneNumberObject;
      });
    } catch (e) {
      // Handle exception or leave initialValue as null
    }
  }

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
        isEnabled: widget.isEnabled,
        onInputChanged: (value) {
          if (value.phoneNumber != null) {
            widget.updateController?.call(value.phoneNumber);
          }
        },
        selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.DIALOG,
            trailingSpace: false,
            setSelectorButtonAsPrefixIcon: true,
            leadingPadding: 10.0),
        ignoreBlank: !widget.isRequired,
        spaceBetweenSelectorAndTextField: 5.0,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        textStyle: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface),
        selectorTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16.0),
        initialValue: initialValue,
        formatInput: false,
        inputDecoration: InputDecoration(
            border: const OutlineInputBorder(),
            disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            labelText: widget.labelText ?? 'Phone Number',
            labelStyle: const TextStyle(fontSize: 16.0),
            suffixIcon: widget.isEnabled ? widget.suffixIcon : null));
  }
}

class PinInputField extends StatefulWidget {
  const PinInputField({Key? key, required this.pinLength, required this.pinController})
      : super(key: key);

  final int pinLength;
  final TextEditingController pinController;

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  List<String> pinValues = [];
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    for (int i = 0; i < widget.pinLength; i++) {
      focusNodes.add(FocusNode());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 400.spMin,
        height: 200.spMin,
        child: Card(
            color: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(),
            child: Padding(
              padding: EdgeInsets.all(20.0.spMin),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    height: 80.0.spMin,
                    child: GridView.builder(
                        itemCount: widget.pinLength,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.pinLength,
                            childAspectRatio: 0.5,
                            mainAxisSpacing: 10.spMin,
                            crossAxisSpacing: 10.spMin),
                        itemBuilder: (context, index) {
                          return TextFormField(
                              style: TextStyle(fontSize: 30.spMin, fontWeight: FontWeight.bold),
                              maxLength: 1,
                              focusNode: focusNodes[index],
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(), counterText: ''),
                              onChanged: (value) {
                                if (value.length == 1 && index < focusNodes.length - 1) {
                                  setState(() {
                                    pinValues.add(value);
                                  });
                                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                                } else {
                                  setState(() {
                                    pinValues.remove(value);
                                  });
                                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                                }
                              });
                        })),
                SizedBox(height: 20.0.spMin),
                ElevatedButton(
                    onPressed: () {
                      print(pinValues);
                    },
                    child: const Text('SUBMIT'))
              ]),
            )));
  }
}

// ignore: must_be_immutable
class AppNumberInputField extends StatefulWidget {
  AppNumberInputField({Key? key, required this.controller, this.readOnly = false, this.onChanged})
      : super(key: key);

  TextEditingController controller = TextEditingController();
  bool? readOnly;
  void Function()? onChanged;

  @override
  State<AppNumberInputField> createState() => _AppNumberInputFieldState();
}

class _AppNumberInputFieldState extends State<AppNumberInputField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 180.spMin,
        height: 40.spMin,
        child: TextFormField(
            controller: widget.controller,
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.spMin),
            keyboardType: TextInputType.number,
            readOnly: widget.readOnly ?? false,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
            onChanged: (value) => widget.onChanged?.call(),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                focusColor: Theme.of(context).colorScheme.secondary,
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                prefixIcon: Visibility(
                    visible: !widget.readOnly!,
                    child: Container(
                        width: 40.spMin,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border: Border.all(color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0.spMin),
                                bottomLeft: Radius.circular(5.0.spMin))),
                        child: IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              double currentValue = double.tryParse(widget.controller.text) ?? 0;
                              if (currentValue != 0.0) {
                                setState(() {
                                  widget.controller.text = (currentValue - 1).toString();
                                });
                              }
                              widget.onChanged?.call();
                            }))),
                suffixIcon: Visibility(
                    visible: !widget.readOnly!,
                    child: Container(
                        width: 40.spMin,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border: Border.all(color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5.0.spMin),
                                bottomRight: Radius.circular(5.0.spMin))),
                        child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                double currentValue = double.tryParse(widget.controller.text) ?? 0;
                                widget.controller.text = (currentValue + 1).toString();
                              });
                              widget.onChanged?.call();
                            }))))));
  }
}
