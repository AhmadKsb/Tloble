import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart' as countryPickers;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/customer.dart';
import 'package:flutter_ecommerce_app/src/pages/home_page.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_svg/svg.dart';

import '../../firebase_notification.dart';

class Otp extends StatefulWidget {
  final String? name;
  final String? email;
  final String newEmail;
  final bool? isGuestCheckOut;
  final String? mobileNumber;
  final countryPickers.Country? country;

  const Otp({
    Key? key,
    this.name,
    this.email,
    this.newEmail = "",
    this.isGuestCheckOut,
    @required this.country,
    @required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _OtpState createState() => new _OtpState();
}

class _OtpState extends State<Otp> with SingleTickerProviderStateMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  late PageState _state;
  late PageState _registerCustomerState;

  bool isCodeSent = false;
  bool _rootAccess = false;
  bool canMockLocation = false;
  bool isRealDevice = true;
  String? _verificationId;

  // Constants
  final int time = 30;
  late AnimationController _controller;

  // Variables
  Size? _screenSize;
  int? _currentDigit;
  int? _firstDigit;
  int? _secondDigit;
  int? _thirdDigit;
  int? _fourthDigit;
  int? _fifthDigit;
  int? _sixthDigit;

  Timer? timer;
  int? totalTimeInSeconds;
  bool? _hideResendButton;

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;

  // Returns "Appbar"
  get _getAppbar {
    return new AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: new InkWell(
        borderRadius: BorderRadius.circular(30.0),
        child: new Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black54,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
    );
  }

  // Return "Verification Code" label
  get _getVerificationCodeLabel {
    return new Text(
      Localization.of(context, 'verification_code'),
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 28.0,
          color: Color.fromARGB(255, 94, 97, 103),
          fontWeight: FontWeight.bold),
    );
  }

  // Return "Email" label
  get _getEmailLabel {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        ((Localizations.localeOf(context).languageCode == 'ar')
                ? replaceVariable(
                    replaceVariable(
                      Localization.of(
                        context,
                        'please_enter_otp_ar',
                      ),
                      'valueone',
                      widget.mobileNumber ?? "",
                    ),
                    'valuetwo',
                    widget.country?.phoneCode ?? "",
                  )
                : replaceVariable(
                    replaceVariable(
                      Localization.of(
                        context,
                        'please_enter_otp',
                      ),
                      'valueone',
                      widget.country?.phoneCode ?? "",
                    ),
                    'valuetwo',
                    widget.mobileNumber ?? "",
                  )) ??
            "",

        ///Fix phone code
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 94, 97, 103),
            fontWeight: FontWeight.w600),
      ),
    );
  }

  // Return "OTP" input field
  get _getInputField {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        if (Localizations.localeOf(context).languageCode != 'ar')
          _otpTextField(_firstDigit),
        if (Localizations.localeOf(context).languageCode != 'ar')
          _otpTextField(_secondDigit),
        if (Localizations.localeOf(context).languageCode != 'ar')
          _otpTextField(_thirdDigit),
        if (Localizations.localeOf(context).languageCode != 'ar')
          _otpTextField(_fourthDigit),
        if (Localizations.localeOf(context).languageCode != 'ar')
          _otpTextField(_fifthDigit),
        if (Localizations.localeOf(context).languageCode != 'ar')
          _otpTextField(_sixthDigit),
        if (Localizations.localeOf(context).languageCode == 'ar')
          _otpTextField(_sixthDigit),
        if (Localizations.localeOf(context).languageCode == 'ar')
          _otpTextField(_fifthDigit),
        if (Localizations.localeOf(context).languageCode == 'ar')
          _otpTextField(_fourthDigit),
        if (Localizations.localeOf(context).languageCode == 'ar')
          _otpTextField(_thirdDigit),
        if (Localizations.localeOf(context).languageCode == 'ar')
          _otpTextField(_secondDigit),
        if (Localizations.localeOf(context).languageCode == 'ar')
          _otpTextField(_firstDigit),
      ],
    );
  }

  // Returns "OTP" input part
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _getVerificationCodeLabel,
        _getEmailLabel,
        _getInputField,
        // _hideResendButton ? _getTimerText : _getResendButton,
        _getOtpKeyboard,
        SizedBox(
          height: 12,
        )
      ],
    );
  }

  // Returns "Timer" label
  get _getTimerText {
    return Container(
        // height: 32,
        // child: new Offstage(
        //   offstage: !_hideResendButton,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       new Icon(Icons.access_time),
        //       new SizedBox(
        //         width: 5.0,
        //       ),
        // OtpTimer(_controller, 15.0, Colors.black)
        // ],
        // ),
        // ),
        );
  }

  // Returns "Resend" button
  get _getResendButton {
    return new InkWell(
      child: new Container(
        height: 32,
        width: 120,
        decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(32)),
        alignment: Alignment.center,
        child: new Text(
          "Resend OTP",
          style:
              new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      onTap: () {
        // Resend you OTP via API or anything
      },
    );
  }

  // Returns "Otp" keyboard
  get _getOtpKeyboard {
    return new Container(
        height: (_screenSize?.width ?? 0) - 80,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "1",
                      onPressed: () {
                        _setCurrentDigit(1);
                      }),
                  _otpKeyboardInputButton(
                      label: "2",
                      onPressed: () {
                        _setCurrentDigit(2);
                      }),
                  _otpKeyboardInputButton(
                      label: "3",
                      onPressed: () {
                        _setCurrentDigit(3);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "4",
                      onPressed: () {
                        _setCurrentDigit(4);
                      }),
                  _otpKeyboardInputButton(
                      label: "5",
                      onPressed: () {
                        _setCurrentDigit(5);
                      }),
                  _otpKeyboardInputButton(
                      label: "6",
                      onPressed: () {
                        _setCurrentDigit(6);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _otpKeyboardInputButton(
                      label: "7",
                      onPressed: () {
                        _setCurrentDigit(7);
                      }),
                  _otpKeyboardInputButton(
                      label: "8",
                      onPressed: () {
                        _setCurrentDigit(8);
                      }),
                  _otpKeyboardInputButton(
                      label: "9",
                      onPressed: () {
                        _setCurrentDigit(9);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new SizedBox(
                    width: 80.0,
                  ),
                  _otpKeyboardInputButton(
                      label: "0",
                      onPressed: () {
                        _setCurrentDigit(0);
                      }),
                  _otpKeyboardActionButton(
                      label: SvgPicture.asset(
                        'assets/svgs/delete.svg',
                      ),
                      onPressed: () {
                        setState(() {
                          if (_sixthDigit != null) {
                            _sixthDigit = null;
                          } else if (_fifthDigit != null) {
                            _fifthDigit = null;
                          } else if (_fourthDigit != null) {
                            _fourthDigit = null;
                          } else if (_thirdDigit != null) {
                            _thirdDigit = null;
                          } else if (_secondDigit != null) {
                            _secondDigit = null;
                          } else if (_firstDigit != null) {
                            _firstDigit = null;
                          }
                        });
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  // Overridden methods
  @override
  void initState() {
    setState(() {
      _state = PageState.loading;
      _registerCustomerState = PageState.loaded;
    });

    totalTimeInSeconds = time;
    super.initState();
    _onVerifyCode();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              setState(() {
                _hideResendButton = !(_hideResendButton ?? false);
              });
            }
          });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return UBScaffold(
      state: AppState(
        pageState: _registerCustomerState == PageState.loading ||
                _state == PageState.loading
            ? PageState.loading
            : _state,
      ),
      appBar: _getAppbar,
      backgroundColor: Colors.white,
      builder: (context) => Container(
        width: _screenSize?.width,
//        padding: new EdgeInsets.only(bottom: 16.0),
        child: _getInputPart,
      ),
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int? digit) {
    return new Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new Text(
        digit != null ? digit.toString() : "",
        style: new TextStyle(
          fontSize: 30.0,
          color: Color.fromARGB(255, 94, 97, 103),
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: Color.fromARGB(255, 94, 97, 103),
      ))),
    );
  }

  Widget _otpKeyboardInputButton({
    String? label,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40.0),
          child: Container(
            height: 80.0,
            width: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x21B5B5B5),
            ),
            child: Center(
              child: Text(
                label ?? "",
                style: TextStyle(
                  fontSize: 30.0,
                  color: Color.fromARGB(255, 94, 97, 103),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({
    Widget? label,
    VoidCallback? onPressed,
  }) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_fifthDigit == null) {
        _fifthDigit = _currentDigit;
      } else if (_sixthDigit == null) {
        _sixthDigit = _currentDigit;

        var otp = _firstDigit.toString() +
            _secondDigit.toString() +
            _thirdDigit.toString() +
            _fourthDigit.toString() +
            _fifthDigit.toString() +
            _sixthDigit.toString();

        _pinEditingController.text = otp;

        _onFormSubmitted();
      }
    });
  }

  Future<Null> _startCountdown() async {
    setState(() {
      _hideResendButton = true;
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    setState(() {});
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          try {
            setState(() {
              _registerCustomerState = PageState.loading;
            });
            var notificationToken = await FirebaseMessaging.instance.getToken();
            var result = await FirebaseFirestore.instance
                .collection('Customers')
                .doc(_firebaseAuth.currentUser?.phoneNumber ?? '')
                .snapshots()
                .first;
            if (result.data() == null) {
              await FirebaseFirestore.instance
                  .collection('Customers')
                  .doc(value.user?.phoneNumber)
                  .set(
                    Customer(
                      name: widget.name,
                      phoneNumber: value.user?.phoneNumber,
                      notificationToken: notificationToken,
                      coins: 0,
                    ).toJson(),
                  );
            } else {
              var customer = Customer.fromJson(result.data()!);
              await FirebaseFirestore.instance
                  .collection('Customers')
                  .doc(customer.phoneNumber)
                  .set(
                    Customer(
                      name: widget.name,
                      phoneNumber: customer.phoneNumber,
                      notificationToken: notificationToken,
                      coins: customer.coins ?? 0,
                    ).toJson(),
                  );
            }

            setState(() {
              _registerCustomerState = PageState.loaded;
            });
          } catch (e) {
            setState(() {
              _registerCustomerState = PageState.loaded;
            });
          }

          Navigator.of(context).pop(widget.name);
          Navigator.of(context).pop(widget.name);
        } else {
          showErrorBottomsheet("Error validating OTP, try again");
        }
      }).catchError((error) {
        showErrorBottomsheet("Try again in some time");
      });
    };

    final PhoneVerificationFailed verificationFailed = (authException) {
      if (authException.code == 'invalid-phone-number') {
        showErrorBottomsheet(
          Localization.of(context, 'please_enter_a_valid_phone_number'),
          doublePop: true,
        );
      } else if (authException.code == 'app-not-authorized') {
        showErrorBottomsheet(
          Localization.of(context, 'this_device_is_not_authorized_emulator'),
          doublePop: true,
        );
      } else {
        showErrorBottomsheet(
          authException.message ?? "",
          doublePop: true,
        );
      }
      setState(() {
        _state = PageState.loaded;
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _state = PageState.loaded;
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _state = PageState.loaded;
        _verificationId = verificationId;
      });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber:
            "+${widget.country?.phoneCode ?? ""}${widget.mobileNumber ?? ""}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    AuthCredential _authCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId ?? "",
        smsCode: _pinEditingController.text);
    setState(() {
      _state = PageState.loading;
    });

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((UserCredential value) async {
      setState(() {
        _state = PageState.loaded;
      });
      if (value.user != null) {
        try {
          setState(() {
            _registerCustomerState = PageState.loading;
          });
          var notificationToken = await FirebaseMessaging.instance.getToken();
          var result = await FirebaseFirestore.instance
              .collection('Customers')
              .doc(_firebaseAuth.currentUser?.phoneNumber ?? '')
              .snapshots()
              .first;
          if (result.data() == null) {
            await FirebaseFirestore.instance
                .collection('Customers')
                .doc(value.user?.phoneNumber)
                .set(
                  Customer(
                    name: widget.name,
                    phoneNumber: value.user?.phoneNumber,
                    notificationToken: notificationToken,
                    coins: 0,
                  ).toJson(),
                );
          } else {
            var customer = Customer.fromJson(result.data()!);
            await FirebaseFirestore.instance
                .collection('Customers')
                .doc(customer.phoneNumber)
                .set(
                  Customer(
                    name: widget.name,
                    phoneNumber: customer.phoneNumber,
                    notificationToken: notificationToken,
                    coins: customer.coins ?? 0,
                  ).toJson(),
                );
          }

          setState(() {
            _registerCustomerState = PageState.loaded;
          });
        } catch (e) {
          setState(() {
            _registerCustomerState = PageState.loaded;
          });
        }
        Navigator.of(context).pop(widget.name);
        Navigator.of(context).pop(widget.name);
      } else {
        showErrorBottomsheet("Error validating OTP, try again");
      }
    }).catchError((error) {
      setState(() {
        _state = PageState.loaded;
      });

      bool isFirebaseError =
          error?.toString()?.toLowerCase()?.contains("] ".toLowerCase()) ??
              false;
      if (isFirebaseError) {
        showErrorBottomsheet(error?.toString().split("] ")[1] ?? "");
      } else {
        showErrorBottomsheet("Something went wrong!");
      }
    });
  }

  void showErrorBottomsheet(String error, {bool doublePop = false}) async {
    await showBottomSheetStatus(
        context: context,
        status: OperationStatus.error,
        message: error,
        popOnPress: true,
        dismissOnTouchOutside: false,
        onPressed: doublePop ? () => Navigator.of(context).pop() : null);
  }
}

class OtpTimer extends StatelessWidget {
  final AnimationController controller;
  double fontSize;
  Color timeColor = Colors.black;

  OtpTimer(this.controller, this.fontSize, this.timeColor);

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Duration? get duration {
    Duration? duration = controller.duration;
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Text(
            timerString,
            style: new TextStyle(
                fontSize: fontSize,
                color: timeColor,
                fontWeight: FontWeight.w600),
          );
        });
  }
}
