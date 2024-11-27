import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Future<List<DateTime>?> openDateRangePicker(BuildContext context,
    [DateTime? startDate, DateTime? endDate]) async {
  return await showDialog(
      context: context,
      builder: (_) {
        List<DateTime>? dateRange;
        return AppDialog(title: '', contents: [
          SizedBox(
              height: 300.spMin,
              width: 300.spMin,
              child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  confirmText: 'SAVE',
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(startDate, endDate),
                  showActionButtons: true,
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    if (args.value.startDate != null && args.value.endDate != null) {
                      dateRange = [args.value.startDate, args.value.endDate];
                    } else {
                      dateRange = null;
                    }
                  },
                  onSubmit: (value) => Navigator.pop(context, dateRange),
                  onCancel: () => Navigator.pop(context)))
        ]);
      });
}
