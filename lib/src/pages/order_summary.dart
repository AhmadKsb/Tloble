import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/customer.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/WKNetworkImage.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/utils/util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ecommerce_app/src/utils/string_helper_extension.dart';

import '../firebase_notification.dart';
import '../models/employee.dart';
import '../utils/UBScaffold/ub_scaffold.dart';
import 'authentication/login.dart';
import 'mainPage.dart';
import 'package:http/http.dart' as http;

class OrderSummaryScreen extends StatefulWidget {
  final HomeScreenController homeScreenController;

  OrderSummaryScreen({
    Key? key,
    required this.homeScreenController,
  }) : super(key: key);
  static const String route = '/home';

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_OrderSummaryScreenState>()?.restartApp();
  }

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen>
    with WidgetsBindingObserver {
  AppLifecycleState appState = AppLifecycleState.resumed;
  bool requestTimerRunning = false;
  bool _isSubmittingOrder = false;
  bool _isLoadingLogin = false;
  var referenceID = Random().nextInt(9999999);
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _customerNumberController =
      TextEditingController();

  FocusNode _customerNumberNode = new FocusNode();

  num rate = 1;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  String? amount,
      versionNumber,
      buildNumber,
      version,
      errorMessage,
      notificationToken,
      newsText = "";

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late Customer customer;
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    WidgetsBinding.instance.addObserver(this);
    _customerNumberController.text =
        _firebaseAuth.currentUser?.phoneNumber ?? "";
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double getPrice() {
    double price = 0;
    for (int i = 0;
        i < widget.homeScreenController.productsPrices.length;
        i++) {
      price += num.tryParse(widget.homeScreenController.productsPrices[i]
                  .replaceAll(',', '') ??
              "0")! *
          num.tryParse(widget.homeScreenController.productsQuantities[i]
                  .replaceAll(',', '') ??
              "0")!;
    }

    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              toolbarHeight: 75.0,
              expandedHeight: 75.0,
              backgroundColor: Color(0xfffbfbfb),
              iconTheme: IconThemeData(color: Colors.black54),
              leading: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 12,
                  bottom: 12,
                ),
                child: RotatedBox(
                  quarterTurns:
                      (Localizations.localeOf(context).languageCode == 'ar')
                          ? 2
                          : 4,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      if (_isSubmittingOrder || _isLoadingLogin)
                        return;
                      else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xfffbfbfb),
                Color(0xfff7f7f7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            // Wrap the content in a SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // _appBar(),
                _title(),
                _buildProducts(),
                if ((widget.homeScreenController.employees
                        .firstWhere(
                            (element) =>
                                element.phoneNumber ==
                                FirebaseAuth.instance.currentUser?.phoneNumber,
                            orElse: () => Employee(name: null))
                        .name !=
                    null))
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: _buildUserPhoneNumber(),
                  ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 62,
                      right: 62,
                      top: 16,
                      bottom: 64,
                    ),
                    child: RaisedButtonV2(
                      disabled: _isSubmittingOrder || _isLoadingLogin,
                      isLoading: _isSubmittingOrder || _isLoadingLogin,
                      onPressed: () async {
                        if (!(widget.homeScreenController.isBanned ?? false)) {
                          await showConfirmationBottomSheet(
                            context: context,
                            // flare: 'assets/flare/pending.flr',
                            title: Localization.of(
                              context,
                              'are_you_sure_you_want_to_submit_this_request',
                            ),
                            message: ((Localizations.localeOf(context)
                                            .languageCode ==
                                        'ar')
                                    ? widget
                                        .homeScreenController.submissionTextAR
                                    : widget
                                        .homeScreenController.submissionText)
                                ?.replaceAll(r'\n', '\n')
                                .replaceAll(r"\'", "\'"),
                            confirmMessage: Localization.of(context, 'confirm'),
                            confirmAction: () async {
                              await confirmAction();
                            },
                            cancelMessage: Localization.of(context, 'cancel'),
                          );
                        } else {
                          await showActionBottomSheet(
                            context: context,
                            status: OperationStatus.error,
                            message: replaceVariable(
                              Localization.of(
                                context,
                                'banned_disclaimer',
                              ),
                              'value',
                              widget.homeScreenController.contactUsNumber ?? "",
                            ),
                            popOnPress: true,
                            dismissOnTouchOutside: false,
                            buttonMessage: Localization.of(
                              context,
                              'ok',
                            ).toUpperCase(),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          );
                          return;
                        }
                        // }
                      },
                      label: Localization.of(context, 'submit'),
                    ),
                  ),
                ),
                if (!(widget.homeScreenController.hideDisclaimer ?? true))
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 16, bottom: 48),
                    child: Text(
                      ((Localizations.localeOf(context).languageCode == 'ar')
                              ? widget
                                  .homeScreenController.orderSummaryDisclaimerAR
                              : widget.homeScreenController
                                  .orderSummaryDisclaimer) ??
                          "",
                      style: TextStyle(
                          fontSize: 12, color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserPhoneNumber() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: _customerNumberNode,
        keyboardType: TextInputType.phone,
        controller: _customerNumberController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r"[+0-9]"),
          ),
        ],
        enabled: !_isSubmittingOrder && !_isLoadingLogin,
        decoration: InputDecoration(
          labelText: Localization.of(context, 'customers_phone_number'),
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
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  var index = -1;
  Widget _buildProducts() {
    index = -1;
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: Border.all(
              width: 2.0,
              color: Colors.grey.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        padding: EdgeInsets.symmetric(vertical: 12),
        // color: Colors.grey.withOpacity(0.1),
        child: Column(
            children: widget.homeScreenController.productsLinks.map((x) {
          index += 1;
          return _item(index,
              isLastIndex: index ==
                  (widget.homeScreenController.productsLinks.length) - 1);
        }).toList()));
  }

  Column _item(var index, {bool isLastIndex = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
          child: Column(
            children: [
              if (index == 0)
                Row(
                  children: [
                    Text(
                      "${Localization.of(context, 'order_summary').toUpperCase()} #$referenceID",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    Text(
                      " (${widget.homeScreenController.productsQuantities.length} ${(widget.homeScreenController.productsImages.length) > 1 ? Localization.of(context, "items") : Localization.of(context, "item")})",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        // border: Border.all(
                        //   width: 1.0,
                        //   color: Colors.grey.withOpacity(0.4),
                        // ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: WKNetworkImage(
                        ((widget.homeScreenController.hideImage ?? true))
                            ? ""
                            : widget.homeScreenController.productsImages[index],
                        fit: BoxFit.contain,
                        width: 60,
                        height: 60,
                        defaultWidget: Image.asset(
                          "assets/images/login_logo.png",
                          width: 60,
                          height: 60,
                        ),
                        placeHolder: AssetImage(
                          'assets/images/placeholder.png',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width:
                                (widget.homeScreenController.showProductPrice ??
                                        false)
                                    ? 100
                                    : 150,
                            child: Text(
                              widget.homeScreenController.productsTitles[index]
                                          .toString()
                                          .toLowerCase() ==
                                      "product"
                                  ? widget
                                      .homeScreenController.productsLinks[index]
                                  : widget.homeScreenController
                                      .productsTitles[index],
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            margin: EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "${Localization.of(context, 'color:')} ${isNotEmpty(widget.homeScreenController.productsColors[index]) ? widget.homeScreenController.productsColors[index] : Localization.of(context, 'not_specified')}",
                              maxLines: 1,
                              style: TextStyle(
                                // fontSize: 15,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            margin: EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "${Localization.of(context, 'size:')} ${isNotEmpty(widget.homeScreenController.productsSizes[index]) ? widget.homeScreenController.productsSizes[index] : Localization.of(context, 'not_specified')}",
                              maxLines: 1,
                              style: TextStyle(
                                // fontSize: 15,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if ((widget.homeScreenController.showProductPrice ??
                                  false) &&
                              widget.homeScreenController
                                      .productsPrices[index] !=
                                  "0")
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: <Widget>[
                                  TitleText(
                                    text: '\$ ',
                                    color: LightColor.red,
                                    fontSize: 12,
                                  ),
                                  TitleText(
                                    text: widget.homeScreenController
                                        .productsPrices[index],
                                    fontSize: 14,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: 12,
                            end: 12,
                            top: num.tryParse(widget.homeScreenController
                                        .productsQuantities[index])! >
                                    1000
                                ? 0
                                : 10),
                        child: Text(
                          " ${(num.tryParse(widget.homeScreenController.productsQuantities[index])! < 100) && (num.tryParse(widget.homeScreenController.productsQuantities[index])! > 10) ? " " : ""}${num.tryParse(widget.homeScreenController.productsQuantities[index])! < 10 ? "  " : ""}${num.tryParse(widget.homeScreenController.productsQuantities[index])! > 100 && num.tryParse(widget.homeScreenController.productsQuantities[index])! < 1000 ? "" : ""}" +
                              widget.homeScreenController
                                  .productsQuantities[index],
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    Spacer(),
                    if ((widget.homeScreenController.showProductPrice ??
                            false) &&
                        (num.tryParse(widget
                                    .homeScreenController.productsPrices[index]
                                    .replaceAll(',', ''))
                                ?.toStringAsFixed(2) !=
                            "0.00"))
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(height: 1),
                          Row(
                            children: <Widget>[
                              TitleText(
                                text: '\$ ',
                                color: LightColor.red,
                                fontSize: 12,
                              ),
                              TitleText(
                                text:
                                    "${(num.tryParse(widget.homeScreenController.productsQuantities[index].replaceAll(',', ''))! * num.tryParse(widget.homeScreenController.productsPrices[index].replaceAll(',', ''))!).toStringAsFixed(2)}",
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isLastIndex)
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Divider(
                    thickness: 1,
                    color: Colors.black26.withOpacity(0.3),
                  ),
                ),
              if (isLastIndex &&
                  !(widget.homeScreenController.showProductsSubtotal ?? false))
                SizedBox(height: 24),
              if (isLastIndex &&
                  (widget.homeScreenController.showProductsSubtotal ?? false))
                Padding(
                  padding:
                      const EdgeInsets.only(top: 32.0, left: 16, right: 16),
                  child: Divider(
                    thickness: 1,
                    color: Colors.black26.withOpacity(0.3),
                  ),
                ),
              if (isLastIndex &&
                  (widget.homeScreenController.showProductsSubtotal ?? false))
                Padding(
                  padding:
                      EdgeInsetsDirectional.only(top: 16, start: 75, end: 75),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${Localization.of(context, 'subtotal')}",
                            style: TextStyle(
                              // overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "\$ ${getPrice().toStringAsFixed(2)}",
                            style: TextStyle(
                              // overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "${Localization.of(context, 'discount')}",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "-\$5",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "${Localization.of(context, 'service_fee')}",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "\$10",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "${Localization.of(context, 'shipping')}",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "TBA",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "${Localization.of(context, 'customs')}",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "TBA",
                              style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Divider(
                          thickness: 1,
                          color: Colors.black26.withOpacity(0.6),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Text(
                              Localization.of(context, 'total'),
                              style: TextStyle(
                                // overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "\$${1699.72.toStringAsFixed(2)}",
                              style: TextStyle(
                                // overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w900,
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
      ],
    );
  }

  Future<void> confirmAction() async {
    if (_firebaseAuth.currentUser?.phoneNumber == null) {
      await userNotRegistered();
    } else {
      await Navigator.of(context).pop;
      await submitOrder();
    }
  }

  Future<void> userNotRegistered() async {
    await showConfirmationBottomSheet(
      context: context,
      flare: 'assets/flare/error.flr',
      title: Localization.of(
        context,
        'please_login_to_use_this_feature',
      ),
      // message: "",
      confirmMessage: Localization.of(context, 'login'),
      confirmAction: () async {
        var customerNamee = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FirebaseNotification(child: LoginPage()),
          ),
        );
        try {
          setState(() {
            _isLoadingLogin = true;
          });

          if (isNotEmpty(customerNamee)) {
            await Navigator.of(context).pop;
            await Navigator.of(context).pop;

            notificationToken = await FirebaseMessaging.instance.getToken();
            var result = await FirebaseFirestore.instance
                .collection('Customers')
                .doc(_firebaseAuth.currentUser?.phoneNumber ?? '')
                .snapshots()
                .first;
            if (result.data() == null) {
              var newCustomer = Customer(
                name: customerNamee.toString().capitalize,
                phoneNumber: _firebaseAuth.currentUser?.phoneNumber ?? '',
                notificationToken: notificationToken,
                coins: 0,
              );

              customer = newCustomer;
              widget.homeScreenController.customer = newCustomer;

              await FirebaseFirestore.instance
                  .collection('Customers')
                  .doc(_firebaseAuth.currentUser?.phoneNumber ?? '')
                  .set(newCustomer.toJson());
            } else {
              customer =
                  Customer.fromJson(result.data() as Map<dynamic, dynamic>);
              customer = Customer(
                name: customerNamee.toString().capitalize,
                phoneNumber: customer.phoneNumber,
                notificationToken: notificationToken,
                coins: customer.coins ?? 0,
              );

              widget.homeScreenController.customer = Customer(
                name: customerNamee.toString().capitalize,
                phoneNumber: customer.phoneNumber,
                notificationToken: notificationToken,
                coins: customer.coins ?? 0,
              );

              await FirebaseFirestore.instance
                  .collection('Customers')
                  .doc(customer.phoneNumber)
                  .set(Customer(
                    name: customerNamee.toString().capitalize,
                    phoneNumber: customer.phoneNumber,
                    notificationToken: notificationToken,
                    coins: customer.coins ?? 0,
                  ).toJson());
            }

            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // String activateNotificationForOrders = prefs.getString(
            //     'swiftShop_${_firebaseAuth.currentUser?.phoneNumber.toString().substring(1)}');
            //
            // if (activateNotificationForOrders == null ||
            //     activateNotificationForOrders != 'activated') {
            //   await FirebaseMessaging.instance.subscribeToTopic(
            //       'swiftShop_notifications_${_firebaseAuth.currentUser?.phoneNumber.toString().substring(1)}');
            //   await prefs.setString(
            //     'swiftShop_${_firebaseAuth.currentUser?.phoneNumber.toString().substring(1)}',
            //     'activated',
            //   );
            // }

            // setState(() {});
            // showSuccessBottomsheet(
            //   Localization.of(context, "login_successful"),
            //   closeOnTapOutside: false,
            //   shouldPop: false,
            //   onTap: () async {
            //     Navigator.of(context).pop(true);
            //     Navigator.of(context).pop(true);
            //     // Navigator.pushAndRemoveUntil(
            //     //     context,
            //     //     MaterialPageRoute(
            //     //       builder: (context) =>
            //     //           FirebaseNotification(child: MainPage()),
            //     //     ),
            //     //     (Route<dynamic> route) => false);
            //   },
            // );
            await submitOrder();
            showSuccessBottomsheet(
              Localization.of(context, "login_order_submitted_successfully"),
              closeOnTapOutside: false,
              shouldSetState: false,
              onTap: () async {
                await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FirebaseNotification(child: MainPage()),
                    ),
                    (Route<dynamic> route) => false);
              },
            );
          } else {
            setState(() {
              _isLoadingLogin = false;
            });
          }
        } catch (e) {
          print("error submitting order ${e.toString()}");
          setState(() {
            _isLoadingLogin = false;
          });
        }
      },
      cancelMessage: Localization.of(context, 'cancel'),
    );
  }

  Future<void> submitOrder() async {
    try {
      setState(() {
        _isSubmittingOrder = true;
      });
      notificationToken = await FirebaseMessaging.instance.getToken();
      DocumentReference orders =
          FirebaseFirestore.instance.collection('Orders').doc("Orders");
      // print("-" + customer?.phoneNumber + "-");
      // print("---------");
      // if (customer == null)
      //   FirebaseFirestore.instance
      //       .collection('Customers')
      //       .doc(widget.user.phoneNumber)
      //       .set(Customer(
      //     phoneNumber: widget.user.phoneNumber,
      //     notificationToken: notificationToken,
      //     coins: customer?.coins ?? 0,
      //     totalMoneyIn: customer?.totalMoneyIn ?? 0,
      //     totalMoneyOut: customer?.totalMoneyOut ?? 0,
      //   ).toJson()),
      await Future.wait(
        [
          FirebaseFirestore.instance
              .collection('Customers')
              .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
              .collection("History")
              .doc(
                  "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}")
              .set(
                Order(
                  amount: 1234,
                  acceptedBy: "",
                  firstPayment: 0,
                  secondPayment: 0,
                  productsTitles: widget.homeScreenController.productsTitles,
                  productsQuantities:
                      widget.homeScreenController.productsQuantities,
                  productsLinks: widget.homeScreenController.productsLinks,
                  productsColors: widget.homeScreenController.productsColors,
                  productsSizes: widget.homeScreenController.productsSizes,
                  productsPrices: widget.homeScreenController.productsPrices,
                  productsImages: widget.homeScreenController.productsImages,
                  customerName: widget.homeScreenController.customer?.name,
                  orderSenderPhoneNumber:
                      FirebaseAuth.instance.currentUser?.phoneNumber,
                  phoneNumber: isNotEmpty(_customerNumberController.text)
                      ? _customerNumberController.text
                      : customer.phoneNumber,
                  locale: (Localizations.localeOf(context).languageCode == 'ar') ? 'ar' : 'en',
                  employeeWhoSentTheOrder: (widget
                          .homeScreenController.employees
                          .firstWhere(
                              (element) =>
                                  element.phoneNumber ==
                                  FirebaseAuth
                                      .instance.currentUser?.phoneNumber,
                              orElse: () => Employee(name: null))
                          .name ??
                      ""),
                  sentByEmployee: (widget.homeScreenController.employees
                          .firstWhere(
                              (element) =>
                                  element.phoneNumber ==
                                  FirebaseAuth
                                      .instance.currentUser?.phoneNumber,
                              orElse: () => Employee(name: null))
                          .name !=
                      null),
                  notificationToken: notificationToken,
                  acceptedTime: '',
                  referenceID: referenceID,
                  coins: 0,
                  shipmentStatus: [ShipmentStatus.awaitingCustomer],
                  orderStatus: [OrderStatus.pending],
                  sentTime:
                      "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
                ).toJson(),
              ),
          orders
              .collection(
                "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)}",
              )
              .doc(
                  "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}")
              // .doc(FirebaseAuth.instance.currentUser.phoneNumber)
              .set(
                Order(
                  amount: 1234,
                  acceptedBy: "",
                  firstPayment: 0,
                  secondPayment: 0,
                  productsTitles: widget.homeScreenController.productsTitles,
                  productsQuantities:
                      widget.homeScreenController.productsQuantities,
                  productsLinks: widget.homeScreenController.productsLinks,
                  productsColors: widget.homeScreenController.productsColors,
                  productsSizes: widget.homeScreenController.productsSizes,
                  productsPrices: widget.homeScreenController.productsPrices,
                  productsImages: widget.homeScreenController.productsImages,
                  customerName: widget.homeScreenController.customer?.name,
                  orderSenderPhoneNumber:
                      FirebaseAuth.instance.currentUser?.phoneNumber,
                  phoneNumber: isNotEmpty(_customerNumberController.text)
                      ? _customerNumberController.text
                      : customer.phoneNumber,
                  locale: (Localizations.localeOf(context).languageCode == 'ar') ? 'ar' : 'en',
                  employeeWhoSentTheOrder: (widget
                          .homeScreenController.employees
                          .firstWhere(
                              (element) =>
                                  element.phoneNumber ==
                                  FirebaseAuth
                                      .instance.currentUser?.phoneNumber,
                              orElse: () => Employee(name: null))
                          .name ??
                      ""),
                  sentByEmployee: (widget.homeScreenController.employees
                          .firstWhere(
                              (element) =>
                                  element.phoneNumber ==
                                  FirebaseAuth
                                      .instance.currentUser?.phoneNumber,
                              orElse: () => Employee(name: null))
                          .name !=
                      null),
                  notificationToken: notificationToken,
                  acceptedTime: '',
                  referenceID: referenceID,
                  coins: 0,
                  shipmentStatus: [ShipmentStatus.awaitingCustomer],
                  orderStatus: [OrderStatus.pending],
                  sentTime:
                      "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
                ).toJson(),
              ),
          FirebaseFirestore.instance
              .collection(
                  widget.homeScreenController.SearchInOrdersCollectionName ??
                      "")
              .doc(
                  "${FirebaseAuth.instance.currentUser?.phoneNumber} ${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}")
              .set(
                Order(
                  amount: 1234,
                  acceptedBy: "",
                  firstPayment: 0,
                  secondPayment: 0,
                  productsTitles: widget.homeScreenController.productsTitles,
                  productsQuantities:
                      widget.homeScreenController.productsQuantities,
                  productsLinks: widget.homeScreenController.productsLinks,
                  productsColors: widget.homeScreenController.productsColors,
                  productsSizes: widget.homeScreenController.productsSizes,
                  productsPrices: widget.homeScreenController.productsPrices,
                  productsImages: widget.homeScreenController.productsImages,
                  customerName: widget.homeScreenController.customer?.name,
                  orderSenderPhoneNumber:
                      FirebaseAuth.instance.currentUser?.phoneNumber,
                  phoneNumber: isNotEmpty(_customerNumberController.text)
                      ? _customerNumberController.text
                      : customer.phoneNumber,
                  locale: (Localizations.localeOf(context).languageCode == 'ar') ? 'ar' : 'en',
                  employeeWhoSentTheOrder: (widget
                          .homeScreenController.employees
                          .firstWhere(
                              (element) =>
                                  element.phoneNumber ==
                                  FirebaseAuth
                                      .instance.currentUser?.phoneNumber,
                              orElse: () => Employee(name: null))
                          .name ??
                      ""),
                  sentByEmployee: (widget.homeScreenController.employees
                          .firstWhere(
                              (element) =>
                                  element.phoneNumber ==
                                  FirebaseAuth
                                      .instance.currentUser?.phoneNumber,
                              orElse: () => Employee(name: null))
                          .name !=
                      null),
                  notificationToken: notificationToken,
                  acceptedTime: '',
                  referenceID: referenceID,
                  coins: 0,
                  shipmentStatus: [ShipmentStatus.awaitingCustomer],
                  orderStatus: [OrderStatus.pending],
                  sentTime:
                      "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
                ).toJson(),
              ),
          // http.get(Uri.parse(
          //     "https://script.google.com/macros/s/AKfycbz-pNnfQNtnvT8jossI-QiK5kxTzzL5dGjDX-tZJbiSul7NKNzvDGYuajBkdbNk0tcX/exec" +
          //         "?requestID=1234" +
          //         "&customerName=John Doe" +
          //         "&acceptedBy=SomeName" +
          //         "&sentByEmployee=AnotherName" +
          //         "&employeeWhoSentTheOrder=EmployeeName" +
          //         "&shipmentStatus=Shipped" +
          //         "&firstPayment=100" +
          //         "&secondPayment=200")),
          http.get(
            Uri.parse(
              widget.homeScreenController.spreadSheetScriptURL! +
                  "?requestID=%23 ${referenceID.toString()}" +
                  "&customerName=${widget.homeScreenController.customer?.name}" +
                  "&phoneNumber=%2B${(isNotEmpty(_customerNumberController.text) ? _customerNumberController.text : customer.phoneNumber)?.replaceAll("+", "")}" +
                  "&acceptedBy=" +
                  "&sentByEmployee=${(widget.homeScreenController.employees.firstWhere((element) => element.phoneNumber == FirebaseAuth.instance.currentUser?.phoneNumber, orElse: () => Employee(name: null)).name != null)}" +
                  "&employeeWhoSentTheOrder=${(widget.homeScreenController.employees.firstWhere((element) => element.phoneNumber == FirebaseAuth.instance.currentUser?.phoneNumber, orElse: () => Employee(name: null)).name ?? "")}" +
                  "&shipmentStatus=${getShipmentStatusForEmployeeString(context, ShipmentStatus.awaitingCustomer)}" +
                  "&firstPayment=0" +
                  "&secondPayment=0",
            ),
          ),
        ],
      );
      widget.homeScreenController.productsTitles = [];
      widget.homeScreenController.productsLinks = [];
      widget.homeScreenController.productsQuantities = [];
      widget.homeScreenController.productsColors = [];
      widget.homeScreenController.productsSizes = [];
      widget.homeScreenController.productsPrices = [];
      widget.homeScreenController.productsImages = [];

      widget.homeScreenController.refreshView();

      showSuccessBottomsheet(
        Localization.of(context, "order_submitted_successfully"),
        closeOnTapOutside: false,
        onTap: () async {
          Navigator.of(context).pop();
        },
      );
      // setState(() {
      //   _isSubmittingOrder = false;
      // });
    } catch (e) {
      showErrorBottomsheet("Error submitting your order, please try again");
      print(e);
      setState(() {
        _isSubmittingOrder = false;
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
            quarterTurns:
                (Localizations.localeOf(context).languageCode == 'ar') ? 2 : 4,
            child: _icon(Icons.arrow_back_ios_new, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return GestureDetector(
      onTap: () {
        if (_isSubmittingOrder || _isLoadingLogin)
          return;
        else {
          Navigator.of(context).pop();
        }
      },
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

  Widget _title() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 30, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: Localization.of(context, 'order_s'),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: Localization.of(context, 'summary_s'),
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ));
  }

  void showSuccessBottomsheet(
    String message, {
    bool closeOnTapOutside = true,
    Function? onTap,
    bool shouldSetState = true,
    bool shouldPop = true,
  }) async {
    if (!mounted) return;
    String animResource;
    animResource = 'assets/flare/success.flr';
    // setState(() {
    Vibration.vibrate();
    // });

    await showBottomsheet(
      context: context,
      isScrollControlled: true,
      dismissOnTouchOutside: closeOnTapOutside,
      height: MediaQuery.of(context).size.height *
          (Theme.of(context).platform == TargetPlatform.iOS ? 0.27 : 0.3),
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 80,
              child: FlareActor(
                animResource,
                animation: 'animate',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      bottomWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: RaisedButtonV2(
              label: Localization.of(context, 'done'),
              // disabled: isLoading ?? false,
              onPressed: () async {
                if (shouldPop) Navigator.of(context).pop();
                if (onTap != null) onTap();
                if (shouldSetState) setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }

  void showErrorBottomsheet(
    String error, {
    bool dismissOnTouchOutside = true,
    bool showDoneButton = true,
    bool doublePop = false,
  }) async {
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
}

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DividerWithArrowPainter(),
      child: Container(
          // width: 200, // Set the desired width
          // height: 20,  // Set the desired height
          ),
    );
  }
}

class DividerWithArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke; // Set the style to stroke

    final double arrowWidth = 40.0;
    final double arrowHeight = 20.0;

    final double startX = 0.0;
    final double endX = size.width;
    final double centerY = size.height / 2;

    // Draw a horizontal line
    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), paint);

    // Draw an arrow pointing downwards in the middle
    final path = Path();
    path.moveTo(endX / 1.5 - arrowWidth / 2, centerY);
    path.lineTo(endX / 1.5 + arrowWidth / 2, centerY);
    path.lineTo(endX / 1.5, centerY + arrowHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
