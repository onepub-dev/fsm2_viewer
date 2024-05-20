import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Mode { one, two, twoByTwo, threeByThree }

class LayoutButtons extends StatefulWidget {
  const LayoutButtons({super.key});

  @override
  State<StatefulWidget> createState() => _LayoutButtonsState();
}

class _LayoutButtonsState extends State<LayoutButtons> {
  Mode mode = Mode.one;

  @override
  Widget build(BuildContext context) {
    final modes = <Widget>[
      const Padding(
          padding: EdgeInsets.only(right: 5, left: 5),
          child: Text(
            'Layout:',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          )),
      Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: ElevatedButton(
              onPressed: modeOne,
              style: selected(Mode.one),
              child: const Text('1'))),
      Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: ElevatedButton(
              onPressed: modeTwo,
              style: selected(Mode.two),
              child: const Text('2'))),
      Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: ElevatedButton(
              onPressed: modeTwoByTo,
              style: selected(Mode.twoByTwo),
              child: const Text('2x2'))),
      Padding(
          padding: const EdgeInsets.only(right: 5, left: 5),
          child: ElevatedButton(
              onPressed: modeThreeByThree,
              style: selected(Mode.threeByThree),
              child: const Text('3x3')))
    ];
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
    final color = (mode == buttonMode ? Colors.blue : Colors.grey);
    // log('color: $color');

    return ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(color));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Mode>('mode', mode));
  }
}
