import 'dart:developer' as d;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final logProvider = StateNotifierProvider((ref) => LogProvider());

class LogProvider extends StateNotifier<String> {
  LogProvider() : super('');

  get clear => state = '';

  set log(String message) {
    state = state += message + '\n';
    d.log(message);
  }

  String get content => state;
}
