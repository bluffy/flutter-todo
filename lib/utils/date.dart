import 'package:intl/intl.dart';

class DateTool {
  static String fromISO(String? isoDate, {String? format}) {
    var localformat = "dd.MM.yyyy HH:mm:ss";
    if (format != null) {
      localformat = format;
    }

    DateFormat dateFormat = DateFormat(localformat);

    if (isoDate == null) {
      return dateFormat.format(DateTime.now());
    }

    return dateFormat.format(DateTime.parse(isoDate));
  }
}
