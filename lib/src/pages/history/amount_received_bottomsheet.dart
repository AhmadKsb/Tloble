import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wkbeast/controllers/home_screen_controller.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/customer.dart';
import 'package:wkbeast/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:wkbeast/utils/BottomSheets/operation_status.dart';
import 'package:wkbeast/utils/buttons/raised_button.dart';
import 'package:wkbeast/utils/string_util.dart';

import '../../models/order.dart';

class AmountReceivedBottomsheet extends StatefulWidget {
  final HomeScreenController controller;
  final Order order;
  final ValueChanged<bool> received;
  final ValueChanged<bool> isBottomSheetLoading;
  final String selectedTime;
  final Customer customer;

  AmountReceivedBottomsheet({
    this.controller,
    this.order,
    this.received,
    this.selectedTime,
    this.isBottomSheetLoading,
    this.customer,
  });

  @override
  State<StatefulWidget> createState() => _AmountReceivedBottomsheetState();
}

class _AmountReceivedBottomsheetState extends State<AmountReceivedBottomsheet> {
  bool _loading = false;
  bool received = false;
  String amountReceived, amountPaid, notificationToken;

  FocusNode amountPaidNode = new FocusNode(),
      amountReceivedNode = new FocusNode();

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    notificationToken = isEmpty(widget.customer?.notificationToken)
        ? await FirebaseMessaging.instance.getToken()
        : widget.customer?.notificationToken;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Localization.of(context, 'amounts'),
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            Localization.of(context, 'enter_amount_received_paid'),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 9),
          _buildAmountPaid(),
          _buildAmountReceived(),
          _buildSubmitBtn()
        ],
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return Padding(
      padding: EdgeInsets.all(32.0),
      child: RaisedButtonV2(
        isLoading: _loading,
        disabled: _loading ||
            received ||
            (amountPaid?.isEmpty ?? true) ||
            (amountReceived?.isEmpty ?? true) ||
            ((num.tryParse(amountPaid) == 0) ||
                (num.tryParse(amountReceived) == 0)),
        label: capitalize(Localization.of(context, 'submit')),
        onPressed: _onSubmit,
      ),
    );
  }

  void _onSubmit() async {
    showConfirmationBottomSheet(
      context: context,
      flare: 'assets/flare/pending.flr',
      title: replaceVariable(
        replaceVariable(
          Localization.of(
            context,
            'are_you_sure_these_are_correct',
          ),
          'valueone',
          "${widget.order.action.toLowerCase() == 'buy' ? replaceVariable(
              replaceVariable(
                Localization.of(
                  context,
                  'usdt_sent_without',
                ),
                'value',
                amountPaid,
              ),
              'mainCurrency',
              widget.controller.mainCurrency,
            ) : replaceVariable(
              Localization.of(
                context,
                'cash_paid_without',
              ),
              'value',
              amountPaid,
            )}",
        ),
        "valuetwo",
        "${widget.order.action.toLowerCase() == 'buy' ? replaceVariable(
            Localization.of(
              context,
              'cash_received_without',
            ),
            'value',
            amountReceived,
          ) : replaceVariable(
            replaceVariable(
              Localization.of(
                context,
                'usdt_received_without',
              ),
              'mainCurrency',
              widget.controller.mainCurrency,
            ),
            'value',
            amountReceived,
          )}",
      ),
      // 'Are you sure you these are the correct values? \n\n ${widget.order.action.toLowerCase() == 'buy' ? 'USDT sent $amountPaid\n' : 'Cash paid \$ $amountPaid\n'} ${widget.order.action.toLowerCase() == 'buy' ? 'Cash received \$ $amountReceived' : 'USDT received $amountReceived'}',
      confirmMessage: Localization.of(context, 'yes'),
      cancelMessage: Localization.of(context, 'no'),
      confirmAction: () async {
        Navigator.of(context).pop();
        setState(() {
          widget.isBottomSheetLoading(true);
          _loading = true;
        });
        try {
          // final gsheets = GSheets(_credentials);
          //
          // final ss = await gsheets.spreadsheet(
          //     (widget.order.amount > widget.controller.smallAmountsLimit)
          //         ? widget.controller.largeAmountsSpreadSheetID
          //         : widget.controller.smallAmountsSpreadSheetID);
          // final sheet =
          //     ss.worksheetByTitle(widget.controller.worksheetTitle ?? 'Sheet1');

          Order newOrder = widget.order;
          newOrder.moneyIn = int.tryParse(amountReceived);
          newOrder.moneyOut = int.tryParse(amountPaid);

          await Future.wait([
            FirebaseFirestore.instance
                .collection('drivers')
                .doc(widget.order.driver)
                .update({
              if (widget.order.action.toLowerCase() == 'buy')
                'cash_in': widget.controller.driverCashIn +
                    int.tryParse(amountReceived),
              if (widget.order.action.toLowerCase() == 'buy')
                'usdt_out': widget.controller.driverUsdtOut +
                    int.tryParse(amountPaid) -
                    1,
              if (widget.order.action.toLowerCase() == 'sell')
                'usdt_in': widget.controller.driverUsdtIn +
                    int.tryParse(amountReceived) -
                    1,
              if (widget.order.action.toLowerCase() == 'sell')
                'cash_out':
                    widget.controller.driverCashOut + int.tryParse(amountPaid),
            }),
            FirebaseFirestore.instance
                .collection('history')
                .doc(widget.order.driver)
                .collection(widget.selectedTime ??
                    "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}")
                .doc(widget.order.sentTime ?? widget.order.orderTime)
                .set(
                  newOrder.toJson(
                    received: true,
                  ),
                ),
            //TODO add check for when amount is empty
            if (isNotEmpty(widget.customer?.phoneNumber))
              FirebaseFirestore.instance
                  .collection('customers')
                  .doc(widget.customer?.phoneNumber)
                  .update({
                'coins': (widget.customer?.coins ?? 0) +
                    (int.tryParse(amountPaid) / 100),
                'totalMoneyIn': (widget.customer?.totalMoneyIn ?? 0) +
                    int.tryParse(amountPaid),
                'totalMoneyOut': (widget.customer?.totalMoneyOut ?? 0) +
                    int.tryParse(amountReceived),
                'notification_token': notificationToken,
              }),
            if (isNotEmpty(widget.customer?.phoneNumber))
              FirebaseFirestore.instance
                  .collection('customers')
                  .doc(widget.customer?.phoneNumber)
                  .collection('MyOrders')
                  .doc(widget.order.customerOrderDateTime)
                  .update({
                'coins': (int.tryParse(amountPaid) / 100),
                'driver': widget.order.driver,
                'accepted': true,
                'received': true,
                'money_in': int.tryParse(amountPaid),
                'money_out': int.tryParse(amountReceived),
              }),
            // sheet.values.insertValueByKeys(
            //   widget.order.action.toLowerCase() == 'buy'
            //       ? (int.tryParse(amountPaid) - 1).toString()
            //       : amountPaid,
            //   columnKey: 'Paid Amount',
            //   rowKey: '# ${widget.order.referenceID}',
            //   eager: false,
            // ),
            // sheet.values.insertValueByKeys(
            //   widget.order.action.toLowerCase() == 'buy'
            //       ? amountReceived
            //       : (int.tryParse(amountReceived) - 1).toString(),
            //   columnKey: 'Received Amount',
            //   rowKey: '# ${widget.order.referenceID}',
            //   eager: false,
            // ),
          ]);

          widget.received(true);
          showSuccessBottomsheet();

          setState(() {
            _loading = false;
            received = true;
            widget.isBottomSheetLoading(false);
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
            ),
          );
          setState(() {
            widget.received(false);
            _loading = false;
            received = false;
            widget.isBottomSheetLoading(false);
          });
        }
      },
    );
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
                  Localization.of(context, 'order_updated_successfully'),
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

  Widget _buildAmountReceived() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: TextFormField(
          focusNode: amountReceivedNode,
          maxLength: 10,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r"[0-9]"),
            ),
          ],
          enabled: !_loading,
          onChanged: (amount) {
            setState(() {
              amountReceived = amount;
            });
          },
          decoration: InputDecoration(
            labelText: widget.order.action.toLowerCase() == 'buy'
                ? Localization.of(context, 'cash_received').replaceAll(":", "")
                : replaceVariable(
                    Localization.of(
                      context,
                      'usdt_received',
                    ),
                    'mainCurrency',
                    widget.controller.mainCurrency,
                  ).replaceAll(":", ""),
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
      ),
    );
  }

  Widget _buildAmountPaid() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: TextFormField(
          focusNode: amountPaidNode,
          maxLength: 10,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r"[0-9]"),
            ),
          ],
          enabled: !_loading,
          onChanged: (amount) {
            setState(() {
              amountPaid = amount;
            });
          },
          validator: (String value) {
            if (value?.trim()?.isEmpty ?? true) {
              return Localization.of(context, 'amount_paid_cannot_be_empty');
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: widget.order.action.toLowerCase() == 'buy'
                ? replaceVariable(
                    Localization.of(
                      context,
                      'usdt_sent',
                    ),
                    'mainCurrency',
                    widget.controller.mainCurrency,
                  ).replaceAll(":", "")
                : Localization.of(context, 'cash_paid').replaceAll(":", ""),
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
      ),
    );
  }
}
