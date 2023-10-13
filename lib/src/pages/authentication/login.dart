import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_pickers/country.dart' as countryPickers;
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/pages/country_picker/country_picker.dart';
import 'package:flutter_ecommerce_app/src/pages/home_page.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/keyboard_actions_form.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
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

  TextEditingController _nameController = TextEditingController();
  FocusNode _nameNode = new FocusNode();

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
        'swiftShop_phoneCode',
        '961',
      );
      prefs.setString(
        'swiftShop_isoCode',
        'LB',
      );

      List data = await Future.wait(
        [
          FirebaseFirestore.instance.collection('app info').snapshots().first,
        ],
      );

      _controller = HomeScreenController(
        {},
        ((data[0] as QuerySnapshot)
            .docs
            .firstWhere((document) => document.id == 'app')).data(),
        {},
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

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns: 4,
            child: _icon(Icons.arrow_back_ios_new, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      // onTap: null,
      child: Container(
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            // color: Theme.of(context).backgroundColor,
            boxShadow: AppTheme.shadow),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }

  // Future<void> _load() async {
  //   prefs = await SharedPreferences.getInstance();
  //   prefs.setString(
  //     'swiftShop_phoneCode',
  //     '961',
  //   );
  //   prefs.setString(
  //     'swiftShop_isoCode',
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
    _nameNode?.dispose();
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
            focusNode: _nameNode,
          ),
          KeyboardFormAction(
            focusNode: phoneField,
          ),
        ],
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 68),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xfffcfcfc),
                    Color(0xfffcfcfc),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _appBar(),
                  Container(
                    padding: EdgeInsets.all(80.0),
                    child: Center(
                      child: Image.asset("assets/images/login_logo.png"),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      layoutContainer(
                        child: TextFormField(
                          textDirection:
                              (Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr),
                          controller: _nameController,
                          focusNode: _nameNode,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                  r"[a-zA-Z0-9 .,()-_!?@+=;:!$'()*+-./:<=>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"),
                            ),
                          ],
                          decoration: inputDecoration(
                            Localization.of(context, 'name'),
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return Localization.of(
                                  context, 'name_cannot_be_empty');
                            }
                            // if (value.length > 0 && value.length > 8) {
                            //   return 'Phone Number can not be more than 8 characters long.';
                            // }
                            return null;
                          },
                          textAlign: TextAlign.start,
                        ),
                      ),
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
                              if (value.isEmpty) {
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
                                          'swiftShop_phoneCode',
                                          selectedCountry.phoneCode,
                                        );
                                        prefs.setString(
                                          'swiftShop_isoCode',
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
                          label: Localization.of(context, 'login_register'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Otp(
                                    name: _nameController?.text ?? "",
                                    country: selectedCountry,
                                    mobileNumber: _phoneNumber,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hintText, {Widget prefixIcon}) {
    return InputDecoration(
      labelText: hintText,
      counterText: "",
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
      prefixIcon: prefixIcon,
    );
  }

  Widget layoutContainer({Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: child,
      ),
    );
  }
}
