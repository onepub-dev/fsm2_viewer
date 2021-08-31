import 'package:flutter/material.dart';

enum Mode { one, two, twoByTwo, threeByThree }

class LayoutButtons extends StatefulWidget {
  LayoutButtons();

  @override
  State<StatefulWidget> createState() => _LayoutButtonsState();
}

class _LayoutButtonsState extends State<LayoutButtons> {
  Mode mode = Mode.one;

  @override
  Widget build(BuildContext context) {
    var modes = <Widget>[];

    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: Text(
          'Layout:',
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.black,
          ),
        )));

    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: ElevatedButton(
            onPressed: () => modeOne(),
            child: Text('1'),
            style: selected(Mode.one))));
    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: ElevatedButton(
            onPressed: () => modeTwo(),
            child: Text('2'),
            style: selected(Mode.two))));
    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: ElevatedButton(
            onPressed: () => modeTwoByTo(),
            child: Text('2x2'),
            style: selected(Mode.twoByTwo))));
    modes.add(Padding(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: ElevatedButton(
            onPressed: () => modeThreeByThree(),
            child: Text('3x3'),
            style: selected(Mode.threeByThree))));
    return Row(children: modes);
  }

  void modeOne() {
    setState(() {
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

  ButtonStyle selected(Mode buttonMode) {
    //log('mode: $buttonMode');
    var color = (mode == buttonMode ? Colors.blue : Colors.grey);
    // log('color: $color');

    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color));
  }
}
