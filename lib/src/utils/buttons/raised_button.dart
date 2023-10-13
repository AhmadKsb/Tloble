import 'package:flutter/material.dart';

class RaisedButtonV2 extends StatelessWidget {
  const RaisedButtonV2({
    @required this.onPressed,
    this.labelStyle,
    this.isLoading = false,
    this.label,
    this.disabled = false,
    this.disabledColor,
    this.green = false,
  });

  @required
  final Function onPressed;
  final String label;
  final bool disabled;
  final Color disabledColor;
  final bool isLoading;
  final bool green;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      key: Key('raised_${label}'),
      elevation: disabled ? 0.0 : null,
      padding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: getHorizontalPadding(context),
        ),
        decoration: BoxDecoration(
          color: disabledColor ?? Colors.grey,
          borderRadius: BorderRadius.circular(8),
          gradient: disabled
              ? null
              : green
                  ? LinearGradient(
                      colors: [
                        Color.fromARGB(255, 76, 187, 23),
                        Color.fromARGB(255, 50, 205, 50),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    )
                  : LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 210, 34, 49)),
                    ),
                  )
                : Text(
                    label ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ).merge(labelStyle),
                  ),
          ],
        ),
      ),
      onPressed: (disabled ?? false)
          ? null
          : isLoading
              ? () {}
              : onPressed,
    );
  }

  double getHorizontalPadding(BuildContext context) {
    double _horizontalPadding;
    var size = MediaQuery.of(context).size;
    if (size.width > 400)
      _horizontalPadding = 54;
    else
      _horizontalPadding = 36;
    return _horizontalPadding;
  }
}
