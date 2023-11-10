import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/WKNetworkImage.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/BottomSheets/bottom_sheet_helper.dart';

class UpcomingOrdersScreen extends StatefulWidget {
  final HomeScreenController homeScreenController;

  const UpcomingOrdersScreen({
    Key? key,
    required this.homeScreenController,
  }) : super(key: key);

  @override
  _UpcomingOrdersScreenState createState() => _UpcomingOrdersScreenState();
}

class _UpcomingOrdersScreenState extends State<UpcomingOrdersScreen> {
  late PageState _state;
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
          .collection(
              widget.homeScreenController.SearchInOrdersCollectionName ?? "")
          .where("phoneNumber",
              isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber ?? "")
          .where("shipmentStatus", arrayContainsAny: [
        ShipmentStatus.paid.value,
        ShipmentStatus.awaitingShipment.value,
        ShipmentStatus.orderOnTheWay.value,
        ShipmentStatus.awaitingCustomerPickup.value,
      ]).get();

      if (result.docs.isNotEmpty) {
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
          children: orders[i].productsTitles!.map((y) {
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

  Widget _item(
    var index, {
    required Order order,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 36),
      height: 80,
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () async {
              try {
                bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
                var url = order.productsLinks?[index];
                if (isIOS) {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    print('Could not launch $url');
                    throw Exception('Could not launch $url');
                  }
                } else {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    print('Could not launch $url');
                    throw Exception('Could not launch $url');
                  }
                }
              } catch (e) {
                print(e);
                showErrorBottomsheet(
                  context,
                  'An error has occurred: $e',
                );
              }
            },
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0),
                // border: Border.all(
                //   width: 1.0,
                //   color: Colors.grey.withOpacity(0.4),
                // ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: WKNetworkImage(
                ((widget.homeScreenController.hideImage ?? true))
                    ? ""
                    : order.productsImages?[index],
                fit: BoxFit.contain,
                width: 60,
                height: 60,
                defaultWidget: Image.asset(
                  "assets/images/login_logo.png",
                  width: 60,
                  height: 60,
                ),
                placeHolder: AssetImage(
                  'assets/images/placeholder.png',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: GestureDetector(
                onLongPress: () {
                  Clipboard.setData(new ClipboardData(
                      text: order.productsLinks?[index]))
                      .then((result) {
                    final snackBar = SnackBar(
                      content: Text('Copied product link to Clipboard'),
                      action: SnackBarAction(
                        label: 'Done',
                        onPressed: () {},
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  });
                },
                onTap: () async {
                  // print("ASD");
                  try {
                    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
                    var url = order.productsLinks?[index];
                    if (isIOS) {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Could not launch $url');
                        throw Exception('Could not launch $url');
                      }
                    } else {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print('Could not launch $url');
                        throw Exception('Could not launch $url');
                      }
                    }
                  } catch (e) {
                    print(e);
                    showErrorBottomsheet(
                      context,
                      'An error has occurred: $e',
                    );
                  }
                },
                child: TitleText(
                  text: order.productsTitles?[index],
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color:
                    Color.fromARGB(255, 0, 0, 255).withOpacity(0.9),
                  ),
                ),
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 200,
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${Localization.of(context, 'quantity:')} ${isNotEmpty(order.productsQuantities?[index]) ? order.productsQuantities![index] : Localization.of(context, 'not_specified')}",
                      maxLines: 1,
                      style: TextStyle(
                        // fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 200,
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${Localization.of(context, 'color:')} ${isNotEmpty(order.productsColors?[index]) ? order.productsColors![index] : Localization.of(context, 'not_specified')}",
                      maxLines: 1,
                      style: TextStyle(
                        // fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 200,
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${Localization.of(context, 'size:')} ${isNotEmpty(order.productsSizes?[index]) ? order.productsSizes![index] : Localization.of(context, 'not_specified')}",
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
                width: 80,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: getShipmentStatusColor(order.shipmentStatus![0]),
                    borderRadius: BorderRadius.circular(10)),
                child: TitleText(
                  text: getShipmentStatusString(
                      context, order.shipmentStatus![0]),
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
    return UBScaffold(
      backgroundColor: Colors.transparent,
      state: AppState(
        pageState: _state,
        onRetry: _load,
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: (orders.isEmpty ||
                (widget.homeScreenController.hideContents ?? false))
            ? Padding(
                padding: const EdgeInsets.only(bottom: 75.0),
                child: Center(
                    child: Text(
                  (widget.homeScreenController.hideContents ?? false)
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
                    SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }
}
