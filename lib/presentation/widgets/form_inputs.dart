// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:select_form_field/select_form_field.dart';

//Form Title With 32 Font Size
class GenericFormTitle extends StatelessWidget {
  const GenericFormTitle({Key? key, required this.title, required this.subTitle}) : super(key: key);

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 70.0.spMin,
        child: Column(children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 32.spMin,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold),
          ),
          Text(
            subTitle,
            style: TextStyle(
                fontSize: 14.spMin,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: "Roboto"),
          )
        ]));
  }
}

//Form Title With 23 Font Size
class SmallFormTitle extends StatelessWidget {
  const SmallFormTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.0.spMin,
      child: Text(title,
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 23.0.spMin, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
    );
  }
}

//Basic DropDown Select Field
class GenericDropDownInput extends StatelessWidget {
  GenericDropDownInput(
      {Key? key,
      required this.items,
      this.validator,
      required this.labelText,
      this.enabled,
      required this.hintText,
      this.initialValue,
      this.controller,
      this.onChanged})
      : super(key: key);

  final List<Map<String, dynamic>>? items;
  final String? Function(String? value)? validator;
  final String? labelText;
  final bool? enabled;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SelectFormField(
      type: SelectFormFieldType.dropdown,
      validator: validator,
      enabled: enabled ?? true,
      onChanged: onChanged,
      initialValue: initialValue,
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        labelText: labelText,
        hintText: hintText,
      ),
      items: items,
    );
  }
}

//Basic Search Bar
class GenericSearchBar extends StatefulWidget {
  const GenericSearchBar(
      {Key? key, this.onchanged, required this.icon, this.onpressed, this.controller})
      : super(key: key);

  final void Function(String)? onchanged;
  final Widget icon;
  final void Function()? onpressed;
  final TextEditingController? controller;

  @override
  _GenericSearchBarState createState() => _GenericSearchBarState();
}

class _GenericSearchBarState extends State<GenericSearchBar> {
  @override
  Widget build(BuildContext context) {
    return AppOutlinedTextFormField(
        onChanged: widget.onchanged,
        controller: widget.controller,
        hintText: 'Search',
        suffixIcon: SizedBox(
            height: 48.0.spMin,
            width: 48.0.spMin,
            child: IconButton(onPressed: widget.onpressed, icon: widget.icon)));
  }
}

//Basic Divider With Text
class DividerWithText extends StatelessWidget {
  const DividerWithText({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.spMin),
        Row(children: [
          Expanded(child: Divider(color: Theme.of(context).colorScheme.onBackground)),
          SizedBox(width: 5.spMin),
          Text(title, style: TextStyle(fontSize: 16.0.spMin)),
          SizedBox(width: 5.spMin),
          Expanded(
              child: Divider(
            color: Theme.of(context).colorScheme.onBackground,
          )),
        ]),
        SizedBox(height: 12.spMin),
      ],
    );
  }
}

class DividerWithPillTitle extends StatelessWidget {
  const DividerWithPillTitle({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.spMin),
        Row(
          children: [
            Expanded(
                child: Divider(
              color: Theme.of(context).colorScheme.onBackground,
            )),
            SizedBox(width: 5.spMin),
            Container(
                alignment: Alignment.center,
                width: 150.spMin,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(20.0))),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0.spMin, horizontal: 0.0.spMin),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 16.0.spMin,
                        letterSpacing: 3.0.spMin,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )),
            SizedBox(width: 5.spMin),
            Expanded(
                child: Divider(
              color: Theme.of(context).colorScheme.onBackground,
            )),
          ],
        ),
        SizedBox(height: 12.spMin),
      ],
    );
  }
}

class ChipInputField extends StatefulWidget {
  const ChipInputField(
      {Key? key, required this.label, required this.onPressed, required this.children})
      : super(key: key);

  final String label;
  final void Function()? onPressed;
  final List<Widget> children;

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isFocused: false,
      decoration: InputDecoration(
          labelText: widget.label,
          hintText: "",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: widget.onPressed,
          )),
      child: Wrap(
        runSpacing: 10.0,
        spacing: 5.0,
        children: widget.children,
      ),
    );
  }
}

class TagsInputField extends StatefulWidget {
  const TagsInputField(
      {Key? key,
      required this.allTags,
      required this.pickedTags,
      required this.onTap,
      this.errorText})
      : super(key: key);
  final List<String> allTags;
  final List<String> pickedTags;
  final void Function()? onTap;
  final String? errorText;

  @override
  State<TagsInputField> createState() => _TagsInputFieldState();
}

class _TagsInputFieldState extends State<TagsInputField> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: InputDecorator(
            isFocused: false,
            decoration: InputDecoration(
                labelText: "Tags",
                hintText: "",
                border: const OutlineInputBorder(),
                errorText: widget.errorText),
            child: Wrap(
                runSpacing: 10.0,
                spacing: 5.0,
                children: widget.pickedTags
                    .map((tag) => InputChip(
                        label: Text(tag),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        onDeleted: () {
                          setState(() {
                            widget.pickedTags.remove(tag);
                            widget.allTags.add(tag);
                          });
                        }))
                    .toList())),
        onTap: widget.onTap);
  }
}

class GenericNumberInput extends StatefulWidget {
  GenericNumberInput(
      {Key? key,
      required this.controller,
      required this.labelText,
      required this.isDouble,
      this.validator,
      this.readOnly = false})
      : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final bool isDouble;
  final String? Function(String?)? validator;
  bool readOnly;

  @override
  _GenericIntegerOnlyInputState createState() => _GenericIntegerOnlyInputState();
}

class _GenericIntegerOnlyInputState extends State<GenericNumberInput> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: TextFormField(
        validator: widget.validator,
        style: TextStyle(fontSize: 16.0.spMin),
        decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
            suffixIcon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 5.0.spMin, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                          child: Icon(Icons.arrow_drop_up, size: 18.0.spMin),
                          onTap: widget.readOnly == false
                              ? () {
                                  num currentValue;
                                  if (widget.controller.text.isNotEmpty) {
                                    if (widget.isDouble) {
                                      currentValue = double.parse(widget.controller.text);
                                    } else {
                                      currentValue = int.parse(widget.controller.text);
                                    }
                                  } else {
                                    currentValue = 0;
                                  }
                                  currentValue++;
                                  widget.controller.text = currentValue.toString();
                                }
                              : null),
                      InkWell(
                          child: Icon(Icons.arrow_drop_down, size: 18.0.spMin),
                          onTap: widget.readOnly == false
                              ? () {
                                  num currentValue;
                                  if (widget.controller.text.isNotEmpty) {
                                    if (widget.isDouble) {
                                      currentValue = double.parse(widget.controller.text);
                                    } else {
                                      currentValue = int.parse(widget.controller.text);
                                    }
                                  } else {
                                    currentValue = 0;
                                  }
                                  currentValue--;
                                  widget.controller.text =
                                      (currentValue > 0 ? currentValue : 0).toString();
                                }
                              : null)
                    ]))),
        readOnly: widget.readOnly,
        controller: widget.controller,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.isDouble),
        inputFormatters: widget.isDouble
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,1}')),
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ]
            : [FilteringTextInputFormatter.digitsOnly],
      ))
    ]);
  }
}

class SwitchButtonFormField extends StatefulWidget {
  const SwitchButtonFormField({
    Key? key,
    required this.labelText,
    required this.trackStock,
    this.onChanged,
  }) : super(key: key);

  final String labelText;
  final bool trackStock;
  final void Function(bool)? onChanged;

  @override
  State<SwitchButtonFormField> createState() => _SwitchButtonFormFieldState();
}

class _SwitchButtonFormFieldState extends State<SwitchButtonFormField> {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: widget.labelText, border: const OutlineInputBorder()),
      child: SizedBox(
        height: 18,
        child: Row(children: [
          Switch(
              value: widget.trackStock,
              activeColor: Theme.of(context).colorScheme.secondary,
              onChanged: widget.onChanged),
          Text(widget.trackStock ? "yes" : "no")
        ]),
      ),
    );
  }
}

class UserGroupDropdownField extends StatelessWidget {
  UserGroupDropdownField(
      {Key? key,
      this.items,
      this.enabled,
      required this.controller,
      required this.labelText,
      this.onChanged})
      : super(key: key);

  final List<Map<String, dynamic>>? items;
  final bool? enabled;
  final TextEditingController controller;
  final String labelText;
  void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SelectFormField(
        type: SelectFormFieldType.dropdown,
        items: items,
        enabled: enabled ?? true,
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14.0.spMin, overflow: TextOverflow.ellipsis),
        decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down, size: 24.0.spMin),
            suffixIconConstraints: BoxConstraints.expand(width: 24.0.spMin, height: 24.0.spMin),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 16.0.spMin),
            contentPadding: EdgeInsets.only(bottom: 10.spMin),
            hintText: ''));
  }
}

class DateRangeFormField extends StatefulWidget {
  const DateRangeFormField({
    Key? key,
    this.onPressed,
    required this.controller,
    this.validator,
  }) : super(key: key);

  final void Function()? onPressed;
  final TextEditingController controller;
  final String? Function(String? value)? validator;

  @override
  State<DateRangeFormField> createState() => _DateRangeFormFieldState();
}

class _DateRangeFormFieldState extends State<DateRangeFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      validator: widget.validator,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Dates',
          hintText: 'Set event duration',
          suffixIcon:
              IconButton(icon: const Icon(Icons.calendar_month), onPressed: widget.onPressed)),
    );
  }
}

class CodeInputBox extends StatelessWidget {
  CodeInputBox({Key? key, required this.controller}) : super(key: key);

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 45.spMin,
        height: 80.spMin,
        child: TextFormField(
            decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ''),
            style: TextStyle(fontSize: 30.0.spMin, fontWeight: FontWeight.bold),
            maxLength: 2,
            controller: controller));
  }
}
