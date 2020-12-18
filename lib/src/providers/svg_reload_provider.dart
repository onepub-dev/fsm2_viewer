import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final svgReloadProvider = StateNotifierProvider((ref) => SvgReloadProvider());

/// Used to indicate that svg files need to be reloaded.
class SvgReloadProvider extends StateNotifier<bool> {
  SvgReloadProvider() : super(true);

  set reload(bool reload) {
    log('svgreload provider set to $reload');
    state = reload;
  }

  bool get reload => state;
}
