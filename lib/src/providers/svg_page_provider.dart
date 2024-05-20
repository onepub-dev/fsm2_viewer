import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2/fsm2.dart';

import 'largest_page.dart';
import 'svg_page.dart';

final smcatPageProvider = StateNotifierProvider<SMCatPageProvider, SMCatPages>(
    SMCatPageProvider.new);

class SMCatPageProvider extends StateNotifier<SMCatPages> {
  SMCatPageProvider(Ref ref) : super(SMCatPages(ref));

  SMCatPages get pages => state;
}

class SMCatPages {

  SMCatPages(this.ref);
  List<SMCatPage> pages = <SMCatPage>[];
  Ref ref;

  int get length => pages.length;

  void loadPages(List<SMCatFile> smcatFiles) {
    pages = <SMCatPage>[];

    for (final smcatFile in smcatFiles) {
      pages.add(SMCatPage(smcatFile));
    }

    log('#########################Loaded pages:');
    log('pagecount = ${pages.length}');

    ref.read(largestPageProvider).update(smcatFiles);
  }

  void add(SMCatFile smcatFile) {
    final page = SMCatPage(smcatFile);
    pages.add(page);

    log('Added page: ${page.pathToSvg} key: ${page.key}');
    log('pagecount = ${pages.length}');
  }

  void remove(SMCatFile svgFile) {
    for (final page in pages) {
      if (page.pathToSvg == svgFile.pathTo) {
        pages.remove(page);
        break;
      }
    }
  }

  void replace(SMCatFile svgFile) {
    log('replacing ${svgFile.pathTo}');
    final location = find(svgFile);

    final page = SMCatPage(svgFile);
    log('Replacing page: ${page.pathToSvg} new key: ${page.key} index: $location');

    if (location != -1) {
      pages..removeAt(location)
      ..insert(location, page);
    } else {
      pages.add(page);
    }
  }

  int find(SMCatFile smcatFile) {
    var found = false;
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
