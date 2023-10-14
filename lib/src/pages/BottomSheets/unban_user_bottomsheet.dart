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
import 'package:vibration/vibration.dart';

class UnbanUserBottomsheet extends StatefulWidget {
  final HomeScreenController? controller;
  final ValueChanged<bool>? isBottomSheetLoading;

  UnbanUserBottomsheet({
    this.controller,
    this.isBottomSheetLoading,
  });

  @override
  State<StatefulWidget> createState() => _UnbanUserBottomsheetState();
}

class _UnbanUserBottomsheetState extends State<UnbanUserBottomsheet> {
  bool _loading = false;
  String? userPhoneNumber;

  FocusNode userPhoneNumberNode = new FocusNode();

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
            Localization.of(context, 'unban_user'),
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            Localization.of(context, 'enter_the_user_phone_number'),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 9),
          _buildUserPhoneNumber(),
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
        disabled: _loading || (userPhoneNumber?.isEmpty ?? true),
        label: capitalize(Localization.of(context, 'submit')),
        onPressed: _onSubmit,
      ),
    );
  }

  void _onSubmit() async {
    if ((userPhoneNumber?.substring(0, 1) != "+"))
      showErrorBottomsheet(
          Localization.of(context, 'phone_number_should_include_dial_code'));
    else {
      setState(() {
        if (widget.isBottomSheetLoading != null)
          widget.isBottomSheetLoading!(true);
        _loading = true;
      });

      try {
        userPhoneNumber = formatPhoneNumber(userPhoneNumber ?? "");
        List? newBansList = widget.controller?.bansList;
        newBansList?.removeWhere((element) => element == userPhoneNumber);

        await FirebaseFirestore.instance
            .collection('app info')
            .doc('app')
            .update({
          'banned': newBansList,
        });

        showSuccessBottomsheet();
        setState(() {
          _loading = false;
          if (widget.isBottomSheetLoading != null)
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
              ) ??
              "",
        );
        setState(() {
          _loading = false;
          if (widget.isBottomSheetLoading != null)
            widget.isBottomSheetLoading!(true);
        });
      }
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
                  replaceVariable(
                        Localization.of(
                          context,
                          'user_with_phone_number_unbanned_successfully',
                        ),
                        'value',
                        "${userPhoneNumber.toString()}",
                      ) ??
                      "",
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

  Widget _buildUserPhoneNumber() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: TextFormField(
        focusNode: userPhoneNumberNode,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r"[+0-9]"),
          ),
        ],
        enabled: !_loading,
        onChanged: (phoneNumber) {
          setState(() {
            userPhoneNumber = phoneNumber;
          });
        },
        decoration: InputDecoration(
          labelText: Localization.of(context, 'phone_number_with_code'),
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
