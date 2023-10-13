import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';

import '../string_util.dart';

class ButtonsButtonSheet extends StatelessWidget {
  final String confirmMessage;
  final bool confirmIsLoading;
  final String cancelMessage;
  final Function confirmAction;
  final Function cancelAction;
  final bool isCancelDisabled;
  final bool isSubmitDisabled;

  const ButtonsButtonSheet({
    Key key,
    this.confirmMessage,
    this.confirmIsLoading = false,
    this.cancelMessage,
    this.confirmAction,
    this.cancelAction,
    this.isCancelDisabled = false,
    this.isSubmitDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaisedButtonV2(
          isLoading: confirmIsLoading,
          label: confirmMessage,
          disabled: isSubmitDisabled,
          onPressed: confirmAction ??
              () {
                Navigator.of(context).pop(true);
              },
        ),
        SizedBox(height: 12),
        if(isNotEmpty(cancelMessage))
        RaisedButtonV2(
          label: cancelMessage,
          onPressed: cancelAction ??
              () {
                Navigator.of(context).pop(false);
              },
          disabled: isCancelDisabled,
          // labelStyle: TextStyle(
          //   fontSize: 16,
          //   fontWeight: FontWeight.w700,
          //   color: isCancelDisabled
          //       ? Color(GRAppColors.siete.hex)
          //       : Color(GRAppColors.uno.hex),
          // ),
        ),
      ],
    );
  }
}
