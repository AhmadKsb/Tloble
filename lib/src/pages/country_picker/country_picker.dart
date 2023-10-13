library country_picker;

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import 'country_list_bottom_sheet.dart';

/// Shows a bottom sheet containing a list of countries to select one.
///
/// The callback function [onSelect] call when the user select a country.
/// The function called with parameter the country that the user has selected.
/// If the user cancels the bottom sheet, the function is not call.
///
/// An optional [exclude] argument can be used to exclude(remove) one ore more
/// country from the countries list. It takes a list of country code(iso2).
///
/// An optional [showPhoneCode] argument can be used to show phone code.
///
/// [countryListTheme] can be used to customizing the country list bottom sheet.
///
/// [onClosed] callback which is called when CountryPicker is dismiss,
/// whether a country is selected or not.
///
/// [searchAutofocus] can be used to initially expand virtual keyboard
///
/// The `context` argument is used to look up the [Scaffold] for the bottom
/// sheet. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the bottom sheet is closed.
void wkShowCountryPicker({
  BuildContext context,
  ValueChanged<Country> onSelect,
  VoidCallback onClosed,
  List<String> exclude,
  List<String> countryFilter,
  bool showPhoneCode = false,
  CountryListThemeData countryListTheme,
  bool searchAutofocus = false,
  bool showWorldWide = false,
}) {
  assert(
    exclude == null || countryFilter == null,
    'Cannot provide both exclude and countryFilter',
  );
  showCountryListBottomSheet(
    context: context,
    onSelect: onSelect,
    onClosed: onClosed,
    exclude: exclude,
    countryFilter: countryFilter,
    showPhoneCode: showPhoneCode,
    countryListTheme: countryListTheme,
    searchAutofocus: searchAutofocus,
    showWorldWide: showWorldWide,
  );
}
