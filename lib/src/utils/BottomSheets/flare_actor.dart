import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';

class FlareSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlareActor(
      'assets/flare/lp-status-success.flr',
      animation: 'Animations',
      fit: BoxFit.fitWidth,
      alignment: Alignment.center,
    );
  }
}

class FlareError extends StatefulWidget {
  @override
  _FlareErrorState createState() => _FlareErrorState();
}

class _FlareErrorState extends State<FlareError> with FlareController {
  FlutterColorFill? _fill;

  @override
  void initialize(FlutterActorArtboard artboard) {
    // FlutterActorShape shape = artboard.getNode("circle_bg");
    // _fill = shape.fill as FlutterColorFill;
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    // advance is called whenever the flare artboard is about to update (before it draws).
    Color nextColor = Colors.white;
    if (_fill != null) {
      _fill?.uiColor = nextColor;
    }
    // Return false as we don't need to be called again. You'd return true if you wanted to manually animate some property.
    return false;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  Widget build(BuildContext context) {
    return FlareActor(
      'assets/flare/error.flr',
      animation: 'animate',
      fit: BoxFit.fitWidth,
      controller: this,
    );
  }
}
