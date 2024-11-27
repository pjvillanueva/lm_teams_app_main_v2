import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Future<DateTime?> openDatePicker(BuildContext context,
    [DateTime? datePicked, bool? enablePastDates]) async {
  return await showDialog(
      context: context,
      builder: (_) {
        return AppDialog(title: '', contents: [
          SizedBox(
              height: 300.spMin,
              width: 400.spMin,
              child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  confirmText: 'SAVE',
                  selectionMode: DateRangePickerSelectionMode.single,
                  enablePastDates: enablePastDates ?? true,
                  initialSelectedDate: datePicked,
                  showActionButtons: true,
                  showNavigationArrow: true,
                  onSubmit: (value) => Navigator.pop(context, value),
                  onCancel: () => Navigator.pop(context)))
        ]);
      });
}
