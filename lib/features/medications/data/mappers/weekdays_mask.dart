/// Converts weekdays ([DateTime.monday]..[DateTime.sunday]) to a bitmask
/// where bit 0 is Monday and bit 6 is Sunday, and back.
abstract final class WeekdaysMask {
  static int encode(Set<int> weekdays) =>
      weekdays.fold(0, (mask, day) => mask | (1 << (day - 1)));

  static Set<int> decode(int mask) => {
    for (var day = DateTime.monday; day <= DateTime.sunday; day++)
      if (mask & (1 << (day - 1)) != 0) day,
  };
}
