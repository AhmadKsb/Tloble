import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';

class InputDropdown extends StatelessWidget {
  const InputDropdown({
    Key key,
    this.label,
    this.child,
    this.hintText,
    this.valueText,
    this.onPressed,
    this.isValueCentered = false,
    this.enabled = true,
    this.suffix,
    this.labelSize = 20,
    this.valueSize = 16,
    this.twoLinesValue = false,
    this.showArrow = true,
    this.icon,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    this.showIconWhenValueSet = false,
  }) : super(key: key);

  final String label;
  final String hintText;
  final String valueText;
  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;
  final Widget suffix;
  final double labelSize;
  final double valueSize;
  final bool twoLinesValue;
  final bool showArrow;
  final bool isValueCentered;
  final Widget icon;
  final EdgeInsets contentPadding;
  final bool showIconWhenValueSet;

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: Colors.blue,
          width: 0.5,
        ),
      );

  @override
  Widget build(BuildContext context) {
    String value = valueText;

    if (isNotEmpty(value) && twoLinesValue)
      value = valueText?.replaceFirst(',', ',\n') ?? '';

    final Color primaryColor = Theme.of(context).textTheme.bodyText2.color;

    final TextStyle labelStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.green);
    final TextStyle valueStyle = TextStyle() ??
        Theme.of(context).inputDecorationTheme.hintStyle.copyWith(
              color: primaryColor,
              fontSize: valueSize,
            );

    List<Widget> trailingChildren = [];
    if (suffix != null) {
      trailingChildren.add(suffix);
    }

    if (showArrow) {
      trailingChildren.add(
        Icon(Icons.keyboard_arrow_down,
            color: Theme.of(context).brightness == Brightness.light
                ? enabled
                    ? Colors.teal
                    : Colors.grey.shade400
                : Colors.white70),
      );
    }

    Widget trailing = Row(children: trailingChildren);

    bool showIcon = icon != null;

    if (showIconWhenValueSet) {
      showIcon = showIcon && isNotEmpty(value);
    }

    return InkWell(
      highlightColor: !enabled ? Colors.transparent : null,
      radius: !enabled ? 0 : null,
      onTap: enabled ? onPressed : null,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: contentPadding,
          fillColor: enabled ? null : Theme.of(context).scaffoldBackgroundColor,
          hintText: hintText,
          hintStyle: valueStyle,
          enabled: enabled,
          border: _border,
          focusedBorder: _border,
          enabledBorder: _border,
          disabledBorder: _border,
        ),
        baseStyle: valueStyle,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 2.0, start: 4),
          child: Row(
            mainAxisAlignment: isValueCentered
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: <Widget>[
                  if (showIcon) icon,
                  if (showIcon) SizedBox(width: 16),
                  value != null
                      ? Text(value, style: valueStyle)
                      : Text(label, style: labelStyle),
                ],
              ),
              trailing
            ],
          ),
        ),
      ),
    );
  }
}
