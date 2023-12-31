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
import 'package:flutter_ecommerce_app/src/pages/authentication/login.dart';
import 'package:flutter_ecommerce_app/src/pages/orders/first_payment_bottomsheet.dart';
import 'package:flutter_ecommerce_app/src/pages/orders/second_payment_bottomsheet.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/loader.dart';
import 'package:flutter_ecommerce_app/src/utils/WKNetworkImage.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/utils/util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:gsheets/gsheets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ecommerce_app/src/utils/string_helper_extension.dart';

import '../../firebase_notification.dart';
import '../mainPage.dart';

// GoogleAuth credentials
var _credentials = r'''
{
  "type": "service_account",
  "project_id": "buyandsellusdt-36e77",
  "private_key_id": "6b206fa2bbd15fa323ef42901d9908721e65cbb4",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDgxq4mhnH5GK9H\nOx02IJGDsIX8TZnWbW4T4Z4aYit/jFzvHl/RkOnulBsuXjd5lVpPloGEozQr35YV\n8qWlMLRvE+dJV5QRbcYRVBeHVDOQo2tWZ5epP/BuOZDQshecfxmq0Bg6Bob6N+zA\nI7pNNoAD0MzZrNjBtf9R7+EvBut3XtKr9MdcQ/AXEG+KY42QgylN3U9YPw8zMLf1\ngVFFZSgZPYmfpgSzoBEtjlFdhrzRxuTG7sxkgxiw3tpiCV90v9HHrNbOrJYihx3W\nHeyPHdRA5ohYaNNS5sAPa28rhrxxNQrvA4FVbYDSbOWRHg/azhIwSDq1a86VwHCA\ndP0bJYQxAgMBAAECggEAAVhrZoIrlD11PPejzjx60n4BHDmcEU7sS2crbTUT6TCl\nnoZ5mB4GNB9VDT2TNG3nxTV9czOZLv9tpG7VpQ+Xh/bTzZyeFbDGejlh+eaoY+TQ\n+bITk+QcMs1Qj1ESMJH0zRq+TDmxFYTdVBnbQpNIvi5VpgT48wKkv8awD6F/oE6L\nE/fpIkEE2iwa/uvBLX5KLdtS/liDjVpjC1pO6dIoqrcxKxe422wB+yCVDwLBL8+P\n7ud4zlOgF3dD+fdm7OIH/utjq4aLT/EMuwrgfp3qb7CiuSwK09ljMRY7o1Vul1z6\nXN+Th6hb4eGiLGYMcmmSNzC8Gin1WtdWMnDSVgJeFwKBgQD597OawOEsFAr6M5TV\noE0+wGbUaFeD/WBHDCnsIMq8uVPYeBnsZqV4fw4jKajVyWFBlQGgg8N2JADvXzXO\nQu5oLfCWsBIqQu+Ri+YCk27DMkJTvTDyJMg58HOiiNeKGY52QxzgXWZdNhLlunG3\nHhK+GGlFh3uxfIwA5Nfv+j7ZZwKBgQDmM1iGvF5anZFPHnGukIx5x+UFJ7Ky1JCA\ncWHDfJvO1FiC2+pnuaBy16Y8rNKNu5PdLIqj6hsN2HZdq1rt9K0r1dNcHKf7KAWN\nLv1OI2BEPk9/Z+PeVt4dSv5BCH8aVFE9/v+KmiyjZCQl65ACMOkA0JfB6kCmIJwm\nwsh+0ZN+pwKBgE392ywNwjPejQ5Dycxdl7xci7j6VVP5WnDQesQR9y+rI14HGw+H\nd1mBSwftl6AclRvBQiCy++mAkkodiswwVfJrYwWhKgnFmLnwzHNBTO3aYJeAECV9\nFHv/ahTsXVPZZXnAtuHKQoYSuRK0eYaI+5AUTcRD4XQfSA9/V2Co07NBAoGBAIp8\nJSuZMqIM3JfeVsGPkBLLIInDYguXOP8sNoYl9o2szTqcFh4kW9P6y7UAuwIs8D1E\nSHtnoLLpn/ul1GQGqA8Q6cAmNSAw6XYP6K8TNRyY57Zbx4fAdorkzKRO+jfata04\nNH8rVONOoTh2yAGpbuLgmgs8Y3wNbiMbVwaECdlNAoGANE78MYxsA2Fg9/cGMlf/\neaeLCHMlM/ANbV/v3imbSw09AwdjvfHy+yfcxE5m+LSeureFynx/js7ctbAzEOHU\nm+Nwd3kvkw4WQGMHaxozeFDtpZ/upGmHUA6z7MeKWg9ka6PMhg9oHDEdqWFdmC6P\nq2hxAymsVfVdyojX6GmZJWk=\n-----END PRIVATE KEY-----\n",
  "client_email": "wkbeast@buyandsellusdt-36e77.iam.gserviceaccount.com",
  "client_id": "110430103338366485166",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/wkbeast%40buyandsellusdt-36e77.iam.gserviceaccount.com"
}
''';

class OrderScreen extends StatefulWidget {
  final HomeScreenController homeScreenController;
  final Order order;

  OrderScreen({
    Key key,
    this.homeScreenController,
    this.order,
  }) : super(key: key);
  static const String route = '/home';

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_OrderScreenState>().restartApp();
  }

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with WidgetsBindingObserver {
  AppLifecycleState appState = AppLifecycleState.resumed;
  bool requestTimerRunning = false;
  bool _isLoading = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  Order _order;

  num rate = 1;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  String amount,
      versionNumber,
      buildNumber,
      version,
      errorMessage,
      notificationToken,
      newsText = "";
  int amountWithFee, amountWithoutFee;
  List<String> adminPanelNames = [];
  List<String> managementNames = [];
  List<String> towns;
  String selectedCity;

  final _formKey = GlobalKey<FormState>();

  String selectedCountryPhoneCode;
  String selectedCountryIsoCode;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Customer customer;
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
    _order = widget.order;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double getPrice() {
    double price = 0;
    for (int i = 0; i < _order.productsPrices.length; i++) {
      price += num.tryParse(
              _order.productsPrices[i].replaceAll(',', '') ?? "0") *
          num.tryParse(_order.productsQuantities[i].replaceAll(',', '') ?? "0");
    }

    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 68),
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
                  _appBar(),
                  _title(),
                  _buildProducts(context),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Accepted by: ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                            Text(
                              widget.homeScreenController.employees
                                      .firstWhere(
                                          (emp) =>
                                              emp.phoneNumber ==
                                              FirebaseAuth.instance.currentUser
                                                  .phoneNumber,
                                          orElse: () => null)
                                      .name ??
                                  "",
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        if (_order.firstPayment.toString() != "0")
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                Text(
                                  "First payment: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                                Text(
                                  "\$" + _order.firstPayment.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_order.secondPayment.toString() != "0")
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                Text(
                                  "Last payment: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                                Text(
                                  "\$" + _order.secondPayment.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 62,
                          vertical: 16,
                        ),
                        child: RaisedButtonV2(
                          disabled:
                              _isLoading || isNotEmpty(_order.acceptedTime),
                          // _isLoading,
                          isLoading: _isLoading,
                          onPressed: () async {
                            await showConfirmationBottomSheet(
                              context: context,
                              title: Localization.of(
                                context,
                                'are_you_sure_you_want_to_contact_this_customer',
                              ),
                              confirmMessage:
                                  Localization.of(context, 'confirm'),
                              confirmAction: () async {
                                bool wasAbleToGetUpdatedOrder =
                                    await _getUpdatedOrder(popFirst: true);
                                if (wasAbleToGetUpdatedOrder ?? false) {
                                  await _updateAcceptedTime();
                                  try {
                                    openWhatsapp();
                                    await _getUpdatedOrder();
                                  } catch (e) {
                                    print(e);
                                    showErrorBottomsheet(
                                      replaceVariable(
                                        Localization.of(context,
                                            'an_error_has_occurred_value'),
                                        'value',
                                        e.toString(),
                                      ),
                                    );
                                  }
                                }
                              },
                              cancelMessage: Localization.of(context, 'cancel'),
                            );
                          },
                          label: isEmpty(_order.acceptedTime)
                              ? Localization.of(context, 'contact')
                              : Localization.of(context, 'contacted'),
                        ),
                      ),
                      if (_order.shipmentStatus[0] ==
                          ShipmentStatus.awaitingCustomer)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 62,
                            vertical: 16,
                          ),
                          child: RaisedButtonV2(
                            disabled:
                                _isLoading || isEmpty(_order.acceptedTime),
                            isLoading: _isLoading,
                            onPressed: () async {
                              await showConfirmationBottomSheet(
                                context: context,
                                title: Localization.of(
                                  context,
                                  'are_you_sure_the_customer_rejected',
                                ),
                                confirmMessage:
                                    Localization.of(context, 'confirm'),
                                confirmAction: () async {
                                  await Navigator.of(context).pop();
                                  bool wasAbleToGetUpdatedOrder =
                                      await _getUpdatedOrder();
                                  if (wasAbleToGetUpdatedOrder ?? false) {
                                    try {
                                      await _updateOrder(
                                        ShipmentStatus.customerRejected,
                                      );

                                      await _getUpdatedOrder();
                                      showSuccessBottomsheet(
                                        Localization.of(context,
                                            "order_status_updated_successfully"),
                                        closeOnTapOutside: true,
                                      );
                                    } catch (e) {
                                      print(e);
                                      showErrorBottomsheet(
                                        replaceVariable(
                                          Localization.of(context,
                                              'an_error_has_occurred_value'),
                                          'value',
                                          e.toString(),
                                        ),
                                      );
                                    }
                                  }
                                },
                                cancelMessage:
                                    Localization.of(context, 'cancel'),
                              );
                            },
                            label: Localization.of(context, 'customerRejected'),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 62,
                          vertical: 16,
                        ),
                        child: RaisedButtonV2(
                          disabled: _isLoading ||
                              isEmpty(_order.acceptedTime) ||
                              (_order.firstPayment != 0) ||
                              (_order.shipmentStatus[0] ==
                                      ShipmentStatus.completed ||
                                  _order.shipmentStatus[0] ==
                                      ShipmentStatus.customerRejected),
                          isLoading: _isLoading,
                          onPressed: () async {
                            bool wasAbleToGetUpdatedOrder =
                                await _getUpdatedOrder();
                            if (wasAbleToGetUpdatedOrder ?? false) {
                              if (isNotEmpty(_order.acceptedTime)) {
                                try {
                                  await showBottomsheet(
                                    context: context,
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
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
                                                size: 30,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                return _isLoading
                                                    ? null
                                                    : Navigator.of(context)
                                                        .pop();
                                              });
                                            })
                                      ],
                                    ),
                                    body: FirstPaymentBottomsheet(
                                      homeScreenController:
                                          widget.homeScreenController,
                                      order: _order,
                                      isBottomSheetLoading: (isLoad) {
                                        setState(() {
                                          _isLoading = isLoad;
                                        });
                                      },
                                    ),
                                  );

                                  await _getUpdatedOrder();
                                } catch (e) {
                                  print(e);
                                  showErrorBottomsheet(
                                    replaceVariable(
                                      Localization.of(context,
                                          'an_error_has_occurred_value'),
                                      'value',
                                      e.toString(),
                                    ),
                                  );
                                }
                              } else {
                                showErrorBottomsheet(
                                  Localization.of(context,
                                      'you_should_first_contact_this_customer'),
                                );
                              }
                            }
                          },
                          label: Localization.of(context, 'first_payment'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 62,
                          vertical: 16,
                        ),
                        child: RaisedButtonV2(
                          disabled: _isLoading ||
                              isEmpty(_order.acceptedTime) ||
                              _order.firstPayment == 0 ||
                              (_order.shipmentStatus[0] ==
                                      ShipmentStatus.completed ||
                                  _order.shipmentStatus[0] ==
                                      ShipmentStatus.customerRejected) ||
                              _order.shipmentStatus[0] ==
                                  ShipmentStatus.awaitingCustomerPickup,
                          isLoading: _isLoading,
                          onPressed: () async {
                            showBottomSheetList<String>(
                              context: context,
                              title:
                                  Localization.of(context, 'select_a_status'),
                              items: [
                                if (_order.shipmentStatus[0] !=
                                        ShipmentStatus.paid &&
                                    num.tryParse(
                                            _order.shipmentStatus[0].value) <
                                        num.tryParse(ShipmentStatus.paid.value))
                                  Localization.of(context, 'paid'),
                                if (_order.shipmentStatus[0] !=
                                        ShipmentStatus.awaitingShipment &&
                                    num.tryParse(
                                            _order.shipmentStatus[0].value) <
                                        num.tryParse(ShipmentStatus
                                            .awaitingShipment.value))
                                  Localization.of(context,
                                      'in_our_warehouse_outside_lebanon'),
                                if (_order.shipmentStatus[0] !=
                                        ShipmentStatus.orderOnTheWay &&
                                    num.tryParse(
                                            _order.shipmentStatus[0].value) <
                                        num.tryParse(
                                            ShipmentStatus.orderOnTheWay.value))
                                  Localization.of(context, 'orderOnTheWay'),
                                if (_order.shipmentStatus[0] !=
                                        ShipmentStatus.awaitingCustomerPickup &&
                                    num.tryParse(
                                            _order.shipmentStatus[0].value) <
                                        num.tryParse(ShipmentStatus
                                            .awaitingCustomerPickup.value))
                                  Localization.of(
                                      context, 'awaitingCustomerPickup'),
                                // if (_order.shipmentStatus[0] !=
                                //         ShipmentStatus.customerRejected &&
                                //     num.tryParse(
                                //             _order.shipmentStatus[0].value) <
                                //         num.tryParse(ShipmentStatus
                                //             .customerRejected.value))
                                //   Localization.of(context, 'customerRejected'),
                              ],
                              itemBuilder: (listTileName) {
                                return ListTile(
                                  title: Text(
                                    "${listTileName ?? ''}",
                                  ),
                                );
                              },
                              itemHeight: 60,
                              onItemSelected: (listTileName) async {
                                bool wasAbleToGetUpdatedOrder =
                                    await _getUpdatedOrder();
                                if (wasAbleToGetUpdatedOrder ?? false) {
                                  if (isNotEmpty(_order.acceptedTime) &&
                                      _order.firstPayment != 0) {
                                    try {
                                      await _updateOrder(
                                        (listTileName.toLowerCase() ==
                                                Localization.of(context, 'paid')
                                                    .toLowerCase())
                                            ? ShipmentStatus.paid
                                            : (listTileName.toLowerCase() ==
                                                    Localization.of(context,
                                                            'in_our_warehouse_outside_lebanon')
                                                        .toLowerCase())
                                                ? ShipmentStatus
                                                    .awaitingShipment
                                                : (listTileName.toLowerCase() ==
                                                        Localization.of(context,
                                                                'orderOnTheWay')
                                                            .toLowerCase())
                                                    ? ShipmentStatus
                                                        .orderOnTheWay
                                                    :
                                                    // (listTileName
                                                    //                         .toLowerCase() ==
                                                    //                     Localization.of(
                                                    //                             context,
                                                    //                             'customerRejected')
                                                    //                         .toLowerCase())
                                                    //                 ? ShipmentStatus
                                                    //                     .customerRejected
                                                    //                 :
                                                    ShipmentStatus
                                                        .awaitingCustomerPickup,
                                      );

                                      await _getUpdatedOrder();
                                      showSuccessBottomsheet(
                                        Localization.of(context,
                                            "order_status_updated_successfully"),
                                        closeOnTapOutside: true,
                                      );
                                    } catch (e) {
                                      print(e);
                                      showErrorBottomsheet(
                                        replaceVariable(
                                          Localization.of(context,
                                              'an_error_has_occurred_value'),
                                          'value',
                                          e.toString(),
                                        ),
                                      );
                                    }
                                  } else {
                                    showErrorBottomsheet(
                                      Localization.of(
                                          context,
                                          _order.firstPayment == 0
                                              ? 'the_customer_did_not_pay_yet'
                                              : 'you_should_first_contact_this_customer'),
                                    );
                                  }
                                }
                              },
                            );
                          },
                          label: Localization.of(context, 'update_status'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 62,
                          vertical: 16,
                        ),
                        child: RaisedButtonV2(
                          disabled: _isLoading ||
                              isEmpty(_order.acceptedTime) ||
                              (_order.firstPayment == 0) ||
                              (_order.shipmentStatus[0] ==
                                      ShipmentStatus.completed ||
                                  _order.shipmentStatus[0] ==
                                      ShipmentStatus.customerRejected),
                          isLoading: _isLoading,
                          onPressed: () async {
                            bool wasAbleToGetUpdatedOrder =
                                await _getUpdatedOrder();
                            if (wasAbleToGetUpdatedOrder ?? false) {
                              if (isNotEmpty(_order.acceptedTime)) {
                                try {
                                  await showBottomsheet(
                                    context: context,
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
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
                                                size: 30,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                return _isLoading
                                                    ? null
                                                    : Navigator.of(context)
                                                        .pop();
                                              });
                                            })
                                      ],
                                    ),
                                    body: SecondPaymentBottomsheet(
                                      homeScreenController:
                                          widget.homeScreenController,
                                      order: _order,
                                      isBottomSheetLoading: (isLoad) {
                                        setState(() {
                                          _isLoading = isLoad;
                                        });
                                      },
                                    ),
                                  );

                                  await _getUpdatedOrder();
                                } catch (e) {
                                  print(e);
                                  showErrorBottomsheet(
                                    replaceVariable(
                                      Localization.of(context,
                                          'an_error_has_occurred_value'),
                                      'value',
                                      e.toString(),
                                    ),
                                  );
                                }
                              } else {
                                showErrorBottomsheet(
                                  Localization.of(context,
                                      'you_should_first_contact_this_customer'),
                                );
                              }
                            }
                          },
                          label: Localization.of(context, 'second_payment'),
                        ),
                      ),
                      SizedBox(height: 36),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrder(ShipmentStatus status) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final gsheets = GSheets(_credentials);
      final ss =
          await gsheets.spreadsheet(widget.homeScreenController.spreadSheetID);
      final sheet =
          ss.worksheetByTitle(widget.homeScreenController.worksheetTitle);

      await Future.wait(
        [
          sheet.values.insertValueByKeys(
            getShipmentStatusForEmployeeString(
              context,
              status,
            ),
            columnKey: 'Shipment Status',
            rowKey: "# ${_order.referenceID}",
            eager: false,
          ),
          FirebaseFirestore.instance
              .collection('Orders')
              .doc('Orders')
              .collection(_order.sentTime.split(" at")[0])
              .doc(_order.sentTime)
              .update({
            'shipmentStatus': [status.value],
          }),
          FirebaseFirestore.instance
              .collection('Customers')
              .doc(_order.phoneNumber)
              .collection("History")
              .doc(_order.sentTime)
              .update({
            'shipmentStatus': [status.value],
          }),
          FirebaseFirestore.instance
              .collection(
                  widget.homeScreenController.SearchInOrdersCollectionName)
              .doc("${_order.phoneNumber} ${_order.sentTime}")
              .update({
            'shipmentStatus': [status.value],
          }),
        ],
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      showErrorBottomsheet(
        replaceVariable(
          Localization.of(context, 'an_error_has_occurred_value'),
          'value',
          e.toString(),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAcceptedTime() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final gsheets = GSheets(_credentials);
      final ss =
          await gsheets.spreadsheet(widget.homeScreenController.spreadSheetID);
      final sheet =
          ss.worksheetByTitle(widget.homeScreenController.worksheetTitle);

      await Future.wait(
        [
          sheet.values.insertValueByKeys(
            widget.homeScreenController.employees
                    .firstWhere(
                        (emp) =>
                            emp.phoneNumber ==
                            FirebaseAuth.instance.currentUser.phoneNumber,
                        orElse: () => null)
                    .name ??
                "",
            columnKey: 'Accepted By',
            rowKey: "# ${_order.referenceID}",
            eager: false,
          ),
          FirebaseFirestore.instance
              .collection('Orders')
              .doc('Orders')
              .collection(_order.sentTime.split(" at")[0])
              .doc(_order.sentTime)
              .update({
            'acceptedBy': widget.homeScreenController.employees
                    .firstWhere(
                        (emp) =>
                            emp.phoneNumber ==
                            FirebaseAuth.instance.currentUser.phoneNumber,
                        orElse: () => null)
                    .name ??
                "",
            'acceptedTime':
                "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
          }),
          FirebaseFirestore.instance
              .collection('Customers')
              .doc(_order.phoneNumber)
              .collection("History")
              .doc(_order.sentTime)
              .update({
            'acceptedBy': widget.homeScreenController.employees
                    .firstWhere(
                        (emp) =>
                            emp.phoneNumber ==
                            FirebaseAuth.instance.currentUser.phoneNumber,
                        orElse: () => null)
                    .name ??
                "",
            'acceptedTime':
                "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
          }),
          FirebaseFirestore.instance
              .collection(
                  widget.homeScreenController.SearchInOrdersCollectionName)
              .doc("${_order.phoneNumber} ${_order.sentTime}")
              .update({
            'acceptedBy': widget.homeScreenController.employees
                    .firstWhere(
                        (emp) =>
                            emp.phoneNumber ==
                            FirebaseAuth.instance.currentUser.phoneNumber,
                        orElse: () => null)
                    .name ??
                "",
            'acceptedTime':
                "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
          }),
        ],
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      showErrorBottomsheet(
        replaceVariable(
          Localization.of(context, 'an_error_has_occurred_value'),
          'value',
          e.toString(),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void openWhatsappNoPrefill() async {
    try {
      launch(
          'https://wa.me/${_order.phoneNumber}?text=Hello%2C%20we%20received%20your%20feedback.');
    } catch (e) {
      print("Open Whatsapp Error: ${e.toString()}");
    }
  }

  void openWhatsapp() async {
    try {
      bool isEnglish = _order.customerName.contains(RegExp(r'[a-zA-Z]'));
      if (isEnglish ?? false) {
        String text =
            "Welcome%20to%20Tloble%21%20We%27re%20thrilled%20to%20have%20you%20as%20our%20valued%20customer.%20Our%20goal%20is%20to%20provide%20you%20with%20a%20seamless%20and%20enjoyable%20experience.%0ALet%20us%20first%20confirm%20your%20order.%0A";
        text +=
            "%0AOrder%20Summary%20for%20Order%20%20%2A%23${_order.referenceID}%2A%0A";
        for (int index = 0; index < _order.productsTitles.length; index++) {
          text +=
              "%0A%2A%20%2A${isEmpty(_order.productsTitles[index]) || (_order.productsTitles[index].toString().toLowerCase() == "product") ? "${_order.productsTitles[index]}%20${index + 1}" : Uri.encodeComponent(_order.productsTitles[index])}%3A%2A%0A-%20Quantity%3A%20${_order.productsQuantities[index]}${isNotEmpty(_order.productsColors[index]) ? "%0A-%20Color%3A%20${_order.productsColors[index]}" : "%0A-%20Color%3A%20Not%20specified"}${isNotEmpty(_order.productsSizes[index]) ? "%0A-%20Size%3A%20${_order.productsSizes[index]}" : "%0A-%20Size%3A%20Not%20specified"}${isNotEmpty(_order.productsLinks[index]) ? "%0A-%20Link%3A%20${Uri.encodeComponent(_order.productsLinks[index])}" : ""}%0A";
        }
        text +=
            "%0AWe%20will%20begin%20processing%20your%20order%20after%20receiving%20the%20payment.%20You%20may%20pay%20through%20%2AOMT%2A%2C%20%2AWhish%2A%2C%20%2AUSDT%2A%20or%20%2Acash%2A%20at%20our%20office.";
        launch('https://wa.me/${_order.phoneNumber}?text=$text');
      } else {
        String text =
            "مرحبا%20بكم%20في%20Tloble%21%20نحن%20سعداء%20أن%20يكون%20لك%20كما%20عملائنا%20الكرام.%20هدفنا%20هو%20أن%20نقدم%20لك%20تجربة%20سلسة%20وممتعة.%0Aدعونا%20أولا%20تأكيد%20طلبك.";

        // for (int index = 0; index < _order.productsTitles.length; index++) {
        //   text += """
// ${isEmpty(_order.productsTitles[index]) || (_order.productsTitles[index].toString().toLowerCase() == "product") ? "*المنتج*%20" : "*" + Uri.encodeComponent(_order.productsTitles[index]) + "*"}
// %3A%2A%0A-%20الكمية%3A%20${_order.productsQuantities[index]}
// ${isNotEmpty(_order.productsColors[index]) ? "- اللون:${_order.productsColors[index]}" : ""}
// ${isNotEmpty(_order.productsSizes[index]) ? "- الحجم:${_order.productsSizes[index]}" : ""}
// """;
        //- الرابط: ${_order.productsLinks[index]}
        // }
        // text += """
// سنبدأ معالجة طلبك بعد تلقي الدفع. يمكنك الدفع من خلال *OMT* ، *Whish* ، *USDT* أو *المال* في مكتبنا.
// """;

        launch(
          // 'https://wa.me/${widget.order?.phoneNumber}?text=مرحبًا، لقد تلقينا طلبك ${(widget.order.action.toLowerCase() == 'buy') ? Localization.of(context, 'for_buy_ar').toLowerCase() : Localization.of(context, 'for_sell_ar').toLowerCase()} بقيمة \$ ${widget.order.amount}.'),
          'https://wa.me/${_order?.phoneNumber}?text=$text',
        );
      }
    } catch (e) {
      print("Open Whatsapp Error: ${e.toString()}");
    }
  }

  Future<bool> _getUpdatedOrder({bool popFirst = false}) async {
    try {
      if (popFirst ?? false) await Navigator.of(context).pop();
      setState(() {
        _isLoading = true;
      });
      var data = await FirebaseFirestore.instance
          .collection('Orders')
          .doc('Orders')
          .collection(_order.sentTime.split(" at")[0])
          .where("referenceID", isEqualTo: _order.referenceID)
          .get();

      if (data != null && data.docs.isNotEmpty) {
        _order = Order.fromJson(data.docs[0].data());
        setState(() {
          _isLoading = false;
        });
        return true;
      } else {
        showErrorBottomsheet(
          Localization.of(
            context,
            'order_not_found',
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return false;
      }
    } catch (e) {
      showErrorBottomsheet(
        replaceVariable(
          Localization.of(
            context,
            'an_error_has_occurred_value',
          ),
          'value',
          "${e.toString()}",
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  var index = -1;
  Widget _buildProducts(BuildContext buildContext) {
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
            children: _order.productsLinks.map((x) {
          index += 1;
          return _item(
            index,
            isLastIndex: index == (_order.productsLinks.length ?? 0) - 1,
            buildContext: buildContext,
          );
        }).toList()));
  }

  Column _item(
    var index, {
    bool isLastIndex = false,
    BuildContext buildContext,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
          child: Column(
            children: [
              if (index == 0)
                Row(
                  children: [
                    Builder(builder: (BuildContext buildContext) {
                      return InkWell(
                        onTap: () {
                          if (isNotEmpty(_order.acceptedTime) &&
                              (widget.homeScreenController.employees
                                      .firstWhere((element) =>
                                          element.phoneNumber ==
                                          FirebaseAuth
                                              .instance.currentUser.phoneNumber)
                                      .name
                                      .toLowerCase() ==
                                  _order.acceptedBy.toLowerCase())) {
                            Clipboard.setData(
                              new ClipboardData(
                                  text: widget.order.referenceID.toString()),
                            ).then((result) {
                              final snackBar = SnackBar(
                                content: Text('Copied order id to Clipboard'),
                                action: SnackBarAction(
                                  label: 'Done',
                                  onPressed: () {},
                                ),
                              );
                              Scaffold.of(buildContext).showSnackBar(snackBar);
                            });
                          } else {
                            final snackBar = SnackBar(
                              content: Text(
                                  'Accept the request to be able to copy the order id.'),
                              action: SnackBarAction(
                                label: 'Done',
                                onPressed: () {},
                              ),
                            );
                            Scaffold.of(buildContext).showSnackBar(snackBar);
                          }
                        },
                        child: Text(
                          "${Localization.of(context, 'order_summary').toUpperCase()} #${_order.referenceID}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      );
                    }),
                    Text(
                      " (${_order.productsQuantities.length ?? 0} ${(_order.productsImages.length ?? 0) > 1 ? "Items" : "Item"})",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 100,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color:
                              getShipmentStatusColor(_order.shipmentStatus[0]),
                          borderRadius: BorderRadius.circular(10)),
                      child: TitleText(
                        text: getShipmentStatusForEmployeeString(
                          context,
                          _order.shipmentStatus[0],
                        ),
                        fontSize: 12,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              if (index == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Builder(builder: (BuildContext buildContext) {
                        return InkWell(
                          onLongPress: () {
                            if (_order.shipmentStatus[0] ==
                                    ShipmentStatus.awaitingCustomerPickup ||
                                (widget.homeScreenController?.isAdmin ??
                                    false)) {
                              try {
                                openWhatsappNoPrefill();
                              } catch (e) {
                                print("Error ${e.toString()}");
                              }
                            }
                          },
                          onTap: () {
                            if (isNotEmpty(_order.acceptedTime) &&
                                (widget.homeScreenController.employees
                                        .firstWhere((element) =>
                                            element.phoneNumber ==
                                            FirebaseAuth.instance.currentUser
                                                .phoneNumber)
                                        .name
                                        .toLowerCase() ==
                                    _order.acceptedBy.toLowerCase())) {
                              Clipboard.setData(new ClipboardData(
                                      text: widget.order.phoneNumber))
                                  .then((result) {
                                final snackBar = SnackBar(
                                  content:
                                      Text('Copied phone number to Clipboard'),
                                  action: SnackBarAction(
                                    label: 'Done',
                                    onPressed: () {},
                                  ),
                                );
                                Scaffold.of(buildContext)
                                    .showSnackBar(snackBar);
                              });
                            } else {
                              final snackBar = SnackBar(
                                content: Text(
                                    'Accept the request to be able to copy the phone number.'),
                                action: SnackBarAction(
                                  label: 'Done',
                                  onPressed: () {},
                                ),
                              );
                              Scaffold.of(buildContext).showSnackBar(snackBar);
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                "${Localization.of(context, 'customer_number')} ",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                              Text(
                                _order?.phoneNumber ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                        child: Builder(builder: (BuildContext buildContext) {
                          return InkWell(
                            onTap: () {
                              if (isNotEmpty(_order.acceptedTime) &&
                                  (widget.homeScreenController.employees
                                          .firstWhere((element) =>
                                              element.phoneNumber ==
                                              FirebaseAuth.instance.currentUser
                                                  .phoneNumber)
                                          .name
                                          .toLowerCase() ==
                                      _order.acceptedBy.toLowerCase())) {
                                Clipboard.setData(new ClipboardData(
                                        text: widget.order.customerName))
                                    .then((result) {
                                  final snackBar = SnackBar(
                                    content: Text(
                                        'Copied customer name to Clipboard'),
                                    action: SnackBarAction(
                                      label: 'Done',
                                      onPressed: () {},
                                    ),
                                  );
                                  Scaffold.of(buildContext)
                                      .showSnackBar(snackBar);
                                });
                              } else {
                                final snackBar = SnackBar(
                                  content: Text(
                                      'Accept the request to be able to copy the customer name.'),
                                  action: SnackBarAction(
                                    label: 'Done',
                                    onPressed: () {},
                                  ),
                                );
                                Scaffold.of(buildContext)
                                    .showSnackBar(snackBar);
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  "${Localization.of(context, 'customer_name')} ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                                Text(
                                  _order.customerName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
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
                        _order.productsImages[index],
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
                          Padding(
                            padding: EdgeInsets.only(top: 0.0, bottom: 4.0),
                            child:
                                Builder(builder: (BuildContext buildContext) {
                              return InkWell(
                                onLongPress: () {
                                  if (isNotEmpty(_order.acceptedTime) &&
                                      (widget.homeScreenController.employees
                                              .firstWhere((element) =>
                                                  element.phoneNumber ==
                                                  FirebaseAuth.instance
                                                      .currentUser.phoneNumber)
                                              .name
                                              .toLowerCase() ==
                                          _order.acceptedBy.toLowerCase())) {
                                    Clipboard.setData(new ClipboardData(
                                            text: widget.order.customerName))
                                        .then((result) {
                                      final snackBar = SnackBar(
                                        content: Text(
                                            'Copied product link to Clipboard'),
                                        action: SnackBarAction(
                                          label: 'Done',
                                          onPressed: () {},
                                        ),
                                      );
                                      Scaffold.of(buildContext)
                                          .showSnackBar(snackBar);
                                    });
                                  } else {
                                    final snackBar = SnackBar(
                                      content: Text(
                                          'Accept the request to be able to copy the product link.'),
                                      action: SnackBarAction(
                                        label: 'Done',
                                        onPressed: () {},
                                      ),
                                    );
                                    Scaffold.of(buildContext)
                                        .showSnackBar(snackBar);
                                  }
                                },
                                onTap: () async {
                                  try {
                                    if (isNotEmpty(_order.acceptedTime) &&
                                        (widget.homeScreenController.employees
                                                .firstWhere((element) =>
                                                    element.phoneNumber ==
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        .phoneNumber)
                                                .name
                                                .toLowerCase() ==
                                            _order.acceptedBy.toLowerCase())) {
                                      bool isIOS = Theme.of(context).platform ==
                                          TargetPlatform.iOS;
                                      var url = _order.productsLinks[index];
                                      if (isIOS) {
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          print('Could not launch $url');
                                          throw Exception(
                                              'Could not launch $url');
                                        }
                                      } else {
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          print('Could not launch $url');
                                          throw Exception(
                                              'Could not launch $url');
                                        }
                                      }
                                    } else {
                                      showErrorBottomsheet(
                                        'Please accept the order.',
                                      );
                                    }
                                  } catch (e) {
                                    print(e);
                                    showErrorBottomsheet(
                                      'An error has occurred: $e',
                                    );
                                  }
                                },
                                child: Text(
                                  "Product Link",
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              );
                            }),
                          ),
                            Container(
                              width: (widget.homeScreenController
                                          .showProductPrice ??
                                      false)
                                  ? 100
                                  : 150,
                              child: Text(
                                _order.productsTitles[index],
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
                              "${Localization.of(context, 'color:')} ${isNotEmpty(_order.productsColors[index]) ? _order.productsColors[index] : Localization.of(context, 'not_specified')}",
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
                              "${Localization.of(context, 'size:')} ${isNotEmpty(_order.productsSizes[index]) ? _order.productsSizes[index] : Localization.of(context, 'not_specified')}",
                              maxLines: 1,
                              style: TextStyle(
                                // fontSize: 15,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if ((widget.homeScreenController.showProductPrice ??
                              false))
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
                                    text: _order.productsPrices[index],
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
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                      ),
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        iconSize: 22,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        hint: Center(
                          child: Text(
                            "    " + _order.productsQuantities[index],
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    if ((widget.homeScreenController.showProductPrice ?? false))
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
                                    "${(num.tryParse(_order.productsQuantities[index].replaceAll(',', '')) * num.tryParse(_order.productsPrices[index].replaceAll(',', ''))).toStringAsFixed(2)}",
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

  void _getOrderInfo() async {
    String text =
        'Welcome%20to%20Tloble%21%20We%27re%20thrilled%20to%20have%20you%20as%20our%20valued%20customer.%20Our%20goal%20is%20to%20provide%20you%20with%20a%20seamless%20and%20enjoyable%20experience.%20Let%20us%20first%20confirm%20your%20order.%0A%0AOrder%20Summary%20for%20Order%20%2A%23%2A%0A%2A%20Item%201%3A%20Quantity%20-%205%2C%20Link%3A%20%0A%2A%20Item%202%3A%20Quantity%20-%202%2C%20Link%3A%20%0A%0AWe%20will%20begin%20processing%20your%20order%20after%20receiving%20the%20payment.%20You%20may%20pay%20through%20OMT%2C%20Which%2C%20USDT%20or%20cash%20at%20our%20office.';
  }

  Future<void> confirmAction() async {
    await submitOrder();
  }

  Future<void> submitOrder() async {
    try {
      setState(() {
        _isLoading = true;
      });
      notificationToken = await FirebaseMessaging.instance.getToken();
      DocumentReference orders =
          FirebaseFirestore.instance.collection('Orders').doc("Orders");
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
      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(FirebaseAuth.instance.currentUser.phoneNumber)
          .collection("History")
          .doc(
              "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}")
          .set(
            Order(
              amount: 1234,
              acceptedBy: "",
              productsTitles: _order.productsTitles,
              productsQuantities: _order.productsQuantities,
              productsLinks: _order.productsLinks,
              productsColors: _order.productsColors,
              productsSizes: _order.productsSizes,
              productsPrices: _order.productsPrices,
              productsImages: _order.productsImages,
              customerName: widget.homeScreenController.customer?.name,
              employeeWhoSentTheOrder: widget.homeScreenController.employees
                      .firstWhere(
                          (emp) =>
                              emp.phoneNumber ==
                              FirebaseAuth.instance.currentUser.phoneNumber,
                          orElse: () => null)
                      .name ??
                  "",
              notificationToken: notificationToken,
              acceptedTime: '',
              referenceID: _order.referenceID,
              coins: 0,
              shipmentStatus: [ShipmentStatus.awaitingCustomer],
              orderStatus: [OrderStatus.pending],
              sentTime:
                  "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
            ).toJson(),
          );
      await orders
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
              productsTitles: _order.productsTitles,
              productsQuantities: _order.productsQuantities,
              productsLinks: _order.productsLinks,
              productsColors: _order.productsColors,
              productsSizes: _order.productsSizes,
              productsPrices: _order.productsPrices,
              productsImages: _order.productsImages,
              customerName: widget.homeScreenController.customer?.name,
              employeeWhoSentTheOrder: widget.homeScreenController.employees
                      .firstWhere(
                          (emp) =>
                              emp.phoneNumber ==
                              FirebaseAuth.instance.currentUser.phoneNumber,
                          orElse: () => null)
                      .name ??
                  "",
              notificationToken: notificationToken,
              acceptedTime: '',
              referenceID: _order.referenceID,
              coins: 0,
              shipmentStatus: [ShipmentStatus.awaitingCustomer],
              orderStatus: [OrderStatus.pending],
              sentTime:
                  "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
            ).toJson(),
          );
      await FirebaseFirestore.instance
          .collection(widget.homeScreenController.SearchInOrdersCollectionName)
          .doc(
              "${FirebaseAuth.instance.currentUser.phoneNumber} ${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}")
          .set(
            Order(
              amount: 1234,
              acceptedBy: "",
              productsTitles: _order.productsTitles,
              productsQuantities: _order.productsQuantities,
              productsLinks: _order.productsLinks,
              productsColors: _order.productsColors,
              productsSizes: _order.productsSizes,
              productsPrices: _order.productsPrices,
              productsImages: _order.productsImages,
              customerName: widget.homeScreenController.customer?.name,
              phoneNumber: FirebaseAuth.instance.currentUser.phoneNumber,
              employeeWhoSentTheOrder: widget.homeScreenController.employees
                      .firstWhere(
                          (emp) =>
                              emp.phoneNumber ==
                              FirebaseAuth.instance.currentUser.phoneNumber,
                          orElse: () => null)
                      .name ??
                  "",
              notificationToken: notificationToken,
              acceptedTime: '',
              referenceID: _order.referenceID,
              coins: 0,
              shipmentStatus: [ShipmentStatus.awaitingCustomer],
              orderStatus: [OrderStatus.pending],
              sentTime:
                  "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}",
            ).toJson(),
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
          await Navigator.of(context).pop();
        },
      );
      // setState(() {
      //   _isSubmittingOrder = false;
      // });
    } catch (e) {
      showErrorBottomsheet("Error submitting your order, please try again");
      setState(() {
        _isLoading = false;
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

  Widget _title() {
    return Container(
        margin: AppTheme.padding,
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
    Function onTap,
    bool shouldSetState = true,
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
      dismissOnTouchOutside: closeOnTapOutside ?? true,
      height: MediaQuery.of(context).size.height * 0.25,
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 80,
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
                  message ?? "",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
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
                await Navigator.of(context).pop();
                if (onTap != null) onTap();
                if (shouldSetState ?? true) setState(() {});
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
