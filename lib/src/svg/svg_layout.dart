import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../layout_buttons.dart';
import '../providers/current_page.dart';
import '../providers/largest_page.dart';
import '../providers/mode_provider.dart';
import '../providers/svg_page_provider.dart';
import '../providers/svg_reload_provider.dart';
import 'size.dart';

class SVGLayout extends ConsumerWidget {
  const SVGLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider).pageNo;
    final mode = ref.watch(layoutModeProvider.notifier).mode;
    final largest = ref.watch(largestPageProvider).largestPage;

    if (currentPage == -1) {
      return const Text('Please open an smcat file.');
    }

    switch (mode) {
      case Mode.one:
        return oneLayout(context, ref, currentPage, largest);
      case Mode.two:
        return twoLayout(context, ref, currentPage, largest);
      case Mode.twoByTwo:
        return twoByTwoLayout(context, ref, currentPage, largest);
      case Mode.threeByThree:
        return threeByThreeLayout(context, ref, currentPage, largest);
    }
  }

  Widget oneLayout(
          BuildContext context, WidgetRef ref, int currentPage, Size largest) =>
      svgForPage(context, ref, currentPage, largest);

  Widget twoLayout(
      BuildContext context, WidgetRef ref, int currentPage, Size largest) {
    final pages = ref.read(smcatPageProvider).pages;
    if (pages.length < 2) {
      message(context, 'Not available as there is only one page');
      return oneLayout(context, ref, currentPage, largest);
    }

    log('two layout');

    return GridView.count(
        crossAxisCount: 1,
        childAspectRatio: largest.width / largest.height,
        children: addPages(context, ref, 2, currentPage, largest));
  }

  Widget twoByTwoLayout(
      BuildContext context, WidgetRef ref, int currentPage, Size largest) {
    final pages = ref.read(smcatPageProvider).pages;
    if (pages.length < 4) {
      message(context, 'Not available as there is less than 4 pages');
      return oneLayout(context, ref, currentPage, largest);
    }

    return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: largest.width / largest.height,
        children: addPages(context, ref, 4, currentPage, largest));
  }

  Widget threeByThreeLayout(
      BuildContext context, WidgetRef ref, int currentPage, Size largest) {
    final pages = ref.read(smcatPageProvider).pages;
    if (pages.length < 9) {
      message(context, 'Not available as there is less than 9 pages');
      return oneLayout(context, ref, currentPage, largest);
    }

    return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: largest.width / largest.height,
        children: addPages(context, ref, 9, currentPage, largest));
  }

  List<Widget> addPages(BuildContext context, WidgetRef ref, int maxPages,
      int currentPage, Size largest) {
    final pages = ref.read(smcatPageProvider).pages;
    final selected = <Widget>[];
    var i = currentPage;

    var count = 0;
    while (i < pages.length && count < maxPages) {
      log('adding page $i');
      selected.add(svgForPage(context, ref, i, largest));
      i++;
      count++;
    }
    log('selected');
    return selected;
  }

  Widget svgForPage(
      BuildContext context, WidgetRef ref, int pageNo, Size largest) {
    final width = MediaQuery.of(context).size.width;
    log('displaying svg: $width, largest: ${largest.width}  height: ${largest.height}');

    return SizedBox(
        width: min(largest.width.toDouble(), width),
        height: largest.height.toDouble(),
        child: ClipRect(child:
            InteractiveViewer(child: Consumer(builder: (context, watch, _) {
          ref
            ..watch(svgReloadProvider.notifier)
            ..watch(smcatPageProvider.notifier);

          svg.cache.clear();
          final pages = ref.read(smcatPageProvider).pages;
          final page = pages[pageNo];
          log('rebuilding svg files path: ${page.pathToSvg} key: ${page.key}');

          return SvgPicture.file(File(pages[pageNo].pathToSvg),
              key: page.key,
              placeholderBuilder: (context) => Container(
                  padding: const EdgeInsets.all(30),
                  child: const CircularProgressIndicator()));
        }))));
  }

  void message(BuildContext context, String text) {
    // scaffoldKey.currentState.hideCurrentSnackBar();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(text),
    );

    Future.delayed(Duration.zero,
        () => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }
}
