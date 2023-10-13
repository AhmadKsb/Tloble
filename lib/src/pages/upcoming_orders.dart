import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/model/data.dart';
import 'package:flutter_ecommerce_app/src/model/product.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/loader.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/WKNetworkImage.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';

import 'order_summary.dart';

class UpcomingOrdersScreen extends StatefulWidget {
  final HomeScreenController homeScreenController;

  const UpcomingOrdersScreen({
    Key key,
    this.homeScreenController,
  }) : super(key: key);

  @override
  _UpcomingOrdersScreenState createState() => _UpcomingOrdersScreenState();
}

class _UpcomingOrdersScreenState extends State<UpcomingOrdersScreen> {
  PageState _state;
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = PageState.loading;
    });

    try {
      var result = await FirebaseFirestore.instance
          .collection(widget.homeScreenController.SearchInOrdersCollectionName)
          .where("phoneNumber",
              isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber ?? "")
          .where("shipmentStatus", arrayContainsAny: [
        ShipmentStatus.paid.value,
        ShipmentStatus.awaitingShipment.value,
        ShipmentStatus.orderOnTheWay.value,
        ShipmentStatus.awaitingCustomerPickup.value,
      ]).get();

      if (result != null && result.docs.isNotEmpty) {
        result.docs.forEach((element) {
          orders.add(Order.fromJson(element.data()));
        });
      }
      orders.sort();

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

  var index = -1;
  List<Widget> items = [];
  Column _cartItems() {
    items = [];
    for (int i = 0; i < orders.length; i++) {
      index = -1;
      items.add(Column(
          children: orders[i].productsTitles.map((y) {
        index += 1;

        return _item(index, order: orders[i]);
      }).toList()));
    }
    return Column(
      children: items,
    );
    // return Column(
    //     children: orders.map((x) {
    //   index += 1;
    //   for (int i = 0; i < orders[index].productsTitles?.length; i++) {
    //     items.add(_item(index, isLastIndex: index == (orders?.length ?? 0) - 1, order: orders[index]));
    //   }
    //   return items;
    // }).toList());
  }

  Widget _item(var index, {Order order}) {
    return Container(
      margin: EdgeInsets.only(bottom: 36),
      height: 80,
      child: Row(
        children: <Widget>[
          WKNetworkImage(
            order.productsImages[index],
            fit: BoxFit.contain,
            width: 100,
            height: 100,
            defaultWidget: Image.asset(
              "assets/images/login_logo.png",
            ),
            placeHolder: AssetImage(
              'assets/images/placeholder.png',
            ),
          ),
          Expanded(
            child: ListTile(
              title: TitleText(
                text: order.productsTitles[index],
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${Localization.of(context, 'color:')} ${isNotEmpty(order.productsColors[index]) ? order.productsColors[index] : Localization.of(context, 'not_specified')}",
                        maxLines: 1,
                        style: TextStyle(
                          // fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      margin: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${Localization.of(context, 'size:')} ${isNotEmpty(order.productsSizes[index]) ? order.productsSizes[index] : Localization.of(context, 'not_specified')}",
                        maxLines: 1,
                        style: TextStyle(
                          // fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Container(
                width: 100,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: getShipmentStatusColor(order.shipmentStatus[0]),
                    borderRadius: BorderRadius.circular(10)),
                child: TitleText(
                  text:
                      getShipmentStatusString(context, order.shipmentStatus[0]),
                  fontSize: 12,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.padding,
      child: ((orders?.isEmpty ?? true) ||
              widget.homeScreenController.hideContents)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 75.0),
              child: Center(
                  child: Text(
                widget.homeScreenController.hideContents
                    ? Localization.of(context, 'coming_soon')
                    : Localization.of(context, 'no_upcoming_orders'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              )),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _cartItems(),
                ],
              ),
            ),
    );
  }
}
