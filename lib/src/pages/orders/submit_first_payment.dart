import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:gsheets/gsheets.dart';
import 'package:vibration/vibration.dart';

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

class SubmitFirstPaymentBottomsheet extends StatefulWidget {
  final HomeScreenController? homeScreenController;
  final Orders? order;
  final ValueChanged<bool>? isBottomSheetLoading;

  SubmitFirstPaymentBottomsheet({
    this.homeScreenController,
    this.order,
    this.isBottomSheetLoading,
  });

  @override
  State<StatefulWidget> createState() => _SubmitFirstPaymentBottomsheetState();
}

class _SubmitFirstPaymentBottomsheetState extends State<SubmitFirstPaymentBottomsheet> {
  bool _isLoading = false;
  String? firstPayment;
  late NavigatorState _nav;

  FocusNode firstPaymentNode = new FocusNode();
  String? country;
  String? transportation;


  @override
  void initState() {
    country = widget.homeScreenController?.defaultCountry;
    transportation = widget.homeScreenController?.defaultTransportation;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _nav = Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Localization.of(context, 'first_payment'),
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            Localization.of(context, 'enter_the_first_payment_received'),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 9),
          Center(
            child: Container(
              width: 75,
              child: DropdownButton<dynamic>(
                // Initial Value
                isExpanded: true,
                value: country as String,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: widget.homeScreenController!.countries
                    ?.whereType<String>() // Filter to include only strings
                    .toList()
                    .map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (dynamic newValue) {
                  setState(() {
                    country = newValue!;
                  });
                },
              ),
            ),
          ),

          Center(
            child: Container(
              width: 75,
              child: DropdownButton<dynamic>(
                // Initial Value
                isExpanded: true,
                value: transportation as String,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: widget.homeScreenController!.transportation
                    ?.whereType<String>() // Filter to include only strings
                    .toList()
                    .map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (dynamic newValue) {
                  setState(() {
                    transportation = newValue!;
                  });
                },
              ),
            ),
          ),
          _buildFirstPayment(),
          _buildFirstNext(),
          // _buildSubmitBtn()
        ],
      ),
    );
  }

  Widget _buildFirstNext() {
    int i = 0;

    String? orderID;
    String? link;
    String? image;
    String? orderDetails =
        "- Quantity: ${widget.order?.productsQuantities![i]}${(isEmpty(widget.order?.productsColors?[i]) || ((widget.order?.productsColors![i].toString().toLowerCase() == Localization.of(context, "not_specified").toLowerCase()) || (widget.order?.productsColors![i].toString().toLowerCase() == "not specified") || (widget.order?.productsColors![i].toString().toLowerCase() == "غير محدد"))) ? "" : "\n- Color: ${widget.order?.productsColors![i]}"}${(isEmpty(widget.order?.productsSizes?[i]) || ((widget.order?.productsSizes![i].toString().toLowerCase() == Localization.of(context, "not_specified").toLowerCase()) || (widget.order?.productsSizes![i].toString().toLowerCase() == "not specified") || (widget.order?.productsSizes![i].toString().toLowerCase() == "غير محدد"))) ? "" : "\n- Size: ${widget.order?.productsSizes![i]}"}";
    String? remarks;

    // * 7.4
    String? customerPrice;

    // / 7.15 and UAE 3.65
    String? orderedPrice;

    return Builder(
      builder: (BuildContext buildContext) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 62,
            vertical: 16,
          ),
          child: RaisedButtonV2(
            disabled: firstPayment?.isEmpty ?? true,
            onPressed: () async {
              i++;
              _nav.pop();
              await showBottomsheet(
                context: buildContext,
                height: MediaQuery.of(buildContext).size.height * 0.85,
                // dismissOnTouchOutside: false,
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
                          _nav.pop();
                          // for (int i = 0;
                          //     i <
                          //         (widget.order?.productsQuantities?.length ??
                          //             0);
                          //     i++) {
                          _buildFirstNext();
                          // }
                        }),
                  ],
                ),
                body: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Builder(
                    builder: (BuildContext buildContextt) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildFields(
                              buildContextt,
                              Localization.of(buildContextt, 'orderId_z'),
                              orderID),
                          _buildFields(buildContextt,
                              Localization.of(buildContextt, 'link_z'), link),
                          _buildFields(buildContextt,
                              Localization.of(buildContextt, 'image_z'), image),
                          _buildFields(
                              buildContextt,
                              Localization.of(buildContextt, 'order_details_z'),
                              orderDetails,
                              maxLines: 3),
                          _buildFields(
                              buildContextt,
                              Localization.of(
                                  buildContextt, 'customer_price_z'),
                              customerPrice),
                          _buildFields(
                              buildContextt,
                              Localization.of(buildContextt, 'ordered_price_z'),
                              orderedPrice),
                          _buildFields(
                              buildContextt,
                              Localization.of(buildContextt, 'remarks_z'),
                              remarks,
                              maxLines: 3),
                          if (i <
                              (widget.order?.productsQuantities?.length ?? 0))
                            _buildFirstNext(),
                          if (i >=
                              (widget.order?.productsQuantities?.length ?? 0))
                            _buildSubmitBtn(buildContextt),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
            label: Localization.of(buildContext, 'next'),
          ),
        );
      },
    );
  }

  Widget _buildFields(BuildContext buildContext, String label, String? text,
      {int maxLines = 1}) {
    return Container(
      width: MediaQuery.of(buildContext).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        keyboardType:
        (label == Localization.of(buildContext, 'ordered_price_z') ||
            label == Localization.of(buildContext, 'customer_price_z'))
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        enabled: !_isLoading,
        initialValue: text,
        onChanged: (txt) {
          // setState(() {
          if (label == Localization.of(buildContext, 'ordered_price_z'))
            text = (num.parse(txt) / 7.4).toString();
          if (label != Localization.of(buildContext, 'ordered_price_z'))
            text = txt;
          // });
        },
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
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

  Widget _buildSubmitBtn(BuildContext buildContext) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: RaisedButtonV2(
        isLoading: _isLoading,
        disabled: _isLoading || (firstPayment?.isEmpty ?? true),
        label: capitalize(Localization.of(buildContext, 'asd')),
        onPressed: () => _onSubmit(buildContext),
      ),
    );
  }

  void _onSubmit(BuildContext buildContext) async {
    // setState(() {
    if (widget.isBottomSheetLoading != null) widget.isBottomSheetLoading!(true);
    // });

    try {
      // await _updateFirstPaymentOrder();

      showSuccessBottomsheet(buildContext);
      // setState(() {
      if (widget.isBottomSheetLoading != null)
        widget.isBottomSheetLoading!(false);
      // });
    } catch (e) {
      showErrorBottomsheet(
        replaceVariable(
          Localization.of(
            context,
            'an_error_has_occurred_value',
          ),
          'value',
          "${e.toString()}",
        ) ??
            "",
      );
      setState(() {
        if (widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(false);
      });
    }
  }

  Future<void> _updateFirstPaymentOrder() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final gsheets = GSheets(_credentials);
      final ss = await gsheets
          .spreadsheet(widget.homeScreenController?.spreadSheetID ?? "");
      final sheet = ss
          .worksheetByTitle(widget.homeScreenController?.worksheetTitle ?? "");

      await Future.wait(
        [
          sheet!.values.insertValueByKeys(
            firstPayment!,
            columnKey: 'First Payment',
            rowKey: "# ${widget.order?.referenceID}",
            eager: false,
          ),
          sheet.values.insertValueByKeys(
            getShipmentStatusForEmployeeString(
              context,
              ShipmentStatus.paid,
            ) ??
                "",
            columnKey: 'Shipment Status',
            rowKey: "# ${widget.order?.referenceID}",
            eager: false,
          ),
          FirebaseFirestore.instance
              .collection('Orders')
              .doc('Orders')
              .collection(widget.order?.sentTime?.split(" at")[0] ?? "")
              .doc(widget.order?.sentTime)
              .update({
            'firstPayment': firstPayment,
            'shipmentStatus': [ShipmentStatus.paid.value],
          }),
          FirebaseFirestore.instance
              .collection('Customers')
              .doc(widget.order?.orderSenderPhoneNumber)
              .collection("History")
              .doc(widget.order?.sentTime)
              .update({
            'firstPayment': firstPayment,
            'shipmentStatus': [ShipmentStatus.paid.value],
          }),
          FirebaseFirestore.instance
              .collection(
              widget.homeScreenController?.SearchInOrdersCollectionName ??
                  "")
              .doc(
              "${widget.order?.orderSenderPhoneNumber} ${widget.order?.sentTime}")
              .update({
            'firstPayment': firstPayment,
            'shipmentStatus': [ShipmentStatus.paid.value],
          }),
        ],
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error first payment ${e}");
      showErrorBottomsheet(
        replaceVariable(
          Localization.of(context, 'an_error_has_occurred_value'),
          'value',
          e.toString(),
        ) ??
            "",
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showSuccessBottomsheet(BuildContext buildContext) async {
    // if (!mounted) return;
    String animResource;
    animResource = 'assets/flare/success.flr';
    // setState(() {
    Vibration.vibrate();
    // });

    await showBottomsheet(
      context: buildContext,
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
                  Localization.of(
                    context,
                    'first_payment_updated',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
      bottomWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          width: MediaQuery.of(buildContext).size.width,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: RaisedButtonV2(
              label: Localization.of(buildContext, 'done'),
              onPressed: () {
                // if (!mounted) return;
                Navigator.of(buildContext).pop();
                Navigator.of(buildContext).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  void showErrorBottomsheet(String error) async {
    if (!mounted) return;
    await showBottomSheetStatus(
      context: context,
      status: OperationStatus.error,
      message: error,
      popOnPress: true,
      dismissOnTouchOutside: false,
    );
  }

  Widget _buildFirstPayment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: firstPaymentNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r"[+0-9]"),
          ),
        ],
        enabled: !_isLoading,
        onChanged: (phoneNumber) {
          setState(() {
            firstPayment = phoneNumber;
          });
        },
        decoration: InputDecoration(
          labelText: Localization.of(context, 'amount'),
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
}
