import 'package:flutter/material.dart';

class UBAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Key? key;
  final Widget? leading;
  final bool? automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final Brightness? brightness;
  final IconThemeData? iconTheme;
  final TextTheme? textTheme;
  final bool? primary;
  final bool? centerTitle;
  final double? titleSpacing;
  final double? toolbarOpacity;
  final double? bottomOpacity;

  UBAppBar({
    this.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation = 0,
    this.backgroundColor,
    this.brightness,
    this.iconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1,
    this.bottomOpacity = 1,
  });
  @override
  State<StatefulWidget> createState() {
    return _UBAppBarState();
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

class _UBAppBarState extends State<UBAppBar> {
  @override
  Widget build(BuildContext context) {
    widget.createElement().state.setState(() {});

    Color? color;
    return AppBar(
      key: widget.key,
      leading: widget.leading,
      automaticallyImplyLeading: widget.automaticallyImplyLeading!,
      title: widget.title,
      actions: widget.actions,
      flexibleSpace: widget.flexibleSpace,
      bottom: widget.bottom,
      elevation: widget.elevation,
      backgroundColor: widget.backgroundColor ?? color ?? Colors.transparent,
      brightness: widget.brightness,
      iconTheme: widget.iconTheme,
      textTheme: widget.textTheme,
      primary: widget.primary ?? false,
      centerTitle: widget.centerTitle,
      titleSpacing: widget.titleSpacing,
      toolbarOpacity: widget.toolbarOpacity ?? 1.0,
      bottomOpacity: widget.bottomOpacity ?? 1.0,
    );
  }
}
