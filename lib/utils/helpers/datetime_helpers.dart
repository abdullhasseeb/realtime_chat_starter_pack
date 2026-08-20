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
}
