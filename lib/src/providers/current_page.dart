import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentPageProvider = StateNotifierProvider((ref) => CurrentPage());

class CurrentPage extends StateNotifier<int> {
  CurrentPage() : super(-1);

  set currentPage(int page) {
    log('currentPage set to $page');
    state = page;
  }

  int get currentPage => state;
}
