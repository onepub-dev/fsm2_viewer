import 'package:flutter/cupertino.dart';
import 'package:fsm2/fsm2.dart';

class SMCatPage {

  SMCatPage(this.smcatFile);
  SMCatFile smcatFile;
  GlobalKey key = GlobalKey();

  String get pathToSvg => smcatFile.svgPath;
}
