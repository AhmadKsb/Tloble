import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color enabledColor;
  final Color disabledColor;

  const ToggleSwitch({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.enabledColor,
    this.disabledColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color enabledColor = this.enabledColor ?? Colors.green;
    final Color disabledColor = this.disabledColor ?? Colors.grey;
    return GestureDetector(
      onTap: onChanged == null
          ? null
          : () {
              onChanged(!value);
            },
      child: SizedBox(
        width: 40,
        height: 20,
        child: Stack(
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: value ? enabledColor : disabledColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedAlign(
              alignment: Alignment(value ? 1 : -1, 0),
              duration: Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
