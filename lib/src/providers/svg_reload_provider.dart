import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final svgReloadProvider = StateNotifierProvider<SvgReloadProvider, SvgReloader>(
    (ref) => SvgReloadProvider(SvgReloader()));

/// Used to indicate that svg files need to be reloaded.
class SvgReloadProvider extends StateNotifier<SvgReloader> {
  SvgReloadProvider(super.state);
}

class SvgReloader {
  SvgReloader();
  bool _reload = true;

  set reload(bool reload) {
    log('svgreload provider set to $reload');
    _reload = reload;
  }

  bool get reload => _reload;
}
