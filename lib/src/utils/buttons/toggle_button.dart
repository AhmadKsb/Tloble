import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({
    @required this.pos,
    @required this.onChanged,
    @required this.label1,
    @required this.label2,
    this.padding,
    Key key,
  }) : super(key: key);

  final EdgeInsets padding;
  final int pos;
  final void Function(int pos) onChanged;
  final String label1, label2;

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  static const double borderRadius = 8.0;

  //bool list containing the state of each togglebutton
  List<bool> enabledList;

  TextStyle get selectedTextStyle {
    return TextStyle(
      fontSize: 14,
      color: Colors.white,
    );
  }

  TextStyle get unSelectedTextStyle {
    return selectedTextStyle.copyWith();
  }

  void changeState(int pos) {
    //only change position of enabled item
    if (!enabledList[pos]) {
      setState(() {
        for (int i = 0; i < enabledList.length; i++) {
          enabledList[i] = !enabledList[i];
        }
      });

      widget.onChanged(enabledList.indexWhere((item) => item == true));
    }
  }

  @override
  void initState() {
    super.initState();
    enabledList = [widget.pos == 0, widget.pos == 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.all(8),
      //Since toggleButton doesn't have a property for changing the bgColor for
      //disabled items, its required to add a color and a radius to the parent container
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      child: ToggleButtons(
        isSelected: enabledList,
        borderRadius: BorderRadius.circular(borderRadius),
        renderBorder: false,
        disabledColor: Colors.grey,
        color: Colors.grey,
        fillColor: Color.fromARGB(255, 210, 34, 49),
        onPressed: changeState,
        children: [
          _ZlToggleButtonChild(
            label: widget.label1,
            textStyle:
                enabledList.first ? selectedTextStyle : unSelectedTextStyle,
          ),
          _ZlToggleButtonChild(
            label: widget.label2,
            textStyle:
                enabledList.last ? selectedTextStyle : unSelectedTextStyle,
          ),
        ],
      ),
    );
  }
}

//Leaving this as a private widget because its only beeing used here.
//Move it to a proper file when necessary
class _ZlToggleButtonChild extends StatelessWidget {
  const _ZlToggleButtonChild({
    Key key,
    this.label,
    this.textStyle,
  }) : super(key: key);
  final String label;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
