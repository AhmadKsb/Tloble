import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';

import 'buttons_button_sheet.dart';

class ConfirmationBottomSheet extends StatefulWidget {
  final String title;
  final String message;
  final String confirmMessage;
  final bool confirmIsLoading;
  final String cancelMessage;
  final Function confirmAction;
  final Function cancelAction;
  final String icon;
  final String flare;

  const ConfirmationBottomSheet({
    Key key,
    this.title,
    this.message,
    this.confirmMessage,
    this.confirmIsLoading = false,
    this.cancelMessage,
    this.confirmAction,
    this.cancelAction,
    this.icon,
    this.flare,
  }) : super(key: key);

  @override
  GRConfirmationBottomSheetState createState() =>
      GRConfirmationBottomSheetState();
}

class GRConfirmationBottomSheetState extends State<ConfirmationBottomSheet>
    with FlareController {
  PageState actionState;
  FlutterColorFill _fill;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 28),
                if (widget.icon != null) Image.asset(widget.icon),
                if (widget.flare != null)
                  Container(
                    height: 100,
                    width: 100,
                    child: FlareActor(
                      widget.flare,
                      animation: 'animate',
                      fit: BoxFit.fitWidth,
                      controller: this,
                    ),
                  ),
                SizedBox(height: 19),
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.title ?? '',
                      style: TextStyle()
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (widget.title != null && widget.message != null)
                  SizedBox(height: 15),
                if (widget.message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.message ?? '',
                      style: TextStyle(
                        fontFamily: "Trebuchet MS",
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 24),
                ButtonsButtonSheet(
                  cancelMessage: widget.cancelMessage,
                  confirmMessage: widget.confirmMessage,
                  confirmIsLoading: actionState != null
                      ? actionState == PageState.loading
                      : widget.confirmIsLoading,
                  confirmAction: widget.confirmAction,
                  cancelAction: widget.cancelAction,
                ),
                SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    FlutterActorShape shape = artboard.getNode("circle_bg");
    _fill = shape?.fill as FlutterColorFill;
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    Color nextColor = Colors.white;
    if (_fill != null) {
      _fill.uiColor = nextColor;
    }
    return false;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}
