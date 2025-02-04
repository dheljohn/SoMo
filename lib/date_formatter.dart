String formatTimestamp(DateTime current, DateTime? previous) {
  if (previous != null &&
      current.day == previous.day &&
      current.month == previous.month &&
      current.year == previous.year) {
    return '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';
  } else {
    return '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')} ${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';
  }
}
