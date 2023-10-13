import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/order.dart';
import 'package:wkbeast/utils/UBScaffold/page_state.dart';
import 'package:wkbeast/utils/UBScaffold/ub_page_state_widget.dart';
import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';
import 'package:wkbeast/utils/string_util.dart';

import '../../controllers/home_screen_controller.dart';
import 'orders_list_tile.dart';

class SmallOrdersScreen extends StatefulWidget {
  final HomeScreenController controller;

  SmallOrdersScreen({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  _SmallOrdersScreenState createState() => _SmallOrdersScreenState();
}

class _SmallOrdersScreenState extends State<SmallOrdersScreen> {
  PageState _state;
  DateTime dateSelected;
  String selectedDateAsString;
  List<QueryDocumentSnapshot> orders = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  HomeScreenController _controller;
  bool _isRefreshing = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _controller = widget.controller;
    _load();
  }

  void _load({
    HomeScreenController newController,
    String selectedDate,
    DateTime selectedDateFormatted,
  }) async {
    if (newController != null) _controller = newController;

    setState(() {
      _state = PageState.loading;
      dateSelected = selectedDateFormatted ?? DateTime.now();
    });

    try {
      prefs = await SharedPreferences.getInstance();
      selectedDateAsString = selectedDate ??
          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
      List data = await Future.wait([
        FirebaseFirestore.instance
            .collection('ordersv2')
            .doc('smallOrders')
            .collection(selectedDateAsString)
            .snapshots()
            .first,
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
    int day = int.tryParse(acceptedTime.split("-")[0]);
    int month = int.tryParse(acceptedTime.split("-")[1]);
    int year = int.tryParse(acceptedTime.split("-")[2].split(" ")[0]);
    int hour = int.tryParse(acceptedTime.split("at ")[1].split(":")[0]);
    int minute = int.tryParse(acceptedTime.split("at ")[1].split(":")[1]);
    int second = int.tryParse(acceptedTime.split("at ")[1].split(":")[2]);

    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
    );
  }

  void _selectDate() async {
    final DateTime chosen = await showDatePicker(
      context: context,
      initialDate: dateSelected ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (chosen != null) {
      _load(
        selectedDate: "${chosen.day}-${chosen.month}-${chosen.year}",
        selectedDateFormatted: chosen,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UBScaffold(
        state: AppState(
          pageState: _state,
          onRetry: _load,
        ),
        appBar: AppBar(
          title: Text(
            Localization.of(context, 'orders'),
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 210, 34, 49),
          actions: _state == PageState.loaded
              ? [
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 24),
                    child: GestureDetector(
                      onTap: () {
                        _selectDate();
                      },
                      child: SvgPicture.asset(
                        'assets/svgs/calendar.svg',
                        width: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]
              : null,
        ),
        builder: (context) => RefreshIndicator(
          key: refreshKey,
          onRefresh: refresh,
          child: orders.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: NoData(
                    replaceVariable(
                      Localization.of(
                        context,
                        'no_orders_on',
                      ),
                      'value',
                      DateFormat(
                        prefs.getString("wkbeast_language") == 'ar'
                            ? 'EEEE d MMMM yyyy'
                            : 'EEEE MMMM d, yyyy',
                        prefs.getString("wkbeast_language"),
                      ).format(dateSelected),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        DateFormat(
                          prefs.getString("wkbeast_language") == 'ar'
                              ? 'EEEE d MMMM yyyy'
                              : 'EEEE MMMM d, yyyy',
                          prefs.getString("wkbeast_language"),
                        ).format(dateSelected),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_controller.isAdmin ?? false)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          replaceVariable(
                            Localization.of(
                              context,
                              'total_orders',
                            ),
                            'value',
                            "${orders.length ?? 0}",
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: orders.length,
                        itemBuilder: (BuildContext context, int index) {
                          return OrdersListTile(
                            order: Order.fromJson(orders[index].data()),
                            acceptedTime: null,
                            controller: _controller,
                            isLastRow: index == orders.length - 1,
                            selectedTime: selectedDateAsString,
                            selectedPhoneNumber:
                                _firebaseAuth.currentUser.phoneNumber,
                            isAccepted:
                                Order.fromJson(orders[index].data()).driver ==
                                    _firebaseAuth.currentUser.phoneNumber,
                            shouldRefresh: (shouldRefrsh) {
                              if (shouldRefrsh) _load();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
