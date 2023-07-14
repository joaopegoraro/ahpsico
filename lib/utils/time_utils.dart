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
}
