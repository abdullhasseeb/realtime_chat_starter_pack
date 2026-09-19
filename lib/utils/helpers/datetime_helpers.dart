/// ----------------------[Date Time Helpers]----------------------
///
/// Central place for all date/time formatting used across the app.
/// Add new formats here — never inline DateTime logic in widgets.
class UPDateTimeHelpers {
  UPDateTimeHelpers._();

  /// Conversation / chat list timestamp  (WhatsApp style)
  ///  - Today      → "14:32"
  ///  - This week  → "Mon"
  /// - Older      → "12/05/25"
  static String conversationTime(DateTime time) {
    final now = DateTime.now();
    final local = time.toLocal();

    final diff = DateTime(now.year, now.month, now.day).difference(DateTime(local.year, local.month, local.day)).inDays;

    if (diff == 0) return bubbleTime(local);
    if (diff < 7) return _weekday(local);
    return _shortDate(local);
  }

  /// Chat bubble timestamp
  ///  - Always "14:32"
  static String bubbleTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Chat date separator  ("Today", "Yesterday", "Mon 24 Feb", "12/05/25")
  static String dateSeparator(DateTime time) {
    final now = DateTime.now();
    final local = time.toLocal();

    final diff = DateTime(now.year, now.month, now.day).difference(DateTime(local.year, local.month, local.day)).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${_weekday(local)} ${local.day} ${_monthName(local.month)}';
    return _shortDate(local);
  }

  /// -------------[PrivateHelpers]-------------
  static String _weekday(DateTime t) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[t.weekday - 1];
  }

  static String _shortDate(DateTime t) {
    final d = t.day.toString().padLeft(2, '0');
    final m = t.month.toString().padLeft(2, '0');
    final y = t.year.toString().substring(2);
    return '$d/$m/$y';
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  static bool isDifferentDay(DateTime a, DateTime b){
    bool isDifferent = a.year != b.year || a.month != b.month || a.day != b.day;
    return isDifferent;
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(date.year, date.month, date.day);

    final diff = today.difference(messageDay).inDays;

    if (messageDay == today) return 'Today';
    if (messageDay == yesterday) return 'Yesterday';
    if (diff < 7) return _dayName(date.weekday); // Mon, Tue...
    return _fullDate(date); // 27 Mar 2026
  }

  static String _dayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  static String _fullDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatMessageTime(DateTime time){
    final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
