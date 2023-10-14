import 'package:flutter/material.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';

class Loader extends StatelessWidget {
  final double radius;
  final Color activeColor;
  final Color inactiveColor;

  const Loader({
    Key? key,
    this.radius = 24.0,
    this.activeColor = const Color(0xFFDADADA),
    this.inactiveColor = const Color(0xFFDADADA),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NutsActivityIndicator(
      radius: radius,
      activeColor: activeColor,
      inactiveColor: inactiveColor.withOpacity(0.5),
      tickCount: 12,
      startRatio: 0.4,
      animationDuration: Duration(seconds: 2),
    );
  }
}
