import 'dart:developer' as d;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final logProvider =
    StateNotifierProvider<LogProvider, Logger>((ref) => LogProvider());

class LogProvider extends StateNotifier<Logger> {
  LogProvider() : super(Logger());
}

class Logger {
  Logger();
  String _log = '';

  String get clear => _log = '';

  // ignore: avoid_setters_without_getters
  set log(String message) {
    _log += '$message\n';
    d.log(message);
  }

  String get content => _log;
}
