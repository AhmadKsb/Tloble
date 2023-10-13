class JsonParser {
  static double parseDouble(num value) {
    if (value != null) return value.toDouble();
    return null;
  }

  static int parseInt(num value) {
    return (value ?? 0).toInt();
  }

  static DateTime parseDate(num value, [bool inSeconds = false]) {
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
        inSeconds ? value * 1000 : value);
  }

  static DateTime parseStringDate(String value) {
    DateTime dt;
    if (value != null)
      try {
        dt = DateTime.parse(value);
        return dt;
      } catch (e) {
        print('errorParsingJsonDate $e');
      }
    return null;
  }
}
