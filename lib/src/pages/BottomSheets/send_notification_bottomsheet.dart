import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/utils/util.dart';
import 'package:vibration/vibration.dart';

class SendNotificationBottomsheet extends StatefulWidget {
  final HomeScreenController? controller;
  final ValueChanged<bool>? changed;
  final ValueChanged<bool>? isBottomSheetLoading;

  SendNotificationBottomsheet({
    this.controller,
    this.changed,
    this.isBottomSheetLoading,
  });

  @override
  State<StatefulWidget> createState() => _SendNotificationBottomsheetState();
}

class _SendNotificationBottomsheetState
    extends State<SendNotificationBottomsheet> {
  bool _loading = false;
  String? notification;

  FocusNode notificationNode = new FocusNode();

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
            Localization.of(context, 'notification'),
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            Localization.of(context, 'enter_notification_description'),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 9),
          _buildNotificationTextField(),
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
        disabled: _loading || (notification?.isEmpty ?? true),
        label: capitalize(Localization.of(context, 'submit')),
        onPressed: _onSubmit,
      ),
    );
  }

  void _onSubmit() async {
    setState(() {
      if(widget.isBottomSheetLoading != null)
        widget.isBottomSheetLoading!(true);
      _loading = true;
    });

    try {
      CollectionReference notifications =
          FirebaseFirestore.instance.collection('Notifications');

      await Future.wait([
        notifications
            .doc(
                '${getNumberWithPrefixZero(DateTime.now().year)}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}')
            .set({'description': capitalize(notification ?? "")}),
      ]);

      showSuccessBottomsheet();
      setState(() {
        _loading = false;
        if(widget.changed != null)
        widget.changed!(true);
        if(widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(true);
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
        ) ?? "",
      );
      setState(() {
        _loading = false;
        if(widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(true);
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
                  Localization.of(context, 'notification_sent_successfully'),
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
              onPressed: () async {
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

  Widget _buildNotificationTextField() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: notificationNode,
        keyboardType: TextInputType.text,
        enabled: !_loading,
        onChanged: (city) {
          setState(() {
            notification = city;
          });
        },
        decoration: InputDecoration(
          labelText: Localization.of(context, 'notification_description'),
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
