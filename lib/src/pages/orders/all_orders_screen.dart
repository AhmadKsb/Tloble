import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/mixins/home_screen_controller_mixin.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_page_state_widget.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/utils/util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/home_screen_controller.dart';
import 'orders_list_tile.dart';

class AllOrdersScreen extends StatefulWidget {
  final HomeScreenController? controller;

  AllOrdersScreen({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen>
    with HomeScreenControllerMixin {
  late PageState _state;
  late DateTime dateSelected;
  late String selectedDateAsString;
  List<QueryDocumentSnapshot> orders = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late SharedPreferences prefss;

  HomeScreenController? _controller;
  bool _isRefreshing = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  num balance = 0;
  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _controller = widget.controller;
    _load();
  }

  void _load({
    HomeScreenController? newController,
    String? selectedDate,
    DateTime? selectedDateFormatted,
  }) async {
    if (_controller == null || widget.controller == null) {
      await loadHomeScreenController();
      _controller = homeScreenController;
    }
    if (newController != null) _controller = newController;

    setState(() {
      _state = PageState.loading;
      dateSelected = selectedDateFormatted ?? DateTime.now();
    });

    try {
      prefss = await SharedPreferences.getInstance();
      selectedDateAsString = selectedDate ??
          "${DateTime.now().year}-${getNumberWithPrefixZero(DateTime.now().month)}-${getNumberWithPrefixZero(DateTime.now().day)}";

      List data = await Future.wait([
        FirebaseFirestore.instance
            .collection('Orders')
            .doc('Orders')
            .collection(selectedDateAsString)
            .snapshots()
            .first
      ]);
      orders = (data[0] as QuerySnapshot).docs;

      orders.sort((a, b) => -(getDateTime(a.id)).compareTo(getDateTime(b.id)));

      setState(() {
        _state = PageState.loaded;
      });
    } catch (e) {
      print(e);
      setState(() {
        _state = PageState.error;
      });
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _load(
      newController: _controller,
      selectedDate: selectedDateAsString,
      selectedDateFormatted: dateSelected,
    );
    _isRefreshing = false;
    setState(() {
      refreshKey = GlobalKey<RefreshIndicatorState>();
    });
  }

  DateTime getDateTime(String acceptedTime) {
    int? day = int.tryParse(acceptedTime.split("-")[0]);
    int? month = int.tryParse(acceptedTime.split("-")[1]);
    int? year = int.tryParse(acceptedTime.split("-")[2].split(" ")[0]);
    int? hour = int.tryParse(acceptedTime.split("at ")[1].split(":")[0]);
    int? minute = int.tryParse(acceptedTime.split("at ")[1].split(":")[1]);
    int? second = int.tryParse(acceptedTime.split("at ")[1].split(":")[2]);

    return DateTime(
      year ?? 0,
      month ?? 0,
      day ?? 0,
      hour ?? 0,
      minute ?? 0,
      second ?? 0,
    );
  }

  void _selectDate() async {
    final DateTime? chosen = await showDatePicker(
      context: context,
      initialDate: dateSelected,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: LightColor.orange,
            accentColor: LightColor.orange,
            colorScheme: ColorScheme.light(
              primary: LightColor.orange,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? SizedBox(),
        );
      },
    );

    if (chosen != null) {
      _load(
        selectedDate:
            "${getNumberWithPrefixZero(chosen.year)}-${getNumberWithPrefixZero(chosen.month)}-${getNumberWithPrefixZero(chosen.day)}",
        selectedDateFormatted: chosen,
      );
    }
  }

  Widget _title() {
    return Container(
        margin: EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: Localization.of(context, 'all'),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: Localization.of(context, 'orders'),
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ));
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns:
                (Localizations.localeOf(context).languageCode == 'ar') ? 2 : 4,
            child: _icon(Icons.arrow_back_ios_new, color: Colors.black54),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(end: 24),
            child: GestureDetector(
              onTap: () {
                _selectDate();
              },
              child: SvgPicture.asset(
                'assets/svgs/calendar.svg',
                width: 20,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      // onTap: null,
      child: Container(
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            // color: Theme.of(context).backgroundColor,
            boxShadow: AppTheme.shadow),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }

  bool _isScrolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UBScaffold(
        state: AppState(
          pageState: _state,
          onRetry: _load,
        ),
        backgroundColor: Colors.transparent,
        builder: (context) => NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                toolbarHeight: 50.0,
                expandedHeight: 50.0,
                backgroundColor: Color(0xfffbfbfb),
                iconTheme: IconThemeData(color: Colors.black54),
                leadingWidth: MediaQuery.of(context).size.width,
                leading: SizedBox(),
                flexibleSpace: SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RotatedBox(
                          quarterTurns:
                              (Localizations.localeOf(context).languageCode ==
                                      'ar')
                                  ? 2
                                  : 4,
                          child: _icon(Icons.arrow_back_ios_new,
                              color: Colors.black54),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(end: 24),
                          child: GestureDetector(
                            onTap: () {
                              _selectDate();
                            },
                            child: SvgPicture.asset(
                              'assets/svgs/calendar.svg',
                              width: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xfffbfbfb),
                  Color(0xfff7f7f7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: RefreshIndicator(
              key: refreshKey,
              onRefresh: refresh,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // _appBar(),
                    _title(),
                    orders.isEmpty
                        ? Container(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: NoData(
                                replaceVariable(
                                      Localization.of(
                                        context,
                                        'no_orders_on',
                                      ),
                                      'value',
                                      DateFormat(
                                        prefss.getString(
                                                    "swiftShop_language") ==
                                                'ar'
                                            ? 'EEEE d MMMM yyyy'
                                            : 'EEEE MMMM d, yyyy',
                                        prefss.getString("swiftShop_language"),
                                      ).format(dateSelected),
                                    ) ??
                                    "",
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  DateFormat(
                                    prefss.getString("swiftShop_language") ==
                                            'ar'
                                        ? 'EEEE d MMMM yyyy'
                                        : 'EEEE MMMM d, yyyy',
                                    prefss.getString("swiftShop_language"),
                                  ).format(dateSelected),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (_controller?.isAdmin ?? false)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    replaceVariable(
                                          Localization.of(
                                            context,
                                            'total_orders',
                                          ),
                                          'value',
                                          "${orders.length}",
                                        ) ??
                                        "",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (_controller?.isAdmin ?? false)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    replaceVariable(
                                          Localization.of(
                                            context,
                                            'total_balance_today',
                                          ),
                                          'value',
                                          "${getBalance()}",
                                        ) ??
                                        "",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable inner ListView scrolling

                                itemCount: orders.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return OrdersListTile(
                                    order: Order.fromJson(orders[index].data()
                                        as Map<dynamic, dynamic>),
                                    controller: _controller!,
                                    isLastRow: index == orders.length - 1,
                                    selectedTime: selectedDateAsString,
                                    selectedPhoneNumber: _firebaseAuth
                                            .currentUser?.phoneNumber ??
                                        "",
                                    shouldRefresh: (shouldRefrsh) {
                                      if (shouldRefrsh) _load();
                                    },
                                  );
                                },
                              ),
                              if (orders.isNotEmpty) SizedBox(height: 64),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getBalance() {
    if (balance == 0) {
      orders.forEach((element) {
        if (balance == null) balance = 0;
        balance += Order.fromJson(element.data() as Map<dynamic, dynamic>)
                .firstPayment! +
            Order.fromJson(element.data() as Map<dynamic, dynamic>)
                .secondPayment!;
      });
    }
    return balance.toString();
  }
}
