import 'package:flutter/material.dart';
import '../../dialogs/daterange_picker_dialog.dart';
import '../form_fields.dart';

class DateRangeFilter extends StatefulWidget {
  const DateRangeFilter(this.onDateRangeChanged, {Key? key}) : super(key: key);
  final Function(DateTimeRange)? onDateRangeChanged;
  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  final TextEditingController _dateRangeController =
      TextEditingController(text: dateRangeItems.firstWhere((element) => element.isDefault).label);

  @override
  Widget build(BuildContext context) {
    return AppDropdownField(
      items: _items,
      controller: _dateRangeController,
      prefixIcon: const Icon(Icons.keyboard_arrow_down),
      labelText: '',
      hintText: '',
      onChanged: (value) async {
        var dateRangeFilter = dateRangeItems.firstWhere((element) => element.label == value);

        final dateRange = await dateRangeFilter.getRange(context);
        if (dateRange == null) return;

        _dateRangeController.text = dateRangeFilter.label;
        widget.onDateRangeChanged?.call(dateRange);
      },
    );
  }
}

const List<Map<String, dynamic>> _items = [
  {'label': 'Today', 'value': 'Today'},
  {'label': 'Yesterday', 'value': 'Yesterday'},
  {'label': 'This Week', 'value': 'This Week'},
  {'label': 'Last Week', 'value': 'Last Week'},
  {'label': 'This Month', 'value': 'This Month'},
  {'label': 'Last Month', 'value': 'Last Month'},
  {'label': 'This Year', 'value': 'This Year'},
  {'label': 'Last Year', 'value': 'Last Year'},
  {'label': 'Lifetime', 'value': 'Lifetime'},
  {'label': 'Custom', 'value': 'Custom'},
];

class DateRangeFilterItem {
  DateRangeFilterItem({required this.label, required this.getRange, this.isDefault = false});
  final String label;
  final Future<DateTimeRange?> Function(BuildContext context) getRange;
  bool isDefault;

  @override
  String toString() => 'DateRangeFilterItem (label: $label, getRange: $getRange)';
}

var dateRangeItems = <DateRangeFilterItem>[
  DateRangeFilterItem(
      label: 'Today',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'Yesterday',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day - 1);
        final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'This Week',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day - now.weekday + 1);
        final end = start.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      },
      isDefault: true),
  DateRangeFilterItem(
      label: 'Last Week',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final lastWeekStart = startOfWeek.subtract(const Duration(days: 7));
        final lastWeekEnd = endOfWeek.subtract(const Duration(days: 7));
        return DateTimeRange(
            start: DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day, 0, 0, 0),
            end: DateTime(lastWeekEnd.year, lastWeekEnd.month, lastWeekEnd.day, 23, 59, 59));
      }),
  DateRangeFilterItem(
      label: 'This Month',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'Last Month',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'This Year',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'Last Year',
      getRange: (BuildContext context) async {
        final now = DateTime.now();
        final start = DateTime(now.year - 1, 1, 1);
        final end = DateTime(now.year, 1, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'Lifetime',
      getRange: (BuildContext context) async {
        final start = DateTime.utc(1970);
        final end = DateTime.now();
        return DateTimeRange(start: start, end: end);
      }),
  DateRangeFilterItem(
      label: 'Custom',
      getRange: (BuildContext context) async {
        return await openDateRangePicker(context).then((dateList) =>
            dateList != null ? DateTimeRange(start: dateList.first, end: dateList.last) : null);
      }),
];
