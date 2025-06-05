class SimpleStopwatch {
  late Stopwatch _stopwatch;

  SimpleStopwatch() {
    _stopwatch = Stopwatch();
  }

  void start() => _stopwatch.start();

  void stop() => _stopwatch.stop();

  void reset() => _stopwatch.reset();

  bool get isRunning => _stopwatch.isRunning;

  Duration get elapsed => _stopwatch.elapsed;
}
