import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fsm2_viewer/src/providers/current_page.dart';
import 'package:fsm2_viewer/src/providers/largest_page.dart';
import 'package:fsm2_viewer/src/providers/mode_provider.dart';
import 'package:fsm2_viewer/src/providers/svg_page_provider.dart';
import 'package:fsm2_viewer/src/providers/svg_reload_provider.dart';
import 'package:fsm2_viewer/src/svg/size.dart';
import '../layout_buttons.dart';

class SVGLayout extends ConsumerWidget {
  SVGLayout();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    int currentPage = watch(currentPageProvider.state);
    final mode = watch(layoutModeProvider.state);
    final largest = watch(largestPageProvider.state);

    if (currentPage == -1) return Text('Please open an smcat file.');

    switch (mode) {
      case Mode.one:
        return oneLayout(context, currentPage, largest);
      case Mode.two:
        return twoLayout(context, currentPage, largest);
      case Mode.twoByTwo:
        return twoByTwoLayout(context, currentPage, largest);
      case Mode.threeByThree:
        return threeByThreeLayout(context, currentPage, largest);
    }
  }

  Widget oneLayout(BuildContext context, int currentPage, Size largest) {
    return svgForPage(context, currentPage, largest);
  }

  Widget twoLayout(BuildContext context, int currentPage, Size largest) {
    final pages = context.read(smcatPageProvider).pages;
    if (pages.length < 2) {
      message(context, "Not available as there is only one page");
      return oneLayout(context, currentPage, largest);
    }

    log('two layout');

    return GridView.count(
        crossAxisCount: 1,
        childAspectRatio: largest.width / largest.height,
        children: addPages(context, 2, currentPage, largest));
  }

  Widget twoByTwoLayout(BuildContext context, int currentPage, Size largest) {
    final pages = context.read(smcatPageProvider).pages;
    if (pages.length < 4) {
      message(context, "Not available as there is less than 4 pages");
      return oneLayout(context, currentPage, largest);
    }

    return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: largest.width / largest.height,
        children: addPages(context, 4, currentPage, largest));
  }

  Widget threeByThreeLayout(
      BuildContext context, int currentPage, Size largest) {
    final pages = context.read(smcatPageProvider).pages;
    if (pages.length < 9) {
      message(context, "Not available as there is less than 9 pages");
      return oneLayout(context, currentPage, largest);
    }

    return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: largest.width / largest.height,
        children: addPages(context, 9, currentPage, largest));
  }

  List<Widget> addPages(
      BuildContext context, int maxPages, int currentPage, Size largest) {
    final pages = context.read(smcatPageProvider).pages;
    List<Widget> selected = <Widget>[];
    var i = currentPage;

    var count = 0;
    while (i < pages.length && count < maxPages) {
      log('adding page $i');
      selected.add(svgForPage(context, i, largest));
      i++;
      count++;
    }
    log('selected');
    return selected;
  }

  Widget svgForPage(BuildContext context, int pageNo, Size largest) {
    double width = MediaQuery.of(context).size.width;
    log('displaying svg: $width, largest: ${largest.width}  height: ${largest.height}');

    return SizedBox(
        width: min(largest.width.toDouble(), width),
        height: largest.height.toDouble(),
        child: ClipRect(child:
            InteractiveViewer(child: Consumer(builder: (context, watch, _) {
          watch(svgReloadProvider.state);
          watch(smcatPageProvider.state);

          PictureProvider.clearCache();
          final pages = context.read(smcatPageProvider).pages;
          final page = pages[pageNo];
          log('rebuilding svg files path: ${page.pathToSvg} key: ${page.key}');

          return SvgPicture.file(File(pages[pageNo].pathToSvg),
              key: page.key,
              placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator()));
        }))));
  }

  void message(context, String text) {
    // scaffoldKey.currentState.hideCurrentSnackBar();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(text),
    );

    Future.delayed(Duration(seconds: 0),
        () => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }
}
