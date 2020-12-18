import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2/fsm2.dart';
import 'largest_page.dart';
import 'svg_page.dart';

final smcatPageProvider =
    StateNotifierProvider((ref) => SMCatPageProvider(ref));

class SMCatPageProvider extends StateNotifier<List<SMCatPage>> {
  final ProviderReference ref;
  SMCatPageProvider(this.ref) : super(<SMCatPage>[]);

  set pages(List<SMCatPage> pages) => state = pages;

  List<SMCatPage> get pages => state;

  void loadPages(List<SMCatFile> svgs) {
    var pages = <SMCatPage>[];

    for (final svgFile in svgs) {
      pages.add(SMCatPage(svgFile));
    }

    log('#########################Replaced pages:');
    log('pagecount = ${pages.length}');

    state = pages;

    ref.read(largestPageProvider).update(svgs);
  }

  void add(SMCatFile smcatFile) {
    var pages = state;
    final page = SMCatPage(smcatFile);
    pages.add(page);
    state = pages;

    log('Added page: ${page.pathToSvg} key: ${page.key}');
    log('pagecount = ${pages.length}');
  }

  void remove(SMCatFile svgFile) {
    var pages = state;

    for (final page in pages) {
      if (page.pathToSvg == svgFile.pathTo) {
        pages.remove(page);
        break;
      }
    }

    state = pages;
  }

  void replace(SMCatFile svgFile) {
    log('replacing ${svgFile.pathTo}');
    var location = find(svgFile);

    var pages = state;
    final page = SMCatPage(svgFile);
    log('Replacing page: ${page.pathToSvg} new key: ${page.key} index: $location');

    if (location != -1) {
      pages.removeAt(location);
      pages.insert(location, page);
    } else {
      pages.add(page);
    }
    state = pages;
  }

  int find(SMCatFile smcatFile) {
    bool found = false;
    var index = 0;
    for (final page in pages) {
      if (page.pathToSvg == smcatFile.svgPath) {
        found = true;
        break;
      }
      index++;
    }
    return found ? index : -1;
  }
}
