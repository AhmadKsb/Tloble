import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_appbar.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_page_state_widget.dart';

class UBScaffold extends StatefulWidget {
  /// Extras:
  ///  - Handles different [PageState] widgets using `state`
  ///  - Handles search bar
  UBScaffold({
    Key? key,
    this.scaffoldKey,
    this.appBar,
    this.builder,
    this.noDataBuilder,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.primary = true,
    this.state,
    this.disablePointer = false,
    this.forceAppBar = false,
    this.textUnderLoader,
    this.extendBodyBehindAppBar = false,
    this.error,
    this.disablePopOnBackIfLoading = false,
    this.loadingWidget,
  }) : super(key: key);

  final Key? scaffoldKey;
  final PreferredSizeWidget? appBar;
  final WidgetBuilder? builder;
  final WidgetBuilder? noDataBuilder;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool resizeToAvoidBottomInset;
  final bool primary;
  final AppState? state;
  final bool disablePointer;
  final bool forceAppBar;
  final String? textUnderLoader;
  final bool extendBodyBehindAppBar;
  final dynamic error;
  final bool disablePopOnBackIfLoading;
  final Widget? loadingWidget;

  static UBScaffoldState? of(BuildContext context, {bool nullOk = false}) {
    final UBScaffoldState? result =
        context.findAncestorStateOfType<UBScaffoldState>();
    return result;
  }

  @override
  UBScaffoldState createState() => UBScaffoldState();
}

class UBScaffoldState extends State<UBScaffold> {
  bool _isSearching = false;

  bool get isSearching {
    return _isSearching;
  }

  List<Widget>? _requestedActions;
  Widget? _requestedAppbar;
  AppState? _requestedState;

  bool _showBlur = false;

  set isSearching(bool value) {
    _isSearching = value;
    if (!value) {
      // if (_requestedState?.onSearchChanged != null) {
      //   _requestedState?.onSearchChanged(null);
      // } else if (widget.state?.onSearchChanged != null) {
      //   widget.state?.onSearchChanged(null);
      // }
    }
  }

  void requestAppBarRefresh(
    PreferredSizeWidget appbar, {
    AppState? appState,
    bool forceAppbar = false,
  }) {
    _requestedState = appState;
    bool hadAppbar = _requestedAppbar != null;
    bool requestingAppbar = appbar != null;
    if (hadAppbar != requestingAppbar) refreshState();
    if (forceAppbar)
      _requestedAppbar = appbar;
    else
      _requestedAppbar = null;

    _requestedActions = null;
  }

  void refreshState() {
    var state = UBScaffold.of(context);
    if (state != null) {
      state.refreshState();
    } else {
      Future.delayed(Duration(milliseconds: 16)).then((_) {
        if (mounted)
          setState(() {
            _requestedAppbar = _requestedAppbar;
          });
        else
          refreshState();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _clearPressed() {
    _resetSearch();
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    UBScaffoldState? state = UBScaffold.of(context);

    PreferredSizeWidget? appbar;
    PreferredSizeWidget? ubAppBar =
        widget.appBar is UBAppBar ? widget.appBar : null;

    if (_requestedAppbar != null) {
      appbar = _requestedAppbar as PreferredSizeWidget?;
    } else if (_requestedActions != null &&
        (_requestedActions?.isNotEmpty ?? false) &&
        ubAppBar != null) {
      appbar = UBAppBar(
        // backgroundColor: ubAppBar?.backgroundColor,
        // bottom: ubAppBar.bottom,
        // title: ubAppBar.title,
        actions: _requestedActions,
        // leading: ubAppBar.leading,
        // centerTitle: ubAppBar.centerTitle,
        // elevation: ubAppBar.elevation,
      );
    }
    // else if (widget.state.pageState == PageState.loaded &&
    //     widget.state.hasSearch &&
    //     state == null &&
    //     ubAppBar != null) {
    //   appbar = UBAppBar(
    //     backgroundColor: ubAppBar.backgroundColor,
    //     bottom: ubAppBar.bottom,
    //     title: ubAppBar.title,
    //     centerTitle: ubAppBar.centerTitle,
    //     elevation: ubAppBar.elevation,
    //   );
    // }
    else {
      appbar = widget.appBar;
    }
    if (state != null && appbar != null) {
      state.requestAppBarRefresh(appbar,
          appState: widget.state ?? AppState(),
          forceAppbar: widget.forceAppBar);
      return _EmptyAppBar();
    } else {
      return appbar;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Theme(
      data: Theme.of(context),
      child: Scaffold(
        key: widget.scaffoldKey,
        appBar: _buildAppBar(context),
        body: AbsorbPointer(
          absorbing: widget.disablePointer,
          child: Stack(
            children: [
              SizedBox.expand(
                  child: UBPageStateWidget(
                pageState: widget.state?.pageState,
                loadingWidget: widget.loadingWidget,
                builder: widget.builder,
                noDataBuilder: widget.noDataBuilder,
                textUnderLoader: widget.textUnderLoader,
                onRetry: widget.state?.onRetry,
                error: widget.error,
                noDataMessage: widget.state?.noDataMessage,
              )),
              _buildBlur(),
            ],
          ),
        ),
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        bottomSheet: widget.bottomSheet,
        backgroundColor: widget.backgroundColor ?? Colors.white,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      ),
    );

    if (isSearching)
      return WillPopScope(
        onWillPop: _willPop,
        child: scaffold,
      );

    return scaffold;
  }

  void toggleBlur() {
    setState(() {
      _showBlur = !_showBlur;
    });
  }

  Widget _buildBlur() {
    return Visibility(
      visible: _showBlur,
      child: GestureDetector(
        // onTap: toggleBlur,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  void _resetSearch() {
    if (_requestedState?.onSearchChanged != null) {
      _requestedState?.onSearchChanged!('');
    } else if (widget.state?.onSearchChanged != null) {
      widget.state?.onSearchChanged!('');
    }
  }

  Future<bool> _willPop() async {
    if (widget.disablePopOnBackIfLoading &&
        widget.state?.pageState == PageState.loading) return false;

    if (isSearching) {
      _stopSearching();
      return false;
    }
    return true;
  }

  void _stopSearching() {
    setState(() {
      isSearching = false;
    });
  }
}

// holds page state properties
class AppState {
  final PageState pageState;

  /// to show no data default widget, if null doesn't appear
  final String noDataMessage;

  /// to show search button, it's added at the end of the actions
  final bool hasSearch;
  final ValueChanged<String>? onSearchChanged;

  /// when an error is showing, a retry button will be display
  final VoidCallback? onRetry;

  /// when the keyboard done button for the search textfield is pressed
  final VoidCallback? onSearchSubmit;

  // final String query;

  const AppState({
    this.pageState = PageState.loaded,
    this.noDataMessage = '',
    this.hasSearch = false,
    this.onSearchChanged,
    this.onSearchSubmit,
    this.onRetry,
  });
}

class _EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0, 0);
}
