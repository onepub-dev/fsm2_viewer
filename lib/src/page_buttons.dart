import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2_viewer/src/providers/current_page.dart';
import 'package:fsm2_viewer/src/providers/log_provider.dart';

import 'providers/svg_page_provider.dart';

class PageButtons extends ConsumerWidget {
  
  PageButtons();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final pages = watch(smcatPageProvider.state);
    /// watch the currentPageProvider so we are rebuilt when the page
    /// no changes.
    int currentPage = watch(currentPageProvider.state);
    log('building PageButons currentPage: $currentPage');
    if (pages.length == 0) {
      return Container(width: 0, height: 0);
    }


    currentPage = min(currentPage, pages.length - 1);

    var buttons = <Widget>[];
    for (var pageNo = 0; pageNo < pages.length; pageNo++) {
      buttons.add(Padding(
          padding: EdgeInsets.only(right: 5, left: 5),
          child: RaisedButton(
              color: (pageNo == currentPage ? Colors.blue : Colors.grey),
              onPressed: () {
                if (pageNo == 0) context.read(logProvider).clear;

                /// User click the page button so update the current page.
                context.read(currentPageProvider).currentPage = pageNo;
                context.read(logProvider).log = 'onpressed';
                context.read(logProvider).log = 'changed to page $pageNo';
              },
              child: Text('${pageNo + 1}'))));
    }
    return Row(children: buttons);
  }
}
