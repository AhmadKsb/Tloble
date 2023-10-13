import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_pickers/country.dart' as countryPickers;
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wkbeast/controllers/home_screen_controller.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/main.dart';
import 'package:wkbeast/screens/home/home_screen.dart';
import 'package:wkbeast/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:wkbeast/utils/BottomSheets/operation_status.dart';
import 'package:wkbeast/utils/UBScaffold/page_state.dart';
import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';
import 'package:wkbeast/utils/buttons/raised_button.dart';
import 'package:wkbeast/utils/keyboard_actions_form.dart';
import 'package:wkbeast/widgets/country_picker/country_picker.dart';

import 'otp.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isValid = false;
  FocusNode phoneField = FocusNode();
  String _phoneNumber = '';
  countryPickers.Country selectedCountry;
  SharedPreferences prefs;

  HomeScreenController _controller;
  PageState _state;

  Future<Null> validate(StateSetter updateState) async {
    if (_phoneNumber.length == 7) {
      updateState(() {
        isValid = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCountry = CountryPickerUtils.getCountryByPhoneCode('961');
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = PageState.loading;
    });

    try {
      prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'wk_phoneCode',
        '961',
      );
      prefs.setString(
        'wk_isoCode',
        'LB',
      );

      List data = await Future.wait(
        [
          FirebaseFirestore.instance.collection('app info').snapshots().first,
        ],
      );

      _controller = HomeScreenController(
        ((data[0] as QuerySnapshot)
            .docs
            .firstWhere((document) => document.id == 'rates')).data(),
        ((data[0] as QuerySnapshot)
            .docs
            .firstWhere((document) => document.id == 'app')).data(),
        ((data[0] as QuerySnapshot)
            .docs
            .firstWhere((document) => document.id == 'sell rates')).data(),
      );

      setState(() {
        _state = PageState.loaded;
      });
    } catch (e) {
      print(e);
      setState(() {
        _state = PageState.error;
      });
    }
  }

  // Future<void> _load() async {
  //   prefs = await SharedPreferences.getInstance();
  //   prefs.setString(
  //     'wk_phoneCode',
  //     '961',
  //   );
  //   prefs.setString(
  //     'wk_isoCode',
  //     'LB',
  //   );
  // }

  void showErrorBottomsheet(String error,
      {bool dismissOnTouchOutside = true,
      bool showDoneButton = true,
      bool doublePop = false}) async {
    if (!mounted) return;
    await showBottomSheetStatus(
      context: context,
      status: OperationStatus.error,
      message: error,
      popOnPress: true,
      dismissOnTouchOutside: dismissOnTouchOutside,
      showDoneButton: showDoneButton,
      onPressed: doublePop ? () => Navigator.of(context).pop() : null,
    );
  }

  @override
  void dispose() {
    phoneField?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UBScaffold(
      state: AppState(
        pageState: _state,
        onRetry: _load,
      ),
      builder: (context) => KeyboardFormActions(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
        nextFocus: false,
        keyboardBarColor: Colors.black54,
        actions: [
          KeyboardFormAction(
            focusNode: phoneField,
          )
        ],
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(80.0),
                    child: Center(
                      child: Image.asset("assets/images/login_logo.jpeg"),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                          left: 25.0,
                          right: 25.0,
                          top: 10.0,
                        ),
                        alignment: Alignment.center,
                        padding:
                            EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            focusNode: phoneField,
                            keyboardType: TextInputType.number,
                            onChanged: (String phoneNumber) {
                              setState(() {
                                _phoneNumber = phoneNumber;
                              });
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[0-9]"),
                              ),
                            ],
                            validator: (String value) {
                              if (value.length > 0 && value.length < 1) {
                                return Localization.of(
                                    context, 'phone_number_cannot_be_empty');
                              }
                              // if (value.length > 0 && value.length > 8) {
                              //   return 'Phone Number can not be more than 8 characters long.';
                              // }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  Localization.of(context, 'phone_number'),
                              labelStyle: TextStyle(
                                color: Colors.black,
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
                              prefixIcon: GestureDetector(
                                onTap: () {
                                  wkShowCountryPicker(
                                    context: context,
                                    showPhoneCode: false,
                                    onSelect: (Country country) {
                                      setState(() {
                                        selectedCountry = CountryPickerUtils
                                            .getCountryByPhoneCode(
                                                country.phoneCode);
                                        prefs.setString(
                                          'wk_phoneCode',
                                          selectedCountry.phoneCode,
                                        );
                                        prefs.setString(
                                          'wk_isoCode',
                                          selectedCountry.isoCode,
                                        );
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          start: 8,
                                        ),
                                        child: Image.asset(
                                          CountryPickerUtils
                                              .getFlagImageAssetPath(
                                            selectedCountry.isoCode,
                                          ),
                                          height: 20.0,
                                          width: 35.0,
                                          package: "country_pickers",
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: 8,
                                            ),
                                            child: Text(
                                              (Localizations.localeOf(context)
                                                          .languageCode ==
                                                      'ar')
                                                  ? ("${selectedCountry?.phoneCode ?? ""}" +
                                                      "+")
                                                  : "+${selectedCountry?.phoneCode ?? ""}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              end: 4,
                                            ),
                                            child: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsetsDirectional.only(end: 8),
                                        child: Container(
                                          width: 1,
                                          height: 35,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 175,
                        margin: const EdgeInsets.only(
                          left: 30.0,
                          right: 30.0,
                          top: 20.0,
                        ),
                        alignment: Alignment.center,
                        child: RaisedButtonV2(
                          label: _phoneNumber.isEmpty
                              ? Localization.of(context, 'skip')
                              : Localization.of(context, 'login'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _phoneNumber.isEmpty
                                  ? showConfirmationBottomSheet(
                                      context: context,
                                      flare: 'assets/flare/pending.flr',
                                      title: Localization.of(context,
                                          'are_you_sure_you_want_to_proceed_without_logging_in'),
                                      message: Localization.of(context,
                                          'by_proceeding_you_wont_be_able'),
                                      confirmMessage:
                                          Localization.of(context, 'proceed'),
                                      confirmAction: () async {
                                        Navigator.of(context).pop();
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(),
                                          ),
                                        );
                                      },
                                      cancelMessage:
                                          Localization.of(context, 'cancel'),
                                    )
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Otp(
                                          country: selectedCountry,
                                          mobileNumber: _phoneNumber,
                                        ),
                                      ),
                                    );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 45.0,
                          right: 45.0,
                          top: 45.0,
                          bottom: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            InkWell(
                              onTap: () async {
                                if (_controller?.showChangeLanguage ?? false) {
                                  final isArabic =
                                      (Localizations.localeOf(context)
                                              .languageCode ==
                                          'ar');
                                  MyApp.setLocale(
                                    context,
                                    Locale(isArabic ? "en" : "ar"),
                                  );
                                  await prefs.setString(
                                    'wkbeast_language',
                                    isArabic ? "en" : "ar",
                                  );

                                  Phoenix.rebirth(context);
                                }
                              },
                              child: Container(
                                padding: EdgeInsetsDirectional.only(start: 42),
                                child: (_controller?.showChangeLanguage ??
                                        false)
                                    ? Text(
                                        (Localizations.localeOf(context)
                                                    .languageCode ==
                                                'ar')
                                            ? "English"
                                            : "العربية",
                                        style: TextStyle(
                                            fontSize:
                                                (Localizations.localeOf(context)
                                                            .languageCode ==
                                                        'ar')
                                                    ? 14
                                                    : 16),
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
