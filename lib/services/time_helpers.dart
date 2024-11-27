import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_object.dart';

class TimeService {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat monthNameAbv = DateFormat('MMM');
  final DateFormat monthName = DateFormat('MMMM');

  //return string version of the given date
  String formatRelativeDate(DateTime date) {
    DateTime givenDate = date.ymdOnly;
    DateTime today = DateTime.now().ymdOnly;
    int daysDifference = givenDate.difference(today).inDays;

    if (daysDifference == 0) {
      return "Today";
    } else if (daysDifference == 1) {
      return "Tomorrow";
    } else if (daysDifference == -1) {
      return "Yesterday";
    } else if (daysDifference > 1 && daysDifference < 7) {
      return "Next " + getWeekdayName(date.weekday);
    } else if (daysDifference < -1 && daysDifference > -7) {
      return " " + getWeekdayName(date.weekday);
    } else {
      return formatter.format(givenDate);
    }
  }

  String getWeekdayName(int weekday) {
    List<String> weekdayNames = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];
    return weekdayNames[weekday - 1];
  }

  String statisticsDateRangeFilter(DateTime date, StatisticsDateRangeContext rangeFilter) {
    switch (rangeFilter) {
      case StatisticsDateRangeContext.day:
        if (date.isToday) {
          return 'Today';
        } else if (date.isYesterday) {
          return 'Yesterday';
        } else {
          if (date.isThisWeek) {
            return DateFormat('EEEE').format(date);
          } else if (date.isLastWeek) {
            var dayName = DateFormat('EEEE').format(date);
            return 'last ' + dayName;
          } else {
            return formatter.format(date);
          }
        }
      case StatisticsDateRangeContext.week:
        if (date.isThisWeek) {
          return 'This week';
        } else if (date.isLastWeek) {
          return 'Last week';
        } else {
          return 'Week ' + date.weekNumber.toString();
        }
      case StatisticsDateRangeContext.month:
        if (date.isThisMonth) {
          return 'This month';
        } else {
          if (date.isThisYear) {
            return monthName.format(date);
          } else {
            return monthNameAbv.format(date) + ', ' + date.year.toString();
          }
        }
      case StatisticsDateRangeContext.year:
        if (date.isThisYear) {
          return 'This year';
        } else {
          return date.year.toString();
        }
    }
  }

  String dateToString(DateTime date) {
    return formatter.format(date);
  }

  DateTime stringToDate(String dateString) {
    return formatter.parse(dateString);
  }

  String timeToString(DateTime date) {
    final DateFormat _formatter = DateFormat.jm();
    return _formatter.format(date);
  }
}
//to use this extension paste this path on the file:
// import 'package:lm_teams_app/services/time_helpers.dart';

extension DateHelpers on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    return now.weekNumber == weekNumber;
  }

  bool get isLastWeek {
    final now = DateTime.now();
    final lastWeekNumber = now.weekNumber - 1;
    return lastWeekNumber == weekNumber;
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return now.month == month && now.year == year;
  }

  bool get isThisYear {
    final now = DateTime.now();
    return now.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day && yesterday.month == month && yesterday.year == year;
  }

  bool get isTommorow {
    final tommorow = DateTime.now().add(const Duration(days: 1));
    return tommorow.day == day && tommorow.month == month && tommorow.year == year;
  }

  //return the end of the given date
  DateTime get beforeMidnight {
    return DateTime(year, month, day, 23, 59);
  }

  int get weekNumber {
    return Jiffy(DateTime(year, month, day)).week;
  }

  //return the start of this day
  DateTime get lastMidnight {
    return DateTime(year, month, day);
  }

  //return date with only year, month, date
  DateTime get ymdOnly {
    return DateTime(year, month, day);
  }

  // return elapsed time as string
  String get timeAgo {
    return Jiffy(this).fromNow();
  }

  DateTime get nextMonth {
    return Jiffy(this).add(months: 1).dateTime;
  }

  DateTime get nextYear {
    return Jiffy(this).add(years: 1).dateTime;
  }

  String get simplified {
    return Jiffy(this).yMMMd;
  }

  String get timeOnly {
    return Jiffy(this).jm;
  }
}
