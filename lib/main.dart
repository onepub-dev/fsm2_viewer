import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2_viewer/src/providers/log_provider.dart';
import 'package:fsm2_viewer/src/providers/svg_page_provider.dart';
import 'package:fsm2_viewer/src/providers/svg_reload_provider.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';
import 'package:path/path.dart' as p;

import 'package:fsm2/fsm2.dart' hide State;

import 'src/layout_buttons.dart';
import 'src/page_buttons.dart';
import 'src/providers/current_page.dart';
import 'src/svg/svg_layout.dart';

import 'src/svg/size.dart' as s;

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'FSM2 SMCAT Viewer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SMCatFolder _smcatFolder;

  GlobalKey scaffoldKey = GlobalKey();

  final largest = s.Size(0, 0);

  var currentPage = -1;

  String logBuffer = '';

  final debugging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            PlutoMenuBar(
              menus: getMenus(context),
            ),
            LayoutButtons(),
            Expanded(child: SVGLayout()),
            PageButtons(),
            buildDebugPanel(context)
          ],
        ),
      ),
    );
  }

  Widget buildDebugPanel(BuildContext context) {
    return debugging
        ? Consumer(builder: (context, watch, _) {
            final content = watch(logProvider.state);
            return SizedBox(
                height: 100,
                child: SingleChildScrollView(child: Text(content)));
          })
        : Container(width: 0, height: 0);
  }

  List<MenuItem> getMenus(BuildContext context) {
    return [
      MenuItem(
        title: 'File',
        icon: Icons.home,
        children: [
          MenuItem(
            title: 'Open',
            icon: Icons.open_in_new,
            onTap: () => openFile(context),
          ),
          MenuItem(
            title: 'Close',
            onTap: () => exit(1),
          ),
        ],
      ),
    ];
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

  void openFile(BuildContext context) async {
    try {
      FilePickerCross selectedFile = await FilePickerCross.importFromStorage(
          type: FileTypeCross.any, fileExtension: 'smcat');

      _smcatFolder = SMCatFolder(
          folderPath: p.dirname(selectedFile.path),
          basename: SMCatFolder.getBasename(selectedFile.path));
      await _smcatFolder.generateAll();

      var smcatFile = SMCatFile(selectedFile.path);

      context.read(smcatPageProvider).loadPages(_smcatFolder.list);

      context.read(currentPageProvider).currentPage =
          max(0, smcatFile.pageNo - 1);

      WatchFolder(
          pathTo: _smcatFolder.folderPath,
          extension: 'smcat',
          onChanged: (file, action) async =>
              await reload(context, file, action)).watch();
    } on FileSelectionCanceledError catch (_) {
      log('User cancelled the file open');
    }
  }

  int compareFile(SvgFile lhs, SvgFile rhs) {
    return lhs.pageNo - rhs.pageNo;
  }

  Future<void> reload(
    BuildContext context,
    String file,
    FolderChangeAction action,
  ) async {
    log('reloading smcat files');

    var pageProvider = context.read(smcatPageProvider);
    await _smcatFolder.generateAll();

    switch (action) {
      case FolderChangeAction.create:
        pageProvider.add(SMCatFile(file));
        break;
      case FolderChangeAction.modify:
        pageProvider.replace(SMCatFile(file));
        break;
      case FolderChangeAction.move:
        break;
      case FolderChangeAction.delete:
        pageProvider.remove(SMCatFile(file));
        break;
    }

    context.read(svgReloadProvider).reload = true;
  }
}
