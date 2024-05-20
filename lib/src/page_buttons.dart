import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/current_page.dart';
import 'providers/log_provider.dart';
import 'providers/svg_page_provider.dart';

class PageButtons extends ConsumerWidget {
  const PageButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(smcatPageProvider.notifier).pages;

    /// watch the currentPageProvider so we are rebuilt when the page
    /// no changes.
    var currentPage =
        ref.watch(currentPageProvider.notifier).currentPage.pageNo;
    log('building PageButons currentPage: $currentPage');
    if (pages.length == 0) {
      return const SizedBox.shrink();
    }

    currentPage = min(currentPage, pages.length - 1);

    final buttons = <Widget>[];
    for (var pageNo = 0; pageNo < pages.length; pageNo++) {
      buttons.add(Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      pageNo == currentPage ? Colors.blue : Colors.grey)),
              onPressed: () {
                if (pageNo == 0) {
                  ref.read(logProvider).clear;
                }

                /// User click the page button so update the current page.
                ref.read(currentPageProvider).pageNo = pageNo;
                ref.read(logProvider).log = 'onpressed';
                ref.read(logProvider).log = 'changed to page $pageNo';
              },
              child: Text('${pageNo + 1}'))));
    }
    return Row(children: buttons);
  }
}
