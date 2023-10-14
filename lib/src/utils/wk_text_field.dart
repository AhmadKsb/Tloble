import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WKTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final String? labelText;
  final bool? obscureText;
  final TextEditingController? controller;
  final bool? autocorrect;
  final bool? isDense;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool? autofocus;
  final bool? enableInteractiveSelection;
  final GestureTapCallback? onTap;
  final bool? enabled;
  final TextAlign? textAlign;
  final String? errorText;
  final String? counterText;
  final String? helperText;
  final bool? expanded;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlignVertical? textAlignVertical;
  final Widget? suffix;
  final double? radius;
  final bool? enableSuggestions;
  final Color? fillColor;
  final bool? noBorder;
  final double? hintTextSize;
  final Color? outlineColor;
  final double? borderRadius;
  final bool? hasDefaultStyle;
  final TextDirection? textDirection;
  final TextStyle? style;

  const WKTextField({
    Key? key,
    this.focusNode,
    this.onChanged,
    this.maxLength,
    this.onSubmitted,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.textInputAction,
    this.autocorrect = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
    this.autofocus = false,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.enabled,
    this.isDense,
    this.textAlign = TextAlign.start,
    this.errorText,
    this.counterText,
    this.helperText,
    this.expanded = false,
    this.hasDefaultStyle = true,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding,
    this.textAlignVertical,
    this.suffix,
    this.radius = 4,
    this.enableSuggestions = true,
    this.fillColor,
    this.noBorder = false,
    this.hintTextSize = 16,
    this.outlineColor,
    this.borderRadius = 5,
    this.textDirection,
    this.style,
  })  : assert(textAlign != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key('zl_textfield'),
      textDirection: textDirection ??
          (Localizations.localeOf(context).languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr),
      focusNode: focusNode,
      expands: this.expanded ?? false,
      controller: controller,
      autocorrect: autocorrect ?? false,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      textAlign: textAlign ?? TextAlign.start,
      textAlignVertical: textAlignVertical,
      style: style,
      obscureText: obscureText ?? false,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black54,
          fontSize: hintTextSize,
        ),
        hintMaxLines: 3,
        counterText: "",
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: hintTextSize,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: prefixIcon,
        suffix: suffix,
        contentPadding: contentPadding,
        errorText: errorText,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
      ),
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      autofocus: autofocus ?? false,
      enableInteractiveSelection: enableInteractiveSelection,
      onTap: onTap,
      enableSuggestions: enableSuggestions ?? true,
    );
  }
}
