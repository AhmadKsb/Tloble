import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/string_helper_extension.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';

class RaisedButtonV2 extends StatelessWidget {
  const RaisedButtonV2({
    required this.onPressed,
    this.labelStyle,
    this.isLoading = false,
    this.label,
    this.disabled = false,
    this.disabledColor,
    this.green = false,
    this.backgroundColor,
  });

  @required
  final Function onPressed;
  final String? label;
  final bool disabled;
  final Color? disabledColor;
  final bool isLoading;
  final bool green;
  final TextStyle? labelStyle;
  final MaterialStateProperty<Color?>? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (disabled)
          ? null
          : isLoading
              ? () {} // Provide an empty function for the case where isLoading is true.
              : () {
                  // Call onPressed function here.
                  onPressed();
                },
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        backgroundColor: backgroundColor ??
            MaterialStateProperty.all<Color>((disabled && !isLoading)
                ? (disabledColor ?? Colors.grey)
                : green ? Colors.green : LightColor.orange),
      ),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 4),
        width: AppTheme.fullWidth(context) * .75,
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
                        LightColor.orange,
                      ),
                    ),
                  )
                : TitleText(
                    text: label?.capitalize ?? '',
                    color: LightColor.background,
                    fontWeight: FontWeight.w500,
                  ),
          ],
        ),
      ),
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
