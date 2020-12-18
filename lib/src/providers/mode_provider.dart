import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../layout_buttons.dart';

final layoutModeProvider = StateNotifierProvider((ref) => LayoutModeProvider());

class LayoutModeProvider extends StateNotifier<Mode> {
  LayoutModeProvider() : super(Mode.one);

  set mode(Mode mode) => state = mode;

  Mode get mode => state;
}
