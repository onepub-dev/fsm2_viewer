import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentPageProvider =
    StateNotifierProvider<CurrentPageProvider, CurrentPage>(
        (_) => CurrentPageProvider());

class CurrentPageProvider extends StateNotifier<CurrentPage> {
  CurrentPageProvider() : super(CurrentPage());

  CurrentPage get currentPage => state;
}

class CurrentPage {
  CurrentPage();
  int _pageNo = -1;

  set pageNo(int page) {
    log('currentPage set to $page');
    _pageNo = page;
  }

  int get pageNo => _pageNo;
}
