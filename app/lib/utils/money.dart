/// Splits [totalKurus] into [count] equal shares that add up to the total.
///
/// When the total doesn't divide evenly, the first shares get one kuruş more:
/// `splitEvenly(10000, 3)` returns `[3334, 3333, 3333]`.
List<int> splitEvenly(int totalKurus, int count) {
  if (count <= 0) {
    throw ArgumentError.value(count, 'count', 'must be at least 1');
  }
  final base = totalKurus ~/ count;
  final remainder = totalKurus % count;
  return [for (var i = 0; i < count; i++) i < remainder ? base + 1 : base];
}
