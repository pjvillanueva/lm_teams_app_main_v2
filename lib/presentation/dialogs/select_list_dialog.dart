import 'package:flutter/material.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/filters/date_range_filter.dart';

enum ListItemType { phone, user, reminder, dateRange }

Future<T> showListSelectOneDialog<T>({
  required BuildContext context,
  String? title,
  Color? backgroundColor,
  double? width,
  required List<T> items,
  required ListItemType type,
}) async {
  return await showDialog(
      context: context,
      builder: (_) {
        return AppDialog(title: title ?? '', contents: [
          SizedBox(
              width: width ?? 300.0.spMin,
              child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 5.0.spMin);
                  },
                  itemBuilder: (context, int index) {
                    var item = items[index];

                    switch (type) {
                      case ListItemType.phone:
                        var _item = item as String;
                        return _makeTiles(
                            context: context,
                            leading: Icon(Icons.phone, size: 24.0.spMin),
                            title: Text(_item, style: TextStyle(fontSize: 16.0.spMin)),
                            onTap: () {
                              Navigator.pop(context, item);
                            });
                      case ListItemType.user:
                        var _item = item as User;
                        return _makeTiles(
                            context: context,
                            leading: Icon(Icons.person, size: 24.0.spMin),
                            title: Text(_item.name, style: TextStyle(fontSize: 16.0.spMin)),
                            onTap: () {
                              Navigator.pop(context, item);
                            });
                      case ListItemType.reminder:
                        var _reminder = item as Reminder;
                        return ReminderListTile(
                            reminder: _reminder,
                            trailingIcon: Icons.person,
                            onPressedTrailing: () {
                              Navigator.pop(context, _reminder);
                            });
                      case ListItemType.dateRange:
                        var _range = item as DateRangeFilterItem;
                        return _makeTiles(
                            context: context,
                            title: Text(_range.label, style: TextStyle(fontSize: 16.0.spMin)),
                            onTap: () {
                              Navigator.pop(context, _range);
                            });
                    }
                  }))
        ]);
      });
}

ListTile _makeTiles(
    {required BuildContext context, Widget? leading, Widget? title, Function()? onTap}) {
  return ListTile(
      tileColor: Theme.of(context).colorScheme.surface,
      leading: leading,
      minLeadingWidth: 30.0.spMin,
      title: title,
      onTap: onTap);
}
