import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

// ignore: import_of_legacy_library_into_null_safe
// import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsm2/fsm2.dart' hide State;
import 'package:path/path.dart' as p;
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

import 'src/layout_buttons.dart';
import 'src/page_buttons.dart';
import 'src/providers/current_page.dart';
import 'src/providers/log_provider.dart';
import 'src/providers/svg_page_provider.dart';
import 'src/providers/svg_reload_provider.dart';
import 'src/svg/size.dart' as s;
import 'src/svg/svg_layout.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
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
        home: const MyHomePage(title: 'FSM2 SMCAT Viewer'),
      );
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({required this.title, super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  late SMCatFolder _smcatFolder;

  GlobalKey scaffoldKey = GlobalKey();

  final largest = s.Size(0, 0);

  int currentPage = -1;

  String logBuffer = '';

  final debugging = false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GlobalKey<State<StatefulWidget>>>(
          'scaffoldKey', scaffoldKey))
      ..add(IntProperty('currentPage', currentPage))
      ..add(StringProperty('logBuffer', logBuffer))
      ..add(DiagnosticsProperty<bool>('debugging', debugging))
      ..add(DiagnosticsProperty<s.Size>('largest', largest));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            children: <Widget>[
              PlutoMenuBar(
                menus: getMenus(ref),
              ),
              const LayoutButtons(),
              const Expanded(child: SVGLayout()),
              const PageButtons(),
              buildDebugPanel(context)
            ],
          ),
        ),
      );

  Widget buildDebugPanel(BuildContext context) => debugging
      ? Consumer(builder: (context, watch, _) {
          final content = watch.read(logProvider).content;
          return SizedBox(
              height: 100, child: SingleChildScrollView(child: Text(content)));
        })
      : const SizedBox.shrink();

  List<PlutoMenuItem> getMenus(WidgetRef ref) => [
        PlutoMenuItem(
          title: 'File',
          icon: Icons.home,
          children: [
            PlutoMenuItem(
              title: 'Open',
              icon: Icons.open_in_new,
              onTap: () async => openFile(ref),
            ),
            PlutoMenuItem(
              title: 'Close',
              onTap: () => exit(1),
            ),
          ],
        ),
      ];

  // void _message(WidgetRef widgetRef, String text) {
  //   // scaffoldKey.currentState.hideCurrentSnackBar();
  //   ScaffoldMessenger.of(widgetRef.context).hideCurrentSnackBar();

  //   final snackBar = SnackBar(
  //     content: Text(text),
  //   );

  //   Future.delayed(Duration.zero,
  //       () => ScaffoldMessenger.of(widgetRef.context).showSnackBar(snackBar));
  // }

  Future<void> openFile(WidgetRef widgetRef) async {
    final selectedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['smcat']);
    if (selectedFile == null) {
      log('User cancelled the file open');
      return;
    }
    if (selectedFile.count == 0) {
      return;
    }

    final pathToSelected = selectedFile.files[0].path!;
    _smcatFolder = SMCatFolder(
        folderPath: p.dirname(pathToSelected),
        basename: SMCatFolder.getBasename(pathToSelected));
    await _smcatFolder.generateAll(force: true);

    final smcatFile = SMCatFile(pathToSelected);

    widgetRef.read(smcatPageProvider).loadPages(_smcatFolder.list);

    widgetRef.read(currentPageProvider).pageNo = max(0, smcatFile.pageNo - 1);

    await WatchFolder(
            pathTo: _smcatFolder.folderPath,
            extension: 'smcat',
            onChanged: (file, action) async => reload(widgetRef, file, action))
        .watch();
  }

  // int _compareFile(SvgFile lhs, SvgFile rhs) => lhs.pageNo - rhs.pageNo;

  Future<void> reload(
    WidgetRef ref,
    String file,
    FolderChangeAction action,
  ) async {
    log('reloading smcat files');

    final pageProvider = ref.read(smcatPageProvider);
    await _smcatFolder.generateAll(force: true);

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

    ref.read(svgReloadProvider).reload = true;
  }
}
