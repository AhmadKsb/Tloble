import 'package:flutter/material.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/utils/UBScaffold/page_state.dart';

import 'error_switcher.dart';
import 'loader.dart';

class UBPageStateWidget extends StatelessWidget {
  final PageState pageState;
  final Widget loadingWidget;
  final WidgetBuilder builder;
  final WidgetBuilder noDataBuilder;
  final String textUnderLoader;
  final Function onRetry;
  final dynamic error;
  final String noDataMessage;

  UBPageStateWidget({
    this.pageState,
    this.loadingWidget,
    this.builder,
    this.noDataBuilder,
    this.textUnderLoader,
    this.onRetry,
    this.error,
    this.noDataMessage,
  });

  @override
  Widget build(BuildContext context) {
    Widget pageBody = SizedBox.shrink();
    switch (pageState) {
      case PageState.loading:
        pageBody = loadingWidget ?? Loader();
        break;
      case PageState.loaded:
        if (builder != null) pageBody = Builder(builder: builder);
        break;
      case PageState.error:
        pageBody = ErrorSwitcher(
          message: Localization.of(context, 'network_error'),
          onRetry: onRetry,
          error: error,
        );
        break;
      case PageState.noData:
        if (noDataBuilder != null)
          pageBody = Builder(builder: noDataBuilder);
        else if (noDataMessage != null) pageBody = NoData(noDataMessage);
        break;
    }

    return pageBody;
  }
}

class NoData extends StatelessWidget {
  NoData(
    this.message, {
    this.child,
    Key key,
    this.size = 18,
  });

  final Widget child;
  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: child ??
          Text(
            message,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
    );
  }
}
