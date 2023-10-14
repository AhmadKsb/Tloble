import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';

import 'flare_actor.dart';
import 'operation_status.dart';

class ActionBottomSheet extends StatelessWidget {
  final OperationStatus? status;
  final String? message;
  final String? buttonMessage;
  final VoidCallback? onPressed;
  final bool? dismissOnTouchOutside;
  final bool? showCancelButton;
  final bool? showDoneButton;
  final Widget? extraButton;
  final String? title;

  ///Use when you want to override the default widgets under the divider
  final Widget? bottomWidget;

  const ActionBottomSheet({
    Key? key,
    this.status,
    this.message,
    this.buttonMessage,
    this.onPressed,
    this.dismissOnTouchOutside,
    this.showCancelButton,
    this.showDoneButton = true,
    this.extraButton,
    this.bottomWidget,
    this.title,
  }) : super(key: key);

  Widget _getAnimatedStatusIcon() {
    switch (status) {
      case OperationStatus.success:
        return Container(
          width: 150,
          height: 150,
          child: FlareActor(
            'assets/flare/success.flr',
            animation: 'animate',
            fit: BoxFit.fitWidth,
          ),
        );

      case OperationStatus.warning:
        return Container(
          width: 150,
          height: 150,
          child: FlareActor(
            'assets/flare/pending.flr',
            animation: 'animate',
            fit: BoxFit.fitWidth,
          ),
        );
      default:
        return Container(
          key: Key('error_animation'),
          margin: const EdgeInsets.only(top: 30, bottom: 18),
          width: 100,
          height: 100,
          child: FlareError(),
        );
    }
  }

  Widget _buildButton(BuildContext context) {
    if (!(showDoneButton ?? true)) return Container();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: RaisedButtonV2(
            label: buttonMessage ?? 'DONE',
            onPressed: onPressed ?? () => null,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 21, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 60.0,
                height: 5.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (title != null) SizedBox(height: 16),
        if (title != null)
          Text(
            title ?? "",
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        status == OperationStatus.success
            ? SizedBox(height: 16)
            : SizedBox.shrink(),
        _getAnimatedStatusIcon(),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            message ?? "",
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  fontSize: 16,
                  color: status == OperationStatus.error
                      ? Color.fromARGB(255, 210, 34, 49)
                      : null,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        status == OperationStatus.success
            ? SizedBox(height: 24)
            : SizedBox(height: 50),
      ],
    );
  }

  Widget _buildSuccessBottomSheet(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return dismissOnTouchOutside ?? false;
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              status == OperationStatus.success
                  ? _buildSuccessBottomSheet(context)
                  : SingleChildScrollView(
                      child: _buildBody(context),
                    ),
              if (bottomWidget != null) bottomWidget!,
              if (bottomWidget == null)
                ((showCancelButton ?? false) || extraButton != null)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if (extraButton != null)
                            Expanded(child: extraButton ?? SizedBox()),
                          _buildButton(context),
                          if (showCancelButton ?? false)
                            FlatButton(
                              child: Text(
                                'CANCEL',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 210, 34, 49)),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                        ],
                      )
                    : _buildButton(context),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
