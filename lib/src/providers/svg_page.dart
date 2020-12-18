import 'package:flutter/cupertino.dart';
import 'package:fsm2/fsm2.dart';

class SMCatPage {
  SMCatFile smcatFile;
  GlobalKey key = GlobalKey();

  SMCatPage(this.smcatFile);

  String get pathToSvg => smcatFile.svgPath;
}
