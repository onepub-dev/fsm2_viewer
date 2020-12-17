import 'dart:io';
import 'dart:math';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';
import 'package:path/path.dart' as p;

import 'package:fsm2/fsm2.dart' hide State;

import 'src/svg/size.dart' as s;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      home: MyHomePage(title: 'FSM2 SVG Viewer'),
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

  var pages = <SvgFile>[];

  var currentPage = -1;

  String logBuffer = '';

  var largest = s.Size(0, 0);

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
            getModeButtons(),
            Expanded(child: getSvgLayout(context)),
            Row(children: getButtons()),
            buildDebugPanel()
          ],
        ),
      ),
    );
  }

  Widget buildDebugPanel() {
    return debugging
        ? SizedBox(
            height: 100, child: SingleChildScrollView(child: Text(logBuffer)))
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
            onTap: () => openFile(),
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

  void openFile() async {
    FilePickerCross selectedFile = await FilePickerCross.importFromStorage(
        type: FileTypeCross.any, fileExtension: 'svg');

    _smcatFolder = SMCatFolder(
        folderPath: p.dirname(selectedFile.path),
        basename: SMCatFolder.getBasename(selectedFile.path));

    var svgFile = SvgFile(selectedFile.path);

    pages.clear();
    pages.addAll(_smcatFolder.listSvgs);

    findLargestPage();

    // if (svgFile.pageNo == 0) {
    //   pages.add(svgFile);
    // } else {
    //   // we have multiple files.
    //   var files = await Directory(p.dirname(svgFile.pathTo)).list().toList();
    //   var svgFiles = files.where((entity) {
    //     //   getBasename(entity.path) == basename &&
    //     // log('extenions ${p.extension(entity.path)}');
    //     return p.extension(entity.path) == '.svg';
    //   }).toList();

    //   // log('found ${svgFiles.length} svg files');

    //   pages.sort((lhs, rhs) => compareFile(lhs, rhs));
    // }

    setState(() {
      currentPage = svgFile.pageNo - 1;
    });

//     watchDirectory(p.dirname(selectedFile.path), onChanged: () => reload());
    WatchFolder(
        pathTo: _smcatFolder.folderPath,
        extension: 'svg',
        onChanged: (file, action) => reload(file, action));
  }

  List<Widget> getButtons() {
    if (pages.length == 0) {
      return [Container(width: 0, height: 0)];
    }

    var buttons = <Widget>[];
    for (var pageNo = 0; pageNo < pages.length; pageNo++) {
      buttons.add(Padding(
          padding: EdgeInsets.only(right: 5, left: 5),
          child: RaisedButton(
              color: (pageNo == currentPage ? Colors.blue : Colors.grey),
              onPressed: () {
                showPage(pageNo);
              },
              child: Text('${pageNo + 1}'))));
    }
    return buttons;
  }

  void showPage(int pageNo) {
    setState(() {
      currentPage = pageNo;
    });
  }

  void log(String message) {
    setState(() {
      logBuffer += message + '\n';
    });
  }

  int compareFile(SvgFile lhs, SvgFile rhs) {
    return lhs.pageNo - rhs.pageNo;
  }

  Widget getModeButtons() {
    var modes = <Widget>[];

    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: RaisedButton(
            onPressed: () => modeOne(),
            child: Text('1'),
            color: selected(Mode.one))));
    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: RaisedButton(
            onPressed: () => modeTwo(),
            child: Text('2'),
            color: selected(Mode.two))));
    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: RaisedButton(
            onPressed: () => modeTwoByTo(),
            child: Text('2x2'),
            color: selected(Mode.twoByTwo))));
    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: RaisedButton(
            onPressed: () => modeThreeByThree(),
            child: Text('3x3'),
            color: selected(Mode.threeByThree))));
    return Row(children: modes);
  }

  Mode mode = Mode.one;
  void modeOne() {
    setState(() {
      logBuffer = '';
      mode = Mode.one;
    });
  }

  void modeTwo() {
    setState(() => mode = Mode.two);
  }

  void modeTwoByTo() {
    setState(() => mode = Mode.twoByTwo);
  }

  void modeThreeByThree() {
    setState(() => mode = Mode.threeByThree);
  }

  Widget getSvgLayout(BuildContext context) {
    if (currentPage == -1) return Text('Please open an svg file.');

    switch (mode) {
      case Mode.one:
        return oneLayout(context);
        break;
      case Mode.two:
        return twoLayout(context);
        break;
      case Mode.twoByTwo:
        return twoByTwoLayout(context);
        break;
      case Mode.threeByThree:
        return threeByThreeLayout(context);
        break;
    }

    return oneLayout(context);
  }

  Widget oneLayout(BuildContext context) {
    return svgForPage(currentPage);
  }

  Widget twoLayout(BuildContext context) {
    if (pages.length < 2) {
      message(context, "Not available as there is only one page");
      return oneLayout(context);
    }

    log('two layout');

    return GridView.count(
        crossAxisCount: 1,
        childAspectRatio: largest.width / largest.height,
        children: addPages(2));
  }

  Widget twoByTwoLayout(BuildContext context) {
    if (pages.length < 4) {
      message(context, "Not available as there is less than 4 pages");
      return oneLayout(context);
    }

    return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: largest.width / largest.height,
        children: addPages(4));
  }

  Widget threeByThreeLayout(BuildContext context) {
    if (pages.length < 9) {
      message(context, "Not available as there is less than 9 pages");
      return oneLayout(context);
    }

    return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: largest.width / largest.height,
        children: addPages(9));
  }

  Widget svgForPage(int pageNo) {
    double width = MediaQuery.of(context).size.width;
    log('scree: $width, largest: ${largest.width}  height: ${largest.height}');
    return SizedBox(
        width: min(largest.width.toDouble(), width),
        height: largest.height.toDouble(),
        child: SvgPicture.file(File(pages[pageNo].pathTo)));
  }

  Color selected(Mode buttonMode) {
    //log('mode: $buttonMode');
    var color = (mode == buttonMode ? Colors.blue : Colors.grey);
    // log('color: $color');
    return color;
  }

  List<Widget> addPages(int maxPages) {
    List<Widget> selected = <Widget>[];
    var i = currentPage;

    var count = 0;
    while (i < pages.length && count < maxPages) {
      log('adding page $i');
      selected.add(svgForPage(i));
      i++;
      count++;
    }
    log('selected');
    return selected;
  }

  void findLargestPage() {
    for (var svgFile in _smcatFolder.listSvgs) {
      if (svgFile.height > largest.height) {
        largest.height = svgFile.height;
      }
      if (svgFile.width > largest.width) {
        largest.width = svgFile.width;
      }
    }
  }

  void reload(String file, FolderChangeAction action) {
    setState(() {
      switch (action) {
        case FolderChangeAction.create:
          pages.add(SvgFile(file));
          break;
        case FolderChangeAction.modify:
          break;
        case FolderChangeAction.move:
          break;
        case FolderChangeAction.delete:
          pages.remove(SvgFile(file));
          break;
      }
    });
  }
}

enum Mode { one, two, twoByTwo, threeByThree }

// class SelectedButton extends StatefulWidget
// {
//   @override
//   State<StatefulWidget> createState() {
//     return
//   }

// }
