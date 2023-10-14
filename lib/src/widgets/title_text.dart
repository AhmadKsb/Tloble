import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleText extends StatelessWidget {
  final String? text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextStyle? style;

  const TitleText({
    Key? key,
    this.text,
    this.fontSize = 18,
    this.color = LightColor.titleTextColor,
    this.textAlign = TextAlign.start,
    this.fontWeight = FontWeight.w800,
    this.style,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 2,
      textAlign: textAlign,
      style: style ??
          GoogleFonts.mulish(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
    );
  }
}
