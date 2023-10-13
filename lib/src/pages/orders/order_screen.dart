import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/customer.dart';
import 'package:wkbeast/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:wkbeast/utils/BottomSheets/operation_status.dart';
import 'package:wkbeast/utils/UBScaffold/page_state.dart';
import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';
import 'package:wkbeast/utils/buttons/raised_button.dart';
import 'package:wkbeast/utils/string_util.dart';

import '../../controllers/home_screen_controller.dart';
import '../../models/order.dart';
import '../../utils/string_helper_extension.dart';
import '../history/amount_received_bottomsheet.dart';

class OrderScreen extends StatefulWidget {
  final HomeScreenController controller;
  final Order order;
  final bool accepted;
  final bool isAdmin;
  final bool isHistory;
  final String selectedTime;
  final String selectedPhoneNumber;
  final ValueChanged<bool> shouldRefresh;

  OrderScreen({
    Key key,
    this.controller,
    @required this.order,
    this.accepted = false,
    this.isAdmin = false,
    this.isHistory = false,
    this.selectedTime,
    this.selectedPhoneNumber,
    this.shouldRefresh,
  })  : assert(order != null),
        super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _scaffoldKey = GlobalKey<UBScaffoldState>();
  bool isLoading = false;
  bool isButtonLoading = false;
  bool accepted = false;
  bool disableButton = false;
  bool received = false;
  bool googleMapsOpened = false;
  bool alreadyReceived = false;
  bool isAdmin = false;

  num fiftyToHundred,
      hundredToThousand,
      thousandToThreeThousand,
      threeThousandToFiveThousand,
      fiveThousandToTenThousand,
      tenThousandPlus,
      amountWithoutFee,
      amountWithFee,
      rate,
      smallAmountsLimit;

  String smallAmountsSpreadSheetID;
  String largeAmountsSpreadSheetID;
  String mainCurrency;

  double amount;
  PageState _state;
  Customer customer;

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String errorMessage;
  String notificationToken;

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _load();
    if (!widget.order.shareLocation ||
        widget.order.longitude == null ||
        widget.order.latitude == null) {
      googleMapsOpened = true;
    }
  }

//   // GoogleAuth credentials
//   var _credentials = r'''
// {
//   "type": "service_account",
//   "project_id": "buyandsellusdt-36e77",
//   "private_key_id": "6b206fa2bbd15fa323ef42901d9908721e65cbb4",
//   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDgxq4mhnH5GK9H\nOx02IJGDsIX8TZnWbW4T4Z4aYit/jFzvHl/RkOnulBsuXjd5lVpPloGEozQr35YV\n8qWlMLRvE+dJV5QRbcYRVBeHVDOQo2tWZ5epP/BuOZDQshecfxmq0Bg6Bob6N+zA\nI7pNNoAD0MzZrNjBtf9R7+EvBut3XtKr9MdcQ/AXEG+KY42QgylN3U9YPw8zMLf1\ngVFFZSgZPYmfpgSzoBEtjlFdhrzRxuTG7sxkgxiw3tpiCV90v9HHrNbOrJYihx3W\nHeyPHdRA5ohYaNNS5sAPa28rhrxxNQrvA4FVbYDSbOWRHg/azhIwSDq1a86VwHCA\ndP0bJYQxAgMBAAECggEAAVhrZoIrlD11PPejzjx60n4BHDmcEU7sS2crbTUT6TCl\nnoZ5mB4GNB9VDT2TNG3nxTV9czOZLv9tpG7VpQ+Xh/bTzZyeFbDGejlh+eaoY+TQ\n+bITk+QcMs1Qj1ESMJH0zRq+TDmxFYTdVBnbQpNIvi5VpgT48wKkv8awD6F/oE6L\nE/fpIkEE2iwa/uvBLX5KLdtS/liDjVpjC1pO6dIoqrcxKxe422wB+yCVDwLBL8+P\n7ud4zlOgF3dD+fdm7OIH/utjq4aLT/EMuwrgfp3qb7CiuSwK09ljMRY7o1Vul1z6\nXN+Th6hb4eGiLGYMcmmSNzC8Gin1WtdWMnDSVgJeFwKBgQD597OawOEsFAr6M5TV\noE0+wGbUaFeD/WBHDCnsIMq8uVPYeBnsZqV4fw4jKajVyWFBlQGgg8N2JADvXzXO\nQu5oLfCWsBIqQu+Ri+YCk27DMkJTvTDyJMg58HOiiNeKGY52QxzgXWZdNhLlunG3\nHhK+GGlFh3uxfIwA5Nfv+j7ZZwKBgQDmM1iGvF5anZFPHnGukIx5x+UFJ7Ky1JCA\ncWHDfJvO1FiC2+pnuaBy16Y8rNKNu5PdLIqj6hsN2HZdq1rt9K0r1dNcHKf7KAWN\nLv1OI2BEPk9/Z+PeVt4dSv5BCH8aVFE9/v+KmiyjZCQl65ACMOkA0JfB6kCmIJwm\nwsh+0ZN+pwKBgE392ywNwjPejQ5Dycxdl7xci7j6VVP5WnDQesQR9y+rI14HGw+H\nd1mBSwftl6AclRvBQiCy++mAkkodiswwVfJrYwWhKgnFmLnwzHNBTO3aYJeAECV9\nFHv/ahTsXVPZZXnAtuHKQoYSuRK0eYaI+5AUTcRD4XQfSA9/V2Co07NBAoGBAIp8\nJSuZMqIM3JfeVsGPkBLLIInDYguXOP8sNoYl9o2szTqcFh4kW9P6y7UAuwIs8D1E\nSHtnoLLpn/ul1GQGqA8Q6cAmNSAw6XYP6K8TNRyY57Zbx4fAdorkzKRO+jfata04\nNH8rVONOoTh2yAGpbuLgmgs8Y3wNbiMbVwaECdlNAoGANE78MYxsA2Fg9/cGMlf/\neaeLCHMlM/ANbV/v3imbSw09AwdjvfHy+yfcxE5m+LSeureFynx/js7ctbAzEOHU\nm+Nwd3kvkw4WQGMHaxozeFDtpZ/upGmHUA6z7MeKWg9ka6PMhg9oHDEdqWFdmC6P\nq2hxAymsVfVdyojX6GmZJWk=\n-----END PRIVATE KEY-----\n",
//   "client_email": "wkbeast@buyandsellusdt-36e77.iam.gserviceaccount.com",
//   "client_id": "110430103338366485166",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/wkbeast%40buyandsellusdt-36e77.iam.gserviceaccount.com"
// }
// ''';

  void _load() async {
    setState(() {
      _state = PageState.loading;
    });
    notificationToken = await FirebaseMessaging.instance.getToken();
    accepted = widget.accepted ?? false;
    disableButton = widget.order.accepted ?? false;

    try {
      List data;
      if (widget.controller == null) {
        data = await Future.wait([
          FirebaseFirestore.instance.collection('app info').snapshots().first,
          FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.order.phoneNumber)
              .snapshots()
              .first,
        ]);
        customer = Customer.fromJson(
            (data[1] as DocumentSnapshot).data() == null
                ? null
                : data[1].data());
      } else {
        data = await Future.wait([
          FirebaseFirestore.instance
              .collection('drivers')
              .doc(widget.selectedPhoneNumber ??
                  widget.controller.loggedInUserPhoneNumber)
              .snapshots()
              .first,
          FirebaseFirestore.instance
              .collection('history')
              .doc(widget.selectedPhoneNumber ??
                  widget.controller.loggedInUserPhoneNumber)
              .collection(widget.selectedTime ??
                  "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}")
              .doc(widget.order.sentTime)
              .snapshots()
              .first,
          FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.order.phoneNumber)
              .snapshots()
              .first,
        ]);
        widget.controller.driverCashIn = data[0]['cash_in'];
        widget.controller.driverUsdtIn = data[0]['usdt_in'];
        widget.controller.driverUsdtOut = data[0]['usdt_out'];
        widget.controller.driverCashOut = data[0]['cash_out'];
        alreadyReceived = data[1]['received'] ?? false;
        customer = Customer.fromJson(
            (data[2] as DocumentSnapshot).data() == null
                ? null
                : data[2].data());
      }

      Map<String, dynamic> ratesSnapshot = widget.controller == null
          ? ((data[0] as QuerySnapshot)
              .docs
              .firstWhere((document) => document.id == 'rates')).data()
          : {};

      Map<String, dynamic> sellRatesSnapshot = widget.controller == null
          ? ((data[0] as QuerySnapshot)
              .docs
              .firstWhere((document) => document.id == 'sell rates')).data()
          : {};

      Map<String, dynamic> appSnapshot = widget.controller == null
          ? ((data[0] as QuerySnapshot)
              .docs
              .firstWhere((document) => document.id == 'app')).data()
          : {};

      isAdmin = widget.controller == null
          ? appSnapshot['admins']
              .contains(_firebaseAuth?.currentUser?.phoneNumber)
          : widget.isAdmin;

      mainCurrency = widget.controller == null
          ? appSnapshot['mainCurrency']
          : widget.controller.mainCurrency;

      fiftyToHundred = widget.order.action.toLowerCase() == 'buy'
          ? widget.controller == null
              ? ratesSnapshot['50to100'] ?? 7
              : widget.controller.fiftyToHundred
          : widget.controller == null
              ? sellRatesSnapshot['50to100']
              : widget.controller.sellFiftyToHundred;

      hundredToThousand = widget.order.action.toLowerCase() == 'buy'
          ? widget.controller == null
              ? ratesSnapshot['100to1000'] ?? 5
              : widget.controller.hundredToThousand
          : widget.controller == null
              ? sellRatesSnapshot['100to1000']
              : widget.controller.sellHundredToThousand;

      thousandToThreeThousand = widget.order.action.toLowerCase() == 'buy'
          ? widget.controller == null
              ? ratesSnapshot['1000to3000'] ?? 4.5
              : widget.controller.thousandToThreeThousand
          : widget.controller == null
              ? sellRatesSnapshot['1000to3000'] ?? 4.5
              : widget.controller.sellThousandToThreeThousand;

      threeThousandToFiveThousand = widget.order.action.toLowerCase() == 'buy'
          ? widget.controller == null
              ? ratesSnapshot['3000to5000'] ?? 4
              : widget.controller.threeThousandToFiveThousand
          : widget.controller == null
              ? sellRatesSnapshot['3000to5000'] ?? 4
              : widget.controller.sellThreeThousandToFiveThousand;

      fiveThousandToTenThousand = widget.order.action.toLowerCase() == 'buy'
          ? widget.controller == null
              ? ratesSnapshot['5000to10000'] ?? 3.5
              : widget.controller.fiveThousandToTenThousand
          : widget.controller == null
              ? sellRatesSnapshot['5000to10000'] ?? 3.5
              : widget.controller.sellFiveThousandToTenThousand;

      smallAmountsLimit = widget.controller == null
          ? num.tryParse(appSnapshot['smallAmountsLimit']) ?? 0
          : widget.controller.smallAmountsLimit;

      smallAmountsSpreadSheetID = widget.controller == null
          ? appSnapshot['smallAmountsSpreadSheetID'] ??
              '1eQceggAMmmZ-0II5Hq_nxchk3VUGAO3VDGGRW9pTmsA'
          : widget.controller.smallAmountsSpreadSheetID;

      largeAmountsSpreadSheetID = widget.controller == null
          ? appSnapshot['largeAmountsSpreadSheetID'] ??
              '1_qWdbjyLcP9mPPi9m_Yc6t9SHdVvFDZ56FxNDz_A-Nc'
          : widget.controller.largeAmountsSpreadSheetID;

      amount = double.tryParse(widget.order.amount.toString());

      if (amount >= 50 && amount < 100) {
        rate = fiftyToHundred;
      } else if (amount >= 100 && amount < 1000) {
        rate = hundredToThousand;
      } else if (amount >= 1000 && amount < 3000) {
        rate = thousandToThreeThousand;
      } else if (amount >= 3000 && amount < 5000) {
        rate = threeThousandToFiveThousand;
      } else if (amount >= 5000) {
        rate = fiveThousandToTenThousand;
      }

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

  @override
  Widget build(BuildContext context) {
    return UBScaffold(
      key: _scaffoldKey,
      state: AppState(
        pageState: _state,
        onRetry: _load,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _state == PageState.loaded
              ? '${widget.order.action.toLowerCase() == 'buy' ? Localization.of(context, 'buy_order') : Localization.of(context, 'sell_order')} $mainCurrency'
              : "",
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 210, 34, 49),
        actions: _state == PageState.loaded
            ? [
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 24),
                  child: GestureDetector(
                    onTap: () {
                      if (accepted || isAdmin) {
                        _getOrderInfo();
                      } else {
                        showErrorBottomsheet(
                          Localization.of(context, 'please_accept_the_request'),
                        );
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/share.svg',
                      width: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      builder: (context) => SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                labelTitlePair(
                  Localization.of(context, 'request_id'),
                  '\# ${widget.order.referenceID}',
                ),
                InkWell(
                  onLongPress: () {
                    Clipboard.setData(
                            new ClipboardData(text: widget.order.phoneNumber))
                        .then((result) {
                      final snackBar = SnackBar(
                        content: Text(
                          Localization.of(context, 'copied_name_to_clipboard'),
                        ),
                        action: SnackBarAction(
                          label: Localization.of(context, 'done'),
                          onPressed: () {},
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    });
                  },
                  child: labelTitlePair(
                    Localization.of(context, 'name'),
                    widget.order.name.capitalize,
                  ),
                ),
                InkWell(
                  onLongPress: () {
                    if (accepted ||
                        (_firebaseAuth.currentUser.phoneNumber ==
                                '+9611111111' ||
                            _firebaseAuth.currentUser.phoneNumber ==
                                '+9613022005')) {
                      Clipboard.setData(
                              new ClipboardData(text: widget.order.phoneNumber))
                          .then((result) {
                        final snackBar = SnackBar(
                          content: Text(
                            Localization.of(
                                context, 'copied_phone_number_to_clipboard'),
                          ),
                          action: SnackBarAction(
                            label: Localization.of(context, 'done'),
                            onPressed: () {},
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      });
                    } else {
                      final snackBar = SnackBar(
                        content: Text(
                          Localization.of(
                              context, 'accepted_request_to_copy_phone_number'),
                        ),
                        action: SnackBarAction(
                          label: Localization.of(context, 'done'),
                          onPressed: () {},
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  },
                  onTap: () {
                    try {
                      if (accepted || (isAdmin && widget.order.accepted)) {
                        openWhatsapp();
                      } else {
                        showErrorBottomsheet(
                          Localization.of(context, 'please_accept_the_request'),
                        );
                      }
                    } catch (e) {
                      print(e);
                      showErrorBottomsheet(
                        replaceVariable(
                          Localization.of(
                              context, 'an_error_has_occurred_value'),
                          'value',
                          e.toString(),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          Localization.of(context, 'phone_number'),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              accepted ||
                                      (_firebaseAuth.currentUser.phoneNumber ==
                                              '+9611111111' ||
                                          _firebaseAuth
                                                  .currentUser.phoneNumber ==
                                              '+9613022005')
                                  ? (Localizations.localeOf(context)
                                              .languageCode ==
                                          'ar')
                                      ? ((widget.order?.phoneNumber
                                                  ?.replaceAll('+', '') ??
                                              '') +
                                          '+')
                                      : ('+' +
                                          (widget.order?.phoneNumber
                                                  ?.replaceAll('+', '') ??
                                              ""))
                                  : '*******',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Image.asset(
                              "assets/images/whatsapp.png",
                              height: 20.0,
                              width: 20.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 64,
                      ),
                    ],
                  ),
                ),
                labelTitlePair(
                  Localization.of(context, 'amount'),
                  '${widget.order.action.toLowerCase() == 'buy' ? "\$ " : ""}${(_firebaseAuth.currentUser.phoneNumber == '+9611111111' || _firebaseAuth.currentUser.phoneNumber == '+9613022005') ? amount.floor() : accepted ? amount.floor() : '*****'} ${widget.order.action.toLowerCase() == 'buy' ? "" : "$mainCurrency"}',
                ),
                if (widget.order?.location?.isNotEmpty ?? false)
                  labelTitlePair(
                    Localization.of(context, 'location'),
                    Localization.of(context, widget.order.location),
                  ),
                if (widget.order?.details?.isNotEmpty ?? false)
                  labelTitlePair(
                    Localization.of(context, 'more_details_about_the_location'),
                    widget.order.details,
                  ),
                if (widget.order.shareLocation &&
                    widget.order.longitude != null &&
                    widget.order.latitude != null)
                  SizedBox(height: 16),
                if (widget.order.shareLocation &&
                    widget.order.longitude != null &&
                    widget.order.latitude != null)
                  Container(
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        try {
                          openGoogleMaps();
                          googleMapsOpened = true;
                        } catch (e) {
                          print(e);
                          showErrorBottomsheet(
                            replaceVariable(
                              Localization.of(
                                  context, 'an_error_has_occurred_value'),
                              'value',
                              e.toString(),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Localization.of(context, 'open_location'),
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Image.asset(
                            "assets/images/google_maps.png",
                            height: 20.0,
                            width: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.order.shareLocation) SizedBox(height: 16),
                SizedBox(height: 16),
                Text(
                  (_firebaseAuth.currentUser.phoneNumber == '+9611111111' ||
                          _firebaseAuth.currentUser.phoneNumber ==
                              '+9613022005')
                      ? amount > 10000
                          ? Localization.of(context, 'note_ask_for_rate')
                          : heEitherPays(
                              getTextFormatted(amount.floor().toString()),
                              getTextFormatted((amount - ((amount * rate) / 100)).floor().toString(),
                                  first: false),
                              getTextFormatted((amount + ((amount * rate) / 100))
                                  .ceil()
                                  .toString()),
                              getTextFormatted(amount.ceil().toString(),
                                  first: false))
                      : accepted
                          ? amount > 10000
                              ? Localization.of(context, 'note_ask_for_rate')
                              : heEitherPays(
                                  getTextFormatted(amount.floor().toString()),
                                  getTextFormatted(
                                      (amount - ((amount * rate) / 100))
                                          .floor()
                                          .toString(),
                                      first: false),
                                  getTextFormatted(
                                      (amount + ((amount * rate) / 100))
                                          .ceil()
                                          .toString()),
                                  getTextFormatted(amount.ceil().toString(),
                                      first: false))
                          : heEitherPays(
                              getTextFormatted(accepted
                                  ? amount.floor()
                                  : '*****'.toString()),
                              getTextFormatted(
                                  accepted
                                      ? (amount - ((amount * rate) / 100))
                                          .floor()
                                      : '*****'.toString(),
                                  first: false),
                              getTextFormatted(accepted
                                  ? (amount + ((amount * rate) / 100)).ceil()
                                  : '*****'.toString()),
                              getTextFormatted(
                                  accepted ? amount.ceil() : '*****'.toString(),
                                  first: false)),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontSize: 15, color: Color.fromARGB(255, 210, 34, 49)),
                ),
                SizedBox(height: 16),
                RaisedButtonV2(
                  disabled: isLoading || accepted || disableButton,
                  isLoading: isLoading,
                  green: true,
                  onPressed: () async {
                    if ((googleMapsOpened || (isAdmin ?? false)) ||
                        !widget.order.shareLocation ||
                        widget.order.longitude == null ||
                        widget.order.latitude == null) {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        amountWithoutFee =
                            (amount - ((amount * rate) / 100)).floor();
                        amountWithFee =
                            (amount + ((amount * rate) / 100)).ceil();

                        var databaseReference = FirebaseFirestore.instance
                            .collection('ordersv2')
                            .doc((amount > smallAmountsLimit)
                                ? 'largeOrders'
                                : 'smallOrders')
                            .collection(widget.selectedTime ??
                                widget.order.sentTime.split(' ')[0])
                            .doc(widget.order.sentTime);

                        var driverReference =
                            await databaseReference.snapshots().first;

                        if (driverReference['driver'].toString().isEmpty) {
                          // final gsheets = GSheets(_credentials);
                          // final ss = await gsheets.spreadsheet(
                          //     (amount > smallAmountsLimit)
                          //         ? largeAmountsSpreadSheetID
                          //         : smallAmountsSpreadSheetID);
                          // final sheet = ss.worksheetByTitle(
                          //     widget?.controller?.worksheetTitle ?? 'Sheet1');
                          Order newOrder = widget.order;
                          newOrder.acceptedTime =
                              '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
                          newOrder.driver =
                              _firebaseAuth.currentUser.phoneNumber;

                          await Future.wait([
                            FirebaseFirestore.instance
                                .collection('ordersv2')
                                .doc((amount > smallAmountsLimit)
                                    ? 'largeOrders'
                                    : 'smallOrders')
                                .collection(widget.order.sentTime.split(' ')[0])
                                .doc(widget.order.sentTime)
                                .update({
                              'driver': _firebaseAuth.currentUser.phoneNumber,
                              'accepted': true,
                              'acceptedTime':
                                  '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
                            }),
                            FirebaseFirestore.instance
                                .collection('history')
                                .doc(_firebaseAuth.currentUser.phoneNumber)
                                .collection(
                                    "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}")
                                .doc(widget.order.sentTime)
                                .set(
                                  newOrder.toJson(),
                                ),
                            // sheet.values.insertValueByKeys(
                            //   _firebaseAuth.currentUser.phoneNumber,
                            //   columnKey: 'Driver',
                            //   rowKey: '# ${widget.order.referenceID}',
                            //   eager: false,
                            // ),
                          ]);

                          showSuccessBottomsheet();
                          accepted = true;

                          if (widget.shouldRefresh != null)
                            widget.shouldRefresh(true);

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (prefs.getBool('wkbeast_show_history') != true)
                            prefs.setBool('wkbeast_show_history', true);

                          setState(() {
                            isLoading = false;
                          });
                        } else {
                          showErrorBottomsheet(
                            Localization.of(
                                context, 'driver_already_on_his_way'),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } catch (e) {
                        showErrorBottomsheet(
                          replaceVariable(
                            Localization.of(
                                context, 'an_error_has_occurred_value'),
                            'value',
                            e.toString(),
                          ),
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } else {
                      showErrorBottomsheet(
                        Localization.of(
                            context, 'please_check_the_location_first'),
                      );
                    }
                  },
                  label: disableButton
                      ? Localization.of(context, 'accepted')
                      : accepted
                          ? Localization.of(context, 'accepted')
                          : Localization.of(context, 'accept'),
                ),
                if (widget.isHistory ?? false)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: RaisedButtonV2(
                      disabled:
                          (received ?? false) || (alreadyReceived ?? false),
                      isLoading: isLoading,
                      green: true,
                      onPressed: () async {
                        showBottomsheet(
                          context: context,
                          height: MediaQuery.of(context).size.height * 0.45,
                          dismissOnTouchOutside: false,
                          isScrollControlled: true,
                          upperWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 16.0,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 25,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      return isButtonLoading
                                          ? null
                                          : Navigator.of(context).pop();
                                    });
                                  })
                            ],
                          ),
                          body: AmountReceivedBottomsheet(
                            controller: widget.controller,
                            order: widget.order,
                            customer: customer,
                            selectedTime: widget.selectedTime,
                            isBottomSheetLoading: (isLoad) {
                              setState(() {
                                isButtonLoading = isLoad;
                              });
                            },
                            received: (rcvd) {
                              setState(() {
                                received = rcvd;
                                widget.shouldRefresh(true);
                              });
                            },
                          ),
                        );
                      },
                      label: Localization.of(context, 'receivedCapitalized'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getTextFormatted(String text, {bool first = true}) {
    return widget.order.action.toLowerCase() == 'buy'
        ? first
            ? "\$" + text
            : text + " $mainCurrency"
        : first
            ? text + " $mainCurrency"
            : "\$" + text;
  }

  void _getOrderInfo() async {
    String text =
        '*${widget.order.action.capitalize} order*\n\n*Request ID:* \#${widget.order.referenceID}\n*Name:* ${widget.order.name.capitalize}\n*Phone number:* ${widget.order.phoneNumber}\n*Amount:* \$ ${widget.order.amount}\n';
    if (widget.order?.location?.isNotEmpty ?? false)
      text += '*Location:* ${widget.order.location}\n';
    if (widget.order?.details?.isNotEmpty ?? false)
      text += '*More details about the location:* ${widget.order.details}\n';
    if (widget.order.shareLocation &&
        widget.order.longitude != null &&
        widget.order.latitude != null)
      text +=
          '*Google maps:* https://www.google.com/maps/search/?api=1&query=${widget.order.latitude},${widget.order.longitude}';
    try {
      FlutterShare.share(
          title: "Share ${widget.order.action} order", text: text);
    } catch (error) {
      print("ERROR $error");
      // printException(error);
      // showDialog(
      //   context: context,
      //   builder: (ctx) => ZlStatusDialog.error(error),
      // );
    }
  }

  Widget labelTitlePair(
    String title,
    String label,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
          ),
        ),
        SizedBox(
          height: 64,
        ),
      ],
    );
  }

  void showErrorBottomsheet(String error) async {
    await showBottomSheetStatus(
      context: context,
      status: OperationStatus.error,
      message: error,
      popOnPress: true,
      dismissOnTouchOutside: false,
    );
  }

  void showSuccessBottomsheet() async {
    String animResource;
    animResource = 'assets/flare/success.flr';
    setState(() {
      Vibration.vibrate();
    });

    await showBottomsheet(
      context: context,
      isScrollControlled: true,
      dismissOnTouchOutside: false,
      height: MediaQuery.of(context).size.height * 0.3,
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 100,
              child: animResource != null
                  ? FlareActor(
                      animResource,
                      animation: 'animate',
                      fit: BoxFit.fitWidth,
                    )
                  : Container(),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  Localization.of(context, 'order_accepted_successfully'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
      bottomWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: RaisedButtonV2(
                  label: Localization.of(context, 'done'),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void openGoogleMaps() async {
    try {
      launch(
        'https://www.google.com/maps/search/?api=1&query=${widget.order.latitude},${widget.order.longitude}',
      );
    } catch (e) {
      print("Open Google Maps Error: ${e.toString()}");
    }
  }

  void openWhatsapp() async {
    try {
      bool isEnglish = widget.order.name.contains(RegExp(r'[a-zA-Z]'));
      if (isEnglish ?? false) {
        launch(
            'https://wa.me/${widget.order.phoneNumber}?text=Hello%2C%20we%20received%20your%20${widget.order.action.toLowerCase()}%20order%20of%20%24%20${widget.order.amount}.');
      } else {
        launch(
          Uri.encodeFull(
              'https://wa.me/${widget.order?.phoneNumber}?text=مرحبًا، لقد تلقينا طلبك ${(widget.order.action.toLowerCase() == 'buy') ? Localization.of(context, 'for_buy_ar').toLowerCase() : Localization.of(context, 'for_sell_ar').toLowerCase()} بقيمة \$ ${widget.order.amount}.'),
        );
      }
    } catch (e) {
      print("Open Whatsapp Error: ${e.toString()}");
    }
  }

  String heEitherPays(String v1, String v2, String v3, String v4) {
    var firstReplace = replaceVariable(
      Localization.of(
        context,
        'note_he_either_pays',
      ),
      'valueone',
      v1,
    );

    var secondReplace = replaceVariable(
      firstReplace,
      'valuetwo',
      v2,
    );

    var thirdReplace = replaceVariable(
      secondReplace,
      'valuethree',
      v3,
    );

    var fourthReplace = replaceVariable(
      thirdReplace,
      'valuefour',
      v4,
    );

    return fourthReplace;
  }
}
