import 'package:flutter/foundation.dart';
import 'dart:async';

/// Delays the execution of an action.
class Debouncer {
  static const defaultDuration = Duration(milliseconds: 300);

  final Duration? duration;
  Timer? _timer;

  Debouncer({this.duration});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) _timer!.cancel();
    _timer = Timer(duration ?? defaultDuration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
