import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/pages/orders/order_screen.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:vibration/vibration.dart';

class CheckCustomersOrderBottomsheet extends StatefulWidget {
  final HomeScreenController? controller;
  final ValueChanged<bool>? isBottomSheetLoading;

  CheckCustomersOrderBottomsheet({
    this.controller,
    this.isBottomSheetLoading,
  });

  @override
  State<StatefulWidget> createState() => _CheckCustomersOrderBottomsheetState();
}

class _CheckCustomersOrderBottomsheetState
    extends State<CheckCustomersOrderBottomsheet> {
  bool _loading = false;
  String? order;

  FocusNode orderNode = new FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Localization.of(context, 'check_customers_order'),
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 9),
          _buildOrderTextField(),
          _buildSubmitBtn()
        ],
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: RaisedButtonV2(
        isLoading: _loading,
        disabled: _loading || (order == null || order == 0),
        label: capitalize(Localization.of(context, 'search')),
        onPressed: _onSubmit,
      ),
    );
  }

  void _onSubmit() async {
    setState(() {
      if (widget.isBottomSheetLoading != null)
        widget.isBottomSheetLoading!(true);
      _loading = true;
    });

    try {
      var data = await FirebaseFirestore.instance
          .collection(widget.controller?.SearchInOrdersCollectionName ?? "")
          .where("referenceID", isEqualTo: num.tryParse(order ?? "0"))
          .get();

      if (data.docs.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderScreen(
              homeScreenController: widget.controller!,
              order: Order.fromJson(data.docs[0].data()),
            ),
          ),
        );
      } else {
        showErrorBottomsheet(
          Localization.of(
            context,
            'order_not_found',
          ),
        );
      }
      setState(() {
        _loading = false;
        if (widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(false);
      });
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
        _loading = false;
        if (widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(false);
      });
    }
  }

  void showSuccessBottomsheet() async {
    if (!mounted) return;
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
                  Localization.of(context, 'amount_added_successfully'),
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
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: RaisedButtonV2(
              label: Localization.of(context, 'done'),
              onPressed: () {
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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

  Widget _buildOrderTextField() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        focusNode: orderNode,
        enabled: !_loading,
        onChanged: (am) {
          setState(() {
            order = am;
          });
        },
        decoration: InputDecoration(
          labelText: Localization.of(context, 'reference_id_order'),
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
