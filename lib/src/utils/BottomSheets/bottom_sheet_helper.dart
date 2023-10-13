import 'package:flutter/material.dart';
import 'package:wkbeast/utils/selection_bottomsheet.dart';

import 'bottom_sheet_status.dart';
import 'confirmation_bottom_sheet.dart';
import 'operation_status.dart';

Future<T> showBottomsheet<T>({
  BuildContext context,
  Widget body,
  Widget bottomWidget,
  Widget upperWidget,
  bool dismissOnTouchOutside = true,
  bool isScrollControlled = false,
  bool includeUpperPart = false,
  bool includeCloseButton = false,
  double height,
}) {
  assert(context != null, "context cannot be null");
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled ?? false,
    isDismissible: dismissOnTouchOutside ?? true,
    backgroundColor: Colors.white,
    builder: (context) => Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: GestureDetector(
        onVerticalDragDown: dismissOnTouchOutside ? null : (_) {},
        onVerticalDragCancel: dismissOnTouchOutside ? null : () {},
        onVerticalDragEnd: dismissOnTouchOutside ? null : (_) {},
        onVerticalDragStart: dismissOnTouchOutside ? null : (_) {},
        onVerticalDragUpdate: dismissOnTouchOutside ? null : (_) {},
        onPanDown: dismissOnTouchOutside ? null : (_) {},
        onPanStart: dismissOnTouchOutside ? null : (_) {},
        onPanEnd: dismissOnTouchOutside ? null : (_) {},
        onPanUpdate: dismissOnTouchOutside ? null : (_) {},
        onPanCancel: dismissOnTouchOutside ? null : () {},
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: WillPopScope(
            onWillPop: () async {
              return dismissOnTouchOutside;
            },
            child: Container(
              height: height ?? MediaQuery.of(context).size.height * 0.5,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (includeUpperPart) SizedBox(height: 20),
                  if (includeUpperPart)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (includeCloseButton) Expanded(child: Container()),
                        // Container(
                        //   width: 60.0,
                        //   height: 5.0,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.all(
                        //       Radius.circular(3.0),
                        //     ),
                        //     color: Colors.white,
                        //   ),
                        // ),
                        if (includeCloseButton)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (includeUpperPart) SizedBox(height: 20),
                  upperWidget != null ? upperWidget : SizedBox.shrink(),
                  if (body != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            body ?? Container(),
                          ],
                        ),
                      ),
                    ),
                  bottomWidget != null ? bottomWidget : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
  );
}

void showBottomSheetList<T>({
  Key key,
  @required BuildContext context,
  List<T> items,
  Future<List<T>> itemsFuture,
  @required Widget Function(T) itemBuilder,
  @required ValueChanged<T> onItemSelected,
  @required String title,
  double itemHeight,
  bool hasSearch = false,
  bool Function(T, String) searchMatcher,
  bool shouldPop,
  Map<String, SegregationFunction> segregationMap,
  String searchHint,
  String noDataMessage,
  TextStyle defaultSegregationTitleStyle,
  Map<String, TextStyle> segregationTitlesStylesMap,
  EdgeInsets itemsListPadding,
  EdgeInsets segregationTitlePadding,
  EdgeInsets itemsDividerPadding,
}) {
  showModalBottomSheet(
    isDismissible: true,
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.white,
    builder: (context) => SelectionListBottomSheet(
      title: title,
      items: items,
      itemsFuture: itemsFuture,
      itemBuilder: itemBuilder,
      onItemSelected: onItemSelected,
      itemHeight: itemHeight,
      hasSearch: hasSearch,
      searchMatcher: searchMatcher,
      shouldPop: shouldPop,
      segregationMap: segregationMap,
      searchHint: searchHint,
      noDataMessage: noDataMessage,
      defaultSegregationTitleStyle: defaultSegregationTitleStyle,
      segregationTitlesStylesMap: segregationTitlesStylesMap,
      itemsListPadding: itemsListPadding,
      segregationTitlePadding: segregationTitlePadding,
      itemsDividerPadding: itemsDividerPadding,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
  );
}

Future<void> showBottomSheetStatus({
  Key key,
  BuildContext context,
  OperationStatus status,
  String message,
  String buttonMessage,
  VoidCallback onPressed,
  bool popOnPress = false,
  bool showCancelButton = false,
  bool dismissOnTouchOutside = true,
  bool showDoneButton = true,
  Widget extraButton,
  String title,

  ///Use when you want to override the default widgets under the divider
  Widget bottomWidget,
}) {
  assert(context != null, "context cannot be null");
  assert(status != null, "status cannot be null");
  assert(message != null, "message cannot be null");

  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    backgroundColor: Colors.white,
    isDismissible: dismissOnTouchOutside ?? true,
    isScrollControlled: true,
    context: context,
    builder: (ctx) => GestureDetector(
      onVerticalDragDown: dismissOnTouchOutside ? null : (_) {},
      onVerticalDragCancel: dismissOnTouchOutside ? null : () {},
      onVerticalDragEnd: dismissOnTouchOutside ? null : (_) {},
      onVerticalDragStart: dismissOnTouchOutside ? null : (_) {},
      onVerticalDragUpdate: dismissOnTouchOutside ? null : (_) {},
      onPanDown: dismissOnTouchOutside ? null : (_) {},
      onPanStart: dismissOnTouchOutside ? null : (_) {},
      onPanEnd: dismissOnTouchOutside ? null : (_) {},
      onPanUpdate: dismissOnTouchOutside ? null : (_) {},
      onPanCancel: dismissOnTouchOutside ? null : () {},
      child: BottomSheetStatus(
        key: key,
        status: status,
        message: message,
        buttonMessage: buttonMessage,
        dismissOnTouchOutside: dismissOnTouchOutside ?? true,
        showDoneButton: showDoneButton ?? true,
        showCancelButton: showCancelButton,
        extraButton: extraButton,
        title: title,
        bottomWidget: bottomWidget,
        onPressed: () {
          if (!dismissOnTouchOutside || popOnPress) Navigator.of(context).pop();
          if (onPressed != null) onPressed();
        },
      ),
    ),
  );
}

Future<void> showActionBottomSheet({
  Key key,
  BuildContext context,
  OperationStatus status,
  String message,
  String buttonMessage,
  VoidCallback onPressed,
  bool popOnPress = false,
  bool showCancelButton = false,
  bool dismissOnTouchOutside = true,
  bool showDoneButton = true,
  Widget extraButton,
  String title,

  ///Use when you want to override the default widgets under the divider
  Widget bottomWidget,
}) {
  assert(context != null, "context cannot be null");
  assert(status != null, "status cannot be null");
  assert(message != null, "message cannot be null");

  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    backgroundColor: Colors.white,
    isDismissible: dismissOnTouchOutside ?? true,
    isScrollControlled: true,
    context: context,
    builder: (ctx) => GestureDetector(
      onVerticalDragDown: dismissOnTouchOutside ? null : (_) {},
      onVerticalDragCancel: dismissOnTouchOutside ? null : () {},
      onVerticalDragEnd: dismissOnTouchOutside ? null : (_) {},
      onVerticalDragStart: dismissOnTouchOutside ? null : (_) {},
      onVerticalDragUpdate: dismissOnTouchOutside ? null : (_) {},
      onPanDown: dismissOnTouchOutside ? null : (_) {},
      onPanStart: dismissOnTouchOutside ? null : (_) {},
      onPanEnd: dismissOnTouchOutside ? null : (_) {},
      onPanUpdate: dismissOnTouchOutside ? null : (_) {},
      onPanCancel: dismissOnTouchOutside ? null : () {},
      child: BottomSheetStatus(
        key: key,
        status: status,
        message: message,
        buttonMessage: buttonMessage,
        dismissOnTouchOutside: dismissOnTouchOutside ?? true,
        showDoneButton: showDoneButton ?? true,
        showCancelButton: showCancelButton,
        extraButton: extraButton,
        title: title,
        bottomWidget: bottomWidget,
        onPressed: () {
          if (onPressed != null) onPressed();
        },
      ),
    ),
  );
}

void showErrorBottomsheet(
  BuildContext context,
  String error, {
  bool dismissOnTouchOutside = true,
  bool showDoneButton = true,
  bool doublePop = false,
}) async {
  await showBottomSheetStatus(
    context: context,
    status: OperationStatus.error,
    message: error,
    popOnPress: true,
    dismissOnTouchOutside: dismissOnTouchOutside,
    showDoneButton: showDoneButton,
    onPressed: doublePop ? () => Navigator.of(context).pop() : null,
  );
}

Future<bool> showConfirmationBottomSheet({
  @required BuildContext context,
  String title,
  String message,
  String confirmMessage,
  String cancelMessage,
  Function confirmAction,
  Function cancelAction,
  bool dismissOnTouchOutside = true,
  Stream isLoadingStream,
  String icon,
  String flare,
}) {
  assert(context != null, "context, cannot be null");
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: dismissOnTouchOutside,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) => isLoadingStream == null
        ? ConfirmationBottomSheet(
            title: title,
            message: message,
            confirmMessage: confirmMessage,
            cancelMessage: cancelMessage,
            confirmAction: confirmAction,
            cancelAction: cancelAction,
            icon: icon,
            flare: flare,
          )
        : StreamBuilder<bool>(
            stream: isLoadingStream,
            builder: (context, snapshot) {
              return ConfirmationBottomSheet(
                title: title,
                message: message,
                confirmMessage: confirmMessage,
                confirmIsLoading: snapshot.data ?? false,
                cancelMessage: cancelMessage,
                confirmAction: confirmAction,
                cancelAction: cancelAction,
                icon: icon,
              );
            }),
  );
}
