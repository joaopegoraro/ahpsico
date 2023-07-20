import 'dart:io';

import 'package:intl/intl.dart';

final class TimeUtils {
  const TimeUtils._();

  static String formatDateWithOffset(DateTime date, String pattern) {
    String twoDigits(int n) => n >= 10 ? "$n" : "0$n";

    var hours = twoDigits(date.timeZoneOffset.inHours.abs());
    var minutes = twoDigits(date.timeZoneOffset.inMinutes.remainder(60));
    var sign = date.timeZoneOffset.inHours > 0 ? "+" : "-";
    var formattedDate = DateFormat(pattern).format(date);

    return "$formattedDate$sign$hours:$minutes";
  }

  static bool areDatesSameDay(DateTime first, DateTime second) {
    final sameYear = first.year == second.year;
    final sameMonth = first.month == second.month;
    final sameDay = first.day == second.day;
    return sameYear && sameMonth && sameDay;
  }

  static String getReadableDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    final dayDifference = date.difference(now).inDays;
    if (TimeUtils.areDatesSameDay(date, yesterday)) return "Ontem";
    if (TimeUtils.areDatesSameDay(date, now)) return "Hoje";
    if (TimeUtils.areDatesSameDay(date, tomorrow)) return "Amanhã";
    if (dayDifference > 1 && dayDifference <= 6) {
      // "Segunda-feira"
      return DateFormat('EEEE').format(date).split('-').first;
    }
    return DateFormat.MMMMEEEEd(Platform.localeName).format(date); // "sábado, 25 de maio"
  }

  static String getDateAsHours(DateTime date) {
    return DateFormat.Hm().format(date);
  }
}
