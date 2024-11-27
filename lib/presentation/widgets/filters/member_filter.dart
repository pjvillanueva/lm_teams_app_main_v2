import 'package:flutter/material.dart';
import '../../../data/models/member model/member.dart';
import '../../dialogs/checkbox_list_dialog.dart';
import '../form_fields.dart';

class MemberFilter<T extends Member> extends StatefulWidget {
  const MemberFilter(this.members, this.selectedMembers, this.onMembersChanged, {Key? key})
      : super(key: key);
  final List<T> members;
  final List<T> selectedMembers;
  final void Function(List<T>?) onMembersChanged;
  @override
  State<MemberFilter> createState() => _MemberFilterState<T>();
}

class _MemberFilterState<T extends Member> extends State<MemberFilter<T>> {
  @override
  Widget build(BuildContext context) {
    return AppOutlinedTextFormField(
        prefixIcon: Icons.keyboard_arrow_down_outlined,
        readOnly: true,
        enable: widget.members.isNotEmpty,
        controller: TextEditingController(
            text: selectedMembersDropdownLabel(
                members: widget.members.length, selected: widget.selectedMembers.length)),
        onTap: () async {
          var output = await showCheckboxListDialog<T>(
              context: context,
              title: 'Select member(s)',
              allItems: (widget.members).map<CheckboxItemModel<T>>((item) {
                return CheckboxItemModel<T>(
                    payload: item, label: item.name, image: item.user?.image);
              }).toList(),
              selectedItems: widget.selectedMembers.map<CheckboxItemModel<T>>((item) {
                return CheckboxItemModel<T>(
                    payload: item, label: item.name, image: item.user?.image);
              }).toList());
          if (output != null) {
            widget.onMembersChanged.call(output);
          }
        });
  }
}

String selectedMembersDropdownLabel({required int members, required int selected}) {
  if (members == 0) {
    return 'No member';
  } else if (selected == members) {
    return 'All';
  } else {
    return 'Selected $selected';
  }
}
