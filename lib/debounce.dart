import 'dart:async';

class Debounce {
  Duration delay;
  Timer? _timer;

  Debounce({required this.delay});

  call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  dispose() {
    _timer?.cancel();
  }
}