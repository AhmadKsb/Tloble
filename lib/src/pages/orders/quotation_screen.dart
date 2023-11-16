import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;

import '../../themes/light_color.dart';
import '../../themes/theme.dart';
import '../../widgets/title_text.dart';

class QuotationScreen extends StatefulWidget {
  final HomeScreenController? homeScreenController;

  QuotationScreen({
    this.homeScreenController,
  });

  @override
  State<StatefulWidget> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  bool _isLoading = false;
  String? firstPayment;
  String? orderedPriceField;

  FocusNode firstPaymentNode = new FocusNode();
  FocusNode orderedPriceNode = new FocusNode();
  String? country;
  String? transportation;
  PersistentBottomSheetController? bottomSheetController;
  TextEditingController? _phoneNumberController = TextEditingController();

  @override
  void initState() {
    country = widget.homeScreenController?.defaultCountry;
    transportation = widget.homeScreenController?.defaultTransportation;
    _load();
    items.add(_itemInfoBox());

    super.initState();
  }

  void _load() {
    _phoneNumberController?.text = "+961";
    setState(() {});
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
                  // SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildPhoneNumber(),
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
                                ordersLinksList.removeLast();
                                ordersImagesList.removeLast();
                                ordersDetailsList.removeLast();
                                ordersRemarksPriceList.removeLast();
                                sellingPriceList.removeLast();

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
                  text: Localization.of(context, 'quotation'),
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ));
  }

  int i = 0;
  List<String> ordersLinksList = [];
  List<String> ordersImagesList = [];
  List<String> ordersDetailsList = [];
  List<String> ordersRemarksPriceList = [];
  List<String> sellingPriceList = [];

  String? link;
  String? image;
  String? orderDetails;
  String? sellingPrice;
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
      link = "";
      image = "";
      remarks = "";
      orderDetails = "";
      sellingPrice = "";

      link = "";
      orderDetails = "";

      ordersLinksList.add(link ?? " ");
      ordersImagesList.add(image ?? " ");
      ordersDetailsList.add(orderDetails ?? " ");
      sellingPriceList.add(sellingPrice ?? " ");
      ordersRemarksPriceList.add(remarks ?? " ");
    }

    if (shouldReset ?? false) {
      i++;

      link = "";
      image = "";
      remarks = "";
      orderDetails = "";

      link = "";
      sellingPrice = "";

      ordersLinksList.add(link ?? " ");
      ordersImagesList.add(image ?? " ");
      ordersDetailsList.add(orderDetails ?? " ");
      sellingPriceList.add(sellingPrice ?? " ");
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
                  setState(() {});
                  // image = txt;
                },
              ),
              _buildFields(
                buildContextt,
                Localization.of(buildContextt, 'selling_price'),
                sellingPriceList[i],
                index: i,
                onChanged: (i, value) {
                  sellingPriceList[i] = value;
                  print(sellingPriceList[i]);
                  // remarks = txt;
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
        disabled: _isLoading,
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
    link = null;
    image = null;
    remarks = null;
    orderDetails = null;
    link = null;
    orderDetails = null;

    try {
      print("+++++++++++++");
      print(_phoneNumberController?.text.toString());
      print(ordersLinksList.toString());
      print(ordersImagesList.toString());
      print(sellingPriceList.toString());
      print(ordersDetailsList.toString());
      print(ordersRemarksPriceList.toString());
      print("+++++++++++++");

      await _updateFirstPaymentOrder(buildContext);

      showSuccessBottomsheet(buildContext);
    } catch (e) {
      print(e);
      showErrorBottomsheet(e.toString());
    }
  }

  Future<void> _updateFirstPaymentOrder(BuildContext buildContext) async {
    try {
      setState(() {
        _isLoading = true;
      });
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
              (widget.homeScreenController?.QuotationSpreadSheetScriptURL!)! +
                  "?phoneNumber=${Uri.encodeComponent(_phoneNumberController?.text ?? "")}" +
                  "&image=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length - 1) >= j) ? ordersLinksList[j] : "")}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&customerPrice=${Uri.encodeComponent(((sellingPriceList.length - 1) >= j) ? sellingPriceList[j] : "")}" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}",
            ),
          );
          await http.get(
            Uri.parse(
              (widget.homeScreenController?.QuotationSpreadSheetScriptURL!)! +
                  "?phoneNumber=-------------" +
                  "&image=-------------" +
                  "&customerPrice=-------------" +
                  "&orderDetails=-------------" +
                  "&remarks=-------------",
            ),
          );
        } else if (j != ordersDetailsList.length) {
          await http.get(
            Uri.parse(
              (widget.homeScreenController?.QuotationSpreadSheetScriptURL!)! +
                  "?phoneNumber=${Uri.encodeComponent(_phoneNumberController?.text ?? "")}" +
                  "&image=\=hyperlink(\"${Uri.encodeComponent(((ordersLinksList.length - 1) >= j) ? ordersLinksList[j] : "")}\", IMAGE(\"${linksss}\",4,150,150))" +
                  "&customerPrice=${Uri.encodeComponent(((sellingPriceList.length - 1) >= j) ? sellingPriceList[j] : "")}" +
                  "&orderDetails=${Uri.encodeComponent(((ordersDetailsList.length - 1) >= j) ? ordersDetailsList[j] : "")}" +
                  "&remarks=${Uri.encodeComponent(((ordersRemarksPriceList.length - 1) >= j) ? ordersRemarksPriceList[j] : "")}",
            ),
          );
        }
      }

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
                  "Quotation uploaded successfully",
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
              onPressed: () async {
                // if (!mounted) return;
                // Navigator.of(buildContext).pop();

                Navigator.of(buildContext).pop();
                Navigator.of(buildContext).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuotationScreen(
                      homeScreenController: widget.homeScreenController,
                    ),
                  ),
                );
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

  Widget _buildPhoneNumber() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: firstPaymentNode,
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: Localization.of(context, 'phone_number'),
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
