import 'dart:typed_data';

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
import 'package:http/http.dart' as http;

import '../../themes/light_color.dart';
import '../../themes/theme.dart';
import '../../utils/WKNetworkImage.dart';
import '../../widgets/title_text.dart';

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

class FirstPaymentScreen extends StatefulWidget {
  final HomeScreenController? homeScreenController;
  final Orders? order;
  final ValueChanged<bool>? isBottomSheetLoading;

  FirstPaymentScreen({
    this.homeScreenController,
    this.order,
    this.isBottomSheetLoading,
  });

  @override
  State<StatefulWidget> createState() => _FirstPaymentScreenState();
}

class _FirstPaymentScreenState extends State<FirstPaymentScreen> {
  bool _isLoading = false;
  String? firstPayment;
  String? orderedPriceField;
  late NavigatorState _nav;

  FocusNode firstPaymentNode = new FocusNode();
  FocusNode orderedPriceNode = new FocusNode();
  String? country;
  String? transportation;
  PersistentBottomSheetController? bottomSheetController;

  @override
  void initState() {
    country = widget.homeScreenController?.defaultCountry;
    transportation = widget.homeScreenController?.defaultTransportation;
    items.add(_itemInfoBox());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _nav = Navigator.of(context);
    super.didChangeDependencies();
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
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
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildFirstPayment(),
                        _buildOrderedPrice(),
                        SizedBox(height: 32),
                        Center(
                          child: Container(
                            width: (country.toString().toLowerCase() == "uae")
                                ? 90
                                : 130,
                            child: DropdownButton<dynamic>(
                              isExpanded: true,
                              underline: Container(
                                width: 20,
                                color: Colors.transparent,
                                height: 30,
                              ),
                              value: country as String,
                              iconSize: 28,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: widget.homeScreenController!.countries
                                  ?.whereType<String>()
                                  .toList()
                                  .map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
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
                            width: 90,
                            child: DropdownButton<dynamic>(
                              // Initial Value

                              underline: Container(
                                width: 20,
                                color: Colors.transparent,
                                height: 30,
                              ),
                              isExpanded: true,
                              iconSize: 28,
                              value: transportation as String,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: widget.homeScreenController!.transportation
                                  ?.whereType<
                                      String>() // Filter to include only strings
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
                        _buildItemInfoBox(),
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 64.0, right: 64.0, top: 32.0),
                            child: RaisedButtonV2(
                              // disabled: firstPayment?.isEmpty ?? true,
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  LightColor.red),
                              onPressed: () async {
                                items.removeLast();
                                ordersIDList.removeLast();
                                ordersLinksList.removeLast();
                                ordersImagesList.removeLast();
                                ordersDetailsList.removeLast();
                                ordersRemarksPriceList.removeLast();

                                // if()
                                i--;
                                setState(() {});
                              },
                              label: Localization.of(context, 'Remove Item'),
                            ),
                          ),
                        _buildSubmitBtn(context),

                        SizedBox(height: 64),
                        // _buildSubmitBtn()
                      ],
                    ),
                  ),
                  // _showBottomsheet(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  int i = 0;
  List<String> ordersIDList = [];
  List<String> ordersLinksList = [];
  List<String> ordersImagesList = [];
  List<String> ordersDetailsList = [];
  List<String> ordersRemarksPriceList = [];

  String? orderID;
  String? link;
  String? image;
  String? orderDetails;
  String? remarks;
  bool? shouldReset = false;

  // * 7.4
  String? customerPrice;
  var imageLoaded;
  // / 7.15 and UAE 3.65
  String? orderedPrice;

  List<Widget> items = [];

  Column _buildItemInfoBox({bool updateReset = false}) {
    if (updateReset) items.add(_itemInfoBox(updateReset: updateReset));
    return Column(children: items);
  }

  Widget _itemInfoBox({bool updateReset = false}) {
    if (updateReset) shouldReset = updateReset;
    if (!(shouldReset ?? true)) {
      orderID = "";
      link = "";
      image = "";
      remarks = "";
      orderDetails = "";

      if ((widget.order?.productsQuantities?.length ?? 0) > i) {
        link = widget.order?.productsLinks![i];
        orderDetails = "${widget.order?.productsQuantities![i]} pcs";
      }

      ordersIDList.add(orderID ?? " ");
      ordersLinksList.add(link ?? " ");
      ordersImagesList.add(image ?? " ");
      ordersDetailsList.add(orderDetails ?? " ");
      ordersRemarksPriceList.add(remarks ?? " ");
    }

    if (shouldReset ?? false) {
      i++;

      orderID = "";
      link = "";
      image = "";
      remarks = "";
      orderDetails = "";

      if ((widget.order?.productsQuantities?.length ?? 0) > i) {
        link = widget.order?.productsLinks![i];
        orderDetails = "${widget.order?.productsQuantities![i]} pcs";
      }

      ordersIDList.add(orderID ?? " ");
      ordersLinksList.add(link ?? " ");
      ordersImagesList.add(image ?? " ");
      ordersDetailsList.add(orderDetails ?? " ");
      ordersRemarksPriceList.add(remarks ?? " ");

      shouldReset = false;
    }

    // _nav.pop();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Builder(
        builder: (BuildContext buildContextt) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 32),
              // imageWidget,
              Text(
                Localization.of(context, 'Item ') + (i + 1).toString(),
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildFields(
                buildContextt,
                Localization.of(buildContextt, 'orderId_z'),
                ordersIDList[i],
                maxLines: 2,
                index: i,
                onChanged: (i, value) {
                  ordersIDList[i] = value;
                  print(ordersIDList[i]);
                  setState(() {});
                  // orderID = txt;
                },
              ),
              _buildFields(
                buildContextt,
                Localization.of(buildContextt, 'link_z'),
                ordersLinksList[i],
                index: i,
                onChanged: (i, value) {
                  ordersLinksList[i] = value;
                  print(ordersLinksList[i]);
                  setState(() {});
                  // link = txt;
                },
              ),
              _buildFields(
                buildContextt,
                Localization.of(buildContextt, 'image_z'),
                ordersImagesList[i],
                index: i,
                onChanged: (i, value) async {
                  ordersImagesList[i] = value;
                  print(ordersImagesList[i]);
                  try {
                    final response =
                        await http.get(Uri.parse(ordersImagesList[i]));
                    imageLoaded = MemoryImage(
                      Uint8List.fromList(List<int>.from(response.bodyBytes)),
                    );
                    imageWidget;
                    setState(() {});
                  } catch (e) {
                    // Handle error loading image
                    print('Error loading image: $e');
                  }
                  setState(() {});
                  // image = txt;
                },
              ),
              _buildFields(
                buildContextt,
                Localization.of(buildContextt, 'order_details_z'),
                ordersDetailsList[i],
                maxLines: 8,
                index: i,
                onChanged: (i, value) {
                  ordersDetailsList[i] = value;
                  print(ordersDetailsList[i]);
                  // orderDetails = txt;
                },
              ),
              _buildFields(
                buildContextt,
                Localization.of(buildContextt, 'remarks_z'),
                ordersRemarksPriceList[i],
                maxLines: 4,
                index: i,
                onChanged: (i, value) {
                  ordersRemarksPriceList[i] = value;
                  print(ordersRemarksPriceList[i]);
                  // remarks = txt;
                },
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: RaisedButtonV2(
                  green: true,
                  // disabled: firstPayment?.isEmpty ?? true,
                  onPressed: () async {
                    _buildItemInfoBox(updateReset: true);
                    setState(() {});
                  },
                  label: Localization.of(context, 'Add Item'),
                ),
              ),

              // if (i < (widget.order?.productsQuantities?.length ?? 0))
              //   _buildFirstNext(),
              // if (i >= (widget.order?.productsQuantities?.length ?? 0))
              //   _buildSubmitBtn(buildContextt),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFields(BuildContext buildContext, String label, String? text,
      {int maxLines = 1,
      int index = 0,
      Function(int index, String value)? onChanged}) {
    return Container(
      width: MediaQuery.of(buildContext).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        // key: Key(i.toString()),
        keyboardType:
            (label == Localization.of(buildContext, 'ordered_price_z') ||
                    label == Localization.of(buildContext, 'customer_price_z'))
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.multiline,
        enabled: !_isLoading,
        initialValue: text,
        onChanged: (txt) {
          setState(() {
            onChanged?.call(index, txt);
          });
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

  Widget get imageWidget {
    return Container(
      key: Key(imageLoaded.toString()), // Add this line
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: (imageLoaded == null) ? BoxShape.circle : BoxShape.rectangle,
        image: DecorationImage(
          // fit: widget.fit ?? BoxFit.fill,
          image: (imageLoaded == null)
              ? AssetImage("assets/images/image_loading.gif")
              : imageLoaded,
        ),
      ),
    );
  }

  Widget _buildSubmitBtn(BuildContext buildContext) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
      child: RaisedButtonV2(
        isLoading: _isLoading,
        disabled: _isLoading ||
            (firstPayment?.isEmpty ?? true) ||
            (orderedPriceField?.isEmpty ?? true),
        label: capitalize(Localization.of(buildContext, 'submit')),
        onPressed: () => _onSubmit(buildContext),
      ),
    );
  }

  void _onSubmit(BuildContext buildContext) async {
    // if ((orderID?.isEmpty ?? true) &&
    //     (link?.isEmpty ?? true) &&
    //     (image?.isEmpty ?? true) &&
    //     (orderDetails?.isEmpty ?? true) &&
    //     (remarks?.isEmpty ?? true)) {
    // } else {
    //   ordersIDList.add(orderID ?? " ");
    //   ordersLinksList.add(link ?? " ");
    //   ordersImagesList.add(image ?? " ");
    //
    //   ordersDetailsList.add(orderDetails ?? " ");
    //   ordersRemarksPriceList.add(remarks ?? " ");
    // }
    orderID = null;
    link = null;
    image = null;
    remarks = null;
    orderDetails = null;
    link = null;
    orderDetails = null;

    setState(() {
      if (widget.isBottomSheetLoading != null)
        widget.isBottomSheetLoading!(true);
    });
    try {
      print("+++++++++++++");
      print(ordersIDList.toString());
      print(ordersLinksList.toString());
      print(ordersImagesList.toString());
      print(ordersDetailsList.toString());
      print(ordersRemarksPriceList.toString());
      print("+++++++++++++");

      await _updateFirstPaymentOrder(buildContext);

      showSuccessBottomsheet(buildContext);
      setState(() {
        if (widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(false);
      });
    } catch (e) {
      print(e);
      showErrorBottomsheet(e.toString());
      setState(() {
        if (widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(false);
      });
    }
  }

  Future<void> _updateFirstPaymentOrder(BuildContext buildContext) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final gsheets = GSheets(_credentials);
      final ss = await gsheets
          .spreadsheet(widget.homeScreenController?.spreadSheetID ?? "");
      final sheet = ss
          .worksheetByTitle(widget.homeScreenController?.worksheetTitle ?? "");
      // final phonee = widget.order?.phoneNumber?.replaceAll("+", "");

      /// fix multiple items
      for (int j = 0; j < ordersDetailsList.length; j++) {
        String linksss = ((ordersImagesList[j].length) > 2)
            ? ordersImagesList[j].substring(0, 2) == "//"
                ? "https://" + ordersImagesList[j]
                : ordersImagesList[j]
            : "";

        if ((ordersDetailsList.length - 1 == j)) {
          await http.get(
            Uri.parse(
              ((country.toString().toLowerCase() == "uae")
                      ? widget.homeScreenController?.UAESpreadSheetScriptURL!
                      : widget
                          .homeScreenController?.ChinaSpreadSheetScriptURL!)! +
                  "?transportation=$transportation" +
                  "&orderID=${Uri.encodeComponent(((ordersIDList.length - 1) >= j) ? ordersIDList[j] : "")}" +
                  "&image=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length - 1) >= j) ? ordersLinksList[j] : "")}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}" +
                  "&requestID=%23 ${widget.order?.referenceID}" +
                  "&customerName=${widget.order?.customerName}" +
                  "&phoneNumber=%2B${widget.order?.phoneNumber?.replaceAll("+", "")}" +
                  "&customerPrice=$firstPayment" +
                  "&customerLink=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length - 1) >= j) ? ordersLinksList[j] : "")}\", \"Product Link\")" +
                  "&orderedPrice=${((num.parse(orderedPriceField ?? "0") * ((country.toString().toLowerCase() == "uae") ? (widget.homeScreenController?.uaeCommission ?? 1) : (widget.homeScreenController?.chinaCommission ?? 1))) / ((country.toString().toLowerCase() == "uae") ? num.parse(widget.homeScreenController?.aedConversion ?? "1") : (widget.homeScreenController?.yuanRate ?? 1))).toString()}",
            ),
          );

          print("BEFORE)");

          /// Our warehouse spreadsheet
          await http.get(
            Uri.parse(
              ((country.toString().toLowerCase() == "uae")
                      ? widget.homeScreenController
                          ?.UAEWarehouseSpreadSheetScriptURL!
                      : (country.toString().toLowerCase() == "china (abed)")
                          ? widget.homeScreenController
                              ?.ChinaWarehouseSpreadSheetScriptURL!
                          : widget.homeScreenController
                              ?.GSHChinaSpreadSheetScriptURL!)! +
                  "?transportation=$transportation" +
                  "&orderID=${Uri.encodeComponent(((ordersIDList.length - 1) >= j) ? ordersIDList[j] : "")}" +
                  "&image=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length - 1) >= j) ? ordersLinksList[j] : "")}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}",
            ),
          );
          print("after");

          /// Our employee's spreadsheet
          await http.get(
            Uri.parse(
              ((country.toString().toLowerCase() == "uae")
                      ? widget
                          .homeScreenController?.TlobleUAESpreadSheetScriptURL!
                      : widget.homeScreenController
                          ?.TlobleChinaSpreadSheetScriptURL!)! +
                  "?transportation=$transportation" +
                  "&orderID=${Uri.encodeComponent(((ordersIDList.length - 1) >= j) ? ordersIDList[j] : "")}" +
                  "&image=\=hyperlink(\"${""}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}" +
                  "&requestID=%23 ${widget.order?.referenceID}" +
                  "&customerName=${widget.order?.customerName}" +
                  "&phoneNumber=%2B${widget.order?.phoneNumber?.replaceAll("+", "")}",
            ),
          );
        } else if (j != ordersDetailsList.length) {
          await http.get(
            Uri.parse(
              ((country.toString().toLowerCase() == "uae")
                      ? widget.homeScreenController?.UAESpreadSheetScriptURL!
                      : widget
                          .homeScreenController?.ChinaSpreadSheetScriptURL!)! +
                  "?transportation=$transportation" +
                  "&orderID=${Uri.encodeComponent(((ordersIDList.length) > j) ? ordersIDList[j] : "")}" +
                  "&image=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length) > j) ? ordersLinksList[j] : "")}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length) > j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length) > j) ? ordersRemarksPriceList[j] : "")}" +
                  "&requestID=%23 ${widget.order?.referenceID}" +
                  "&customerName=${widget.order?.customerName}" +
                  "&phoneNumber=%2B${widget.order?.phoneNumber?.replaceAll("+", "")}" +
                  "&customerLink=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length) > j) ? ordersLinksList[j] : "")}\", \"Product Link\")",
            ),
          );

          /// Our warehouse spreadsheet
          await http.get(
            Uri.parse(
              ((country.toString().toLowerCase() == "uae")
                      ? widget.homeScreenController
                          ?.UAEWarehouseSpreadSheetScriptURL!
                      : (country.toString().toLowerCase() == "china (abed)")
                          ? widget.homeScreenController
                              ?.ChinaWarehouseSpreadSheetScriptURL!
                          : widget.homeScreenController
                              ?.GSHChinaSpreadSheetScriptURL!)! +
                  "?transportation=$transportation" +
                  "&orderID=${Uri.encodeComponent(((ordersIDList.length - 1) >= j) ? ordersIDList[j] : "")}" +
                  "&image=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length - 1) >= j) ? ordersLinksList[j] : "")}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}",
            ),
          );

          /// Our employee's spreadsheet
          await http.get(
            Uri.parse(
              ((country.toString().toLowerCase() == "uae")
                      ? widget
                          .homeScreenController?.TlobleUAESpreadSheetScriptURL!
                      : widget.homeScreenController
                          ?.TlobleChinaSpreadSheetScriptURL!)! +
                  "?transportation=$transportation" +
                  "&orderID=${Uri.encodeComponent(((ordersIDList.length - 1) >= j) ? ordersIDList[j] : "")}" +
                  "&image=\=hyperlink(\"${""}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}" +
                  "&requestID=%23 ${widget.order?.referenceID}" +
                  "&customerName=${widget.order?.customerName}" +
                  "&phoneNumber=%2B${widget.order?.phoneNumber?.replaceAll("+", "")}",
            ),
          );
        }
      }

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
                  buildContext,
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
      showErrorBottomsheet(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    bottomSheetController?.close();
    super.dispose();
  }

  void showSuccessBottomsheet(BuildContext buildContext) async {
    if (!mounted) return;
    String animResource;
    animResource = 'assets/flare/success.flr';
    setState(() {
      Vibration.vibrate();
    });

    bottomSheetController = await showBottomsheet(
      context: buildContext,
      isScrollControlled: true,
      dismissOnTouchOutside: false,
      height: MediaQuery.of(buildContext).size.height * 0.3,
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
              width: MediaQuery.of(buildContext).size.width / 1.5,
              child: Center(
                child: Text(
                  // Localization.of(
                  //   context,
                  //   'first_payment_updated',
                  // ),
                  "First payment updated successfully",
                  textAlign: TextAlign.center,
                  // style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  //       fontSize: 14,
                  //       color: Colors.black,
                  //     ),
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
                // Navigator.of(buildContext).pop();
                setState(() {});
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

  Widget _buildOrderedPrice() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: orderedPriceNode,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        enabled: !_isLoading,
        onChanged: (phoneNumber) {
          setState(() {
            orderedPriceField = phoneNumber;
          });
        },
        decoration: InputDecoration(
          labelText: Localization.of(context, 'ordered_price_z'),
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

  Widget _buildFirstPayment() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: firstPaymentNode,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        enabled: !_isLoading,
        onChanged: (phoneNumber) {
          setState(() {
            firstPayment = phoneNumber;
          });
        },
        decoration: InputDecoration(
          labelText: Localization.of(context, 'customer_price_z'),
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
