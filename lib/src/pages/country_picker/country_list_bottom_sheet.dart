import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import 'country_list_view.dart';

void showCountryListBottomSheet({
  BuildContext? context,
  ValueChanged<Country>? onSelect,
  VoidCallback? onClosed,
  List<String>? exclude,
  List<String>? countryFilter,
  bool showPhoneCode = false,
  CountryListThemeData? countryListTheme,
  bool searchAutofocus = false,
  bool showWorldWide = false,
}) {
  showModalBottomSheet(
    context: context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.8,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: _builder(
          context,
          onSelect!,
          exclude ?? [],
          countryFilter ?? [],
          showPhoneCode,
          countryListTheme ?? CountryListThemeData(),
          searchAutofocus,
          showWorldWide,
        ),
      ),
    ),
  ).whenComplete(() {
    if (onClosed != null) onClosed();
  });
}

Widget _builder(
  BuildContext context,
  ValueChanged<Country> onSelect,
  List<String> exclude,
  List<String> countryFilter,
  bool showPhoneCode,
  CountryListThemeData countryListTheme,
  bool searchAutofocus,
  bool showWorldWide,
) {
  final device = MediaQuery.of(context).size.height;
  final statusBarHeight = MediaQuery.of(context).padding.top;
  final height = device - (statusBarHeight + (kToolbarHeight / 1.5));

  Color? _backgroundColor = countryListTheme.backgroundColor ??
      Theme.of(context).bottomSheetTheme.backgroundColor;
  if (_backgroundColor == null) {
    if (Theme.of(context).brightness == Brightness.light) {
      _backgroundColor = Colors.white;
    } else {
      _backgroundColor = Colors.black;
    }
  }

  final BorderRadius _borderRadius = countryListTheme.borderRadius ??
      const BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      );

  return Container(
    height: height,
    decoration: BoxDecoration(
      color: _backgroundColor,
      borderRadius: _borderRadius,
    ),
    child: wkCountryListView(
      onSelect: onSelect,
      exclude: exclude,
      countryFilter: countryFilter,
      showPhoneCode: showPhoneCode,
      countryListTheme: countryListTheme,
      searchAutofocus: searchAutofocus,
      showWorldWide: showWorldWide,
    ),
  );
}
