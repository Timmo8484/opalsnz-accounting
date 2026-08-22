// NZ standard balance date: 1 April - 31 March.
class TaxYear {
  static DateTime startFor(DateTime date) => date.month >= 4
      ? DateTime(date.year, 4, 1)
      : DateTime(date.year - 1, 4, 1);

  static DateTime endFor(DateTime date) {
    final start = startFor(date);
    return DateTime(start.year + 1, 3, 31);
  }

  static (DateTime start, DateTime end) current() {
    final now = DateTime.now();
    return (startFor(now), endFor(now));
  }
}
