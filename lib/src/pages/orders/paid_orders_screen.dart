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
import '../../firebase_notification.dart';
import '../mainPage.dart';
import 'orders_list_tile.dart';

class PaidOrdersScreen extends StatefulWidget {
  final HomeScreenController controller;
  final ShipmentStatus shipmentStatus;

  PaidOrdersScreen({
    Key key,
    this.controller,
    this.shipmentStatus,
  }) : super(key: key);

  @override
  _PaidOrdersScreenState createState() => _PaidOrdersScreenState();
}

class _PaidOrdersScreenState extends State<PaidOrdersScreen>
    with HomeScreenControllerMixin {
  PageState _state;
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
  }) async {
    if (_controller == null || widget.controller == null) {
      await loadHomeScreenController();
      _controller = homeScreenController;
    }
    if (newController != null) _controller = newController;

    setState(() {
      _state = PageState.loading;
    });

    try {
      prefs = await SharedPreferences.getInstance();
      var result = await FirebaseFirestore.instance
          .collection(_controller.SearchInOrdersCollectionName)
          .where("shipmentStatus", arrayContainsAny: [
        widget.shipmentStatus.value,
        // ShipmentStatus.paid.value,
        // ShipmentStatus.awaitingShipment.value,
        // ShipmentStatus.orderOnTheWay.value,
        // ShipmentStatus.awaitingCustomerPickup.value,
      ]).get();

      print((result as QuerySnapshot).docs);
      orders = (result as QuerySnapshot).docs;

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
    );
    _isRefreshing = false;
    setState(() {
      refreshKey = GlobalKey<RefreshIndicatorState>();
    });
  }

  DateTime getDateTime(String acceptedTime) {
    int year = int.tryParse(acceptedTime.split("-")[0].split(" ")[1]);
    int month = int.tryParse(acceptedTime.split("-")[1]);
    int day = int.tryParse(acceptedTime.split(" at")[0].split("-")[2]);

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

  Widget _title() {
    return Container(
        margin: AppTheme.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: widget.shipmentStatus == ShipmentStatus.paid
                      ? Localization.of(context, 'paid')
                      : widget.shipmentStatus == ShipmentStatus.awaitingShipment
                          ? Localization.of(context, 'awaitingShipment')
                          : widget.shipmentStatus ==
                                  ShipmentStatus.orderOnTheWay
                              ? Localization.of(context, 'on_the_way')
                              : Localization.of(
                                  context, 'awaitingCustomerPickup'),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: widget.shipmentStatus == ShipmentStatus.paid
                      ? Localization.of(context, 'orders')
                      : widget.shipmentStatus == ShipmentStatus.awaitingShipment
                          ? Localization.of(context, 'orders')
                          : widget.shipmentStatus ==
                                  ShipmentStatus.orderOnTheWay
                              ? Localization.of(context, 'orders')
                              : Localization.of(context, 'orders'),
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
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FirebaseNotification(child: MainPage()),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          UBScaffold(
            state: AppState(
              pageState: _state,
              onRetry: _load,
            ),
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              margin: EdgeInsets.only(top: 68),
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
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _appBar(),
                      _title(),
                      orders.isEmpty
                          ? Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: NoData(
                                  Localization.of(context, 'no_paid_orders'),
                                ),
                              ),
                            )
                          : Column(
                              children: [
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
                                        "${orders.length ?? 0}",
                                      ),
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return OrdersListTile(
                                      order:
                                          Order.fromJson(orders[index].data()),
                                      controller: _controller,
                                      isLastRow: index == orders.length - 1,
                                      selectedPhoneNumber:
                                          _firebaseAuth.currentUser.phoneNumber,
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
        ],
      ),
    );
  }
}
