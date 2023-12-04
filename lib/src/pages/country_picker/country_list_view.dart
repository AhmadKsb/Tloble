import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';

import 'country_codes.dart';

class wkCountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country>? onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// An optional argument for showing "World Wide" option at the beginning of the list
  final bool showWorldWide;

  const wkCountryListView({
    Key? key,
    this.onSelect,
    this.exclude,
    this.countryFilter,
    this.showPhoneCode = false,
    this.countryListTheme,
    this.searchAutofocus = false,
    this.showWorldWide = false,
  })  : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        ),
        super(key: key);

  @override
  _wkCountryListViewState createState() => _wkCountryListViewState();
}

class _wkCountryListViewState extends State<wkCountryListView> {
  late List<Country> _countryList;
  late List<Country> _filteredList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    //Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => (widget.exclude?.contains(element.countryCode) ?? false),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) =>
            !(widget.countryFilter?.contains(element.countryCode) ?? true),
      );
    }

    _filteredList = <Country>[];
    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;
  }

  @override
  Widget build(BuildContext context) {
    final String searchLabel =
        CountryLocalizations.of(context)?.countryName(countryCode: 'search') ??
            Localization.of(context, 'search');

    return Column(
      children: <Widget>[
        const SizedBox(height: 32),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        //   child: TextField(
        //     autofocus: _searchAutofocus,
        //     controller: _searchController,
        //     decoration: widget.countryListTheme?.inputDecoration ??
        //         InputDecoration(
        //           labelText: searchLabel,
        //           hintText: searchLabel,
        //           prefixIcon: const Icon(Icons.search),
        //           border: OutlineInputBorder(
        //             borderSide: BorderSide(
        //               color: const Color(0xFF8C98A8).withOpacity(0.2),
        //             ),
        //             borderRadius: BorderRadius.circular(10.0),
        //           ),
        //         ),
        //     onChanged: _filterSearchResults,
        //   ),
        // ),
        // const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: _filteredList
                .map<Widget>((country) => _listRow(country))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;
    var countryName = country.name;
    if (countryName == "Israel") return SizedBox.shrink();
    if (countryName == "Palestinian Territories") countryName = "Palestine";

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          country.nameLocalized = CountryLocalizations.of(context)
              ?.countryName(countryCode: country.countryCode)
              ?.replaceAll(RegExp(r"\s+"), " ");
          widget.onSelect!(country);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: <Widget>[
              if (country.countryCode == Country.worldWide.countryCode)
                Row(
                  children: [
                    const SizedBox(width: 23),
                    Image(
                      image: AssetImage('worldwide.png'.imagePath),
                      width: 27,
                    ),
                    const SizedBox(width: 15),
                  ],
                )
              else
                Row(
                  children: [
                    const SizedBox(width: 20),
                    SizedBox(
                      // the conditional 50 prevents irregularities caused by the flags in RTL mode
                      width: isRtl ? 50 : null,
                      child: Text(
                        Utils.countryCodeToEmoji(country.countryCode),
                        style: TextStyle(
                          fontSize: widget.countryListTheme?.flagSize ?? 25,
                        ),
                      ),
                    ),
                    if (widget.showPhoneCode) ...[
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 45,
                        child: Text(
                          (country.countryCode == Country.worldWide.countryCode)
                              ? ''
                              : '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
                          style: _textStyle,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ] else
                      const SizedBox(width: 15),
                  ],
                ),
              Expanded(
                child: Text(
                  CountryLocalizations.of(context)
                          ?.countryName(countryCode: country.countryCode)
                          ?.replaceAll(RegExp(r"\s+"), " ") ??
                      Localization.of(context, countryName),
                  style: _textStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool countryStartsWith(
      Country country, String query, CountryLocalizations localizations) {
    String _query = query;
    if (query.startsWith("+")) {
      _query = query.replaceAll("+", "").trim();
    }
    return country.phoneCode.startsWith(_query.toLowerCase()) ||
        Localization.of(context, country.name)
            .toLowerCase()
            .startsWith(_query.toLowerCase()) ||
        country.countryCode.toLowerCase().startsWith(_query.toLowerCase()) ||
        (localizations
                .countryName(countryCode: country.countryCode)
                ?.toLowerCase()
                .startsWith(_query.toLowerCase()) ??
            false);
  }

  void _filterSearchResults(String query) {
    List<Country> _searchResult = <Country>[];
    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
          .where((c) => countryStartsWith(c, query, localizations!))
          .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}

class Utils {
  static String countryCodeToEmoji(String countryCode) {
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
}
