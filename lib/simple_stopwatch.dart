/// A simple wrapper for Dart's Stopwatch with convenient methods.
class SimpleStopwatch {
  final Stopwatch _stopwatch = Stopwatch();
  Duration get elapsed => _stopwatch.elapsed;
  bool get isRunning => _stopwatch.isRunning;

  void start() => _stopwatch.start();
  void stop() => _stopwatch.stop();
  void reset() => _stopwatch.reset();
}
