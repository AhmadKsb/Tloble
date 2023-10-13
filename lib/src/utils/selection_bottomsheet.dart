import 'package:flutter/material.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/utils/string_util.dart';

import 'UBScaffold/error_switcher.dart';
import 'UBScaffold/ub_page_state_widget.dart';

typedef SegregationFunction<T> = bool Function(T value);

class SelectionListBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final ValueChanged<T> onItemSelected;
  final String title;
  final bool hasSearch;
  final bool Function(T, String) searchMatcher;
  final double itemHeight;
  final Future<List<T>> itemsFuture;
  final bool shouldPop;
  final Map<String, SegregationFunction> segregationMap;
  final String searchHint;
  final String noDataMessage;
  final TextStyle defaultSegregationTitleStyle;
  final EdgeInsets itemsListPadding;
  final EdgeInsets segregationTitlePadding;
  final EdgeInsets itemsDividerPadding;
  final Map<String, TextStyle> segregationTitlesStylesMap;

  const SelectionListBottomSheet({
    Key key,
    this.items,
    this.itemsFuture,
    this.itemBuilder,
    this.onItemSelected,
    this.title,
    this.itemHeight,
    this.hasSearch = false,
    this.searchMatcher,
    this.shouldPop = true,
    this.segregationMap,
    this.searchHint,
    this.noDataMessage,
    this.defaultSegregationTitleStyle,
    this.itemsListPadding,
    this.segregationTitlePadding,
    this.itemsDividerPadding,
    this.segregationTitlesStylesMap,
  })  : assert(items != null || itemsFuture != null, "items cannot be null"),
        assert(itemBuilder != null, "itemBuilder cannot be null"),
        assert(onItemSelected != null, "onItemSelected cannot be null"),
        assert(title != null, "title cannot be null"),
        assert(
            hasSearch && searchMatcher != null ||
                !hasSearch && searchMatcher == null,
            "if search enabled, matcher cannot be null"),
        super(key: key);

  @override
  _SelectionListBottomSheetState<T> createState() =>
      _SelectionListBottomSheetState<T>();
}

class _SelectionListBottomSheetState<T>
    extends State<SelectionListBottomSheet<T>> {
  String _searchQuery;
  bool _keyboardOpened = false;

  List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items ?? [];
  }

  TextStyle _getSegregationTitleStyle(String segregationTitle) {
    if (widget.segregationTitlesStylesMap == null) return null;
    return widget.segregationTitlesStylesMap[segregationTitle];
  }

  List<dynamic> get _segregatedItems {
    if (widget.segregationMap == null ||
        widget.segregationMap.isEmpty ||
        _filteredItems.isEmpty) {
      return _filteredItems;
    }
    List<dynamic> data = [];
    widget.segregationMap.forEach((title, segregationFunction) {
      List<T> itemsForKey = _filteredItems
          .where((element) => segregationFunction(element))
          .toList();
      if (itemsForKey != null && itemsForKey.isNotEmpty) {
        data.add(Padding(
          padding: widget.segregationTitlePadding ?? EdgeInsets.zero,
          child: Text(
            title,
            style: _getSegregationTitleStyle(title) ??
                widget.defaultSegregationTitleStyle ??
                TextStyle(fontSize: 12),
          ),
        ));
        data.addAll(itemsForKey);
      }
    });

    List remaining = _filteredItems
        .where((item) =>
            widget.segregationMap.values.firstWhere(
                (segregationFunction) => segregationFunction(item),
                orElse: () => null) ==
            null)
        .toList();
    if (remaining != null && remaining.isNotEmpty) data.addAll(remaining);
    return data;
  }

  List<T> get _filteredItems => (widget.hasSearch && isNotEmpty(_searchQuery))
      ? _items
          .where((item) => widget.searchMatcher(item, _searchQuery))
          .toList()
      : _items;

  Widget _buildToWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 21),
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
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 9.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: BorderSide(
          color: Colors.red,
          width: 0.5,
        ),
      );

  Widget _buildSearchBox() {
    return widget.hasSearch
        ? Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TextField(
              onTap: () => setState(() {
                _keyboardOpened = true;
              }),
              decoration: InputDecoration(
                fillColor: Colors.red,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                hintText: isNotEmpty(widget.searchHint)
                    ? widget.searchHint
                    : Localization.of(context, 'select_an_option'),
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.search),
                ),
                border: _border,
                focusedBorder: _border,
                enabledBorder: _border,
                disabledBorder: _border,
              ),
              onChanged: (searchQuery) => setState(() {
                _searchQuery = searchQuery;
              }),
              onSubmitted: (text) {
                setState(() {
                  _keyboardOpened = false;
                });
              },
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildItemsList() {
    List items = _segregatedItems;
    return Expanded(
      child: ListView.separated(
        padding: widget.itemsListPadding?.copyWith(top: 18) ??
            const EdgeInsets.symmetric(
              horizontal: 17,
            ).copyWith(top: 18),
        itemBuilder: (context, index) => InkWell(
            onTap: items[index] is T
                ? () {
                    widget.onItemSelected(items[index]);
                    if (widget.shouldPop ?? true) Navigator.of(context).pop();
                  }
                : null,
            child: items[index] is Widget
                ? items[index]
                : widget.itemBuilder(items[index])),
        separatorBuilder: (context, index) => (items[index] is Widget ||
                ((index >= 0 || index < items.length - 1) &&
                    items[index + 1] is Widget))
            ? SizedBox.shrink()
            : Padding(
                padding: widget.itemsDividerPadding ?? EdgeInsets.zero,
                child: Divider(height: 1),
              ),
        itemCount: items.length,
      ),
    );
  }

  double get _heightFactorFromHeight {
    if (widget.itemHeight == null) {
      if (_segregatedItems.length == 1)
        return widget.hasSearch ? .3 : .2;
      else if (_segregatedItems.length == 2)
        return widget.hasSearch ? .35 : .25;
      else if (_segregatedItems.length <= 5) return widget.hasSearch ? .5 : .4;
      return widget.hasSearch ? .8 : .7;
    }
    double screenHeight = MediaQuery.of(context).size.height;
    double maxRatio = 0.85;
    double minRatio = 0.1;
    double paddingRatio = 0.08;
    double bottomSheetHeight = widget.itemHeight * widget.items.length;
    bottomSheetHeight = bottomSheetHeight + (widget.hasSearch ? 100.0 : 50.0);
    double ratio = bottomSheetHeight / screenHeight;
    ratio += paddingRatio;
    if (ratio > maxRatio) return maxRatio;
    if (ratio < minRatio) return minRatio;
    return ratio;
  }

  Widget _buildFutureBody() {
    double height = MediaQuery.of(context).size.height * 0.5;
    return FutureBuilder<List<T>>(
      future: widget.itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            height: height,
            child: Center(
              child: ErrorSwitcher(
                message: Localization.of(context, 'an_error_has_occurred'),
                onRetry: () => setState(() {}),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Container(
              height: height,
              child: Center(
                child: NoData(widget.noDataMessage ??
                    Localization.of(context, 'no_data')),
              ),
            );
          } else {
            _items = snapshot.data;
            return _buildItemsBody();
          }
        } else {
          return Container(
            height: height,
            child: Center(
              // child: BankLoader(),
              child: SizedBox(
                child: Opacity(
                  opacity: 1,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.blue,
                  ),
                ),
                height: 1.0,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildItemsBody() {
    return FractionallySizedBox(
      heightFactor: _keyboardOpened ? 0.85 : _heightFactorFromHeight,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: _buildToWidget(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: _buildTitle(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: _buildSearchBox(),
          ),
          _buildItemsList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.itemsFuture != null ? _buildFutureBody() : _buildItemsBody();
  }
}
