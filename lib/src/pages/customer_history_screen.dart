import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/WKNetworkImage.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final HomeScreenController? homeScreenController;

  const CustomerHistoryScreen({
    Key? key,
    this.homeScreenController,
  }) : super(key: key);

  @override
  _CustomerHistoryScreenState createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  late PageState _state;
  List<QueryDocumentSnapshot> history = [];
  List<Order> orders = [];
  late SharedPreferences prefss;
  int acceptedCount = 0;
  int? day, month, year, hour, minute, second;
  late ScrollController _scrollController;

  bool canLoadMore = true;
  bool isLoadingMore = false;
  int _offset = 0;
  int _limit = 10;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _load();
    _offset = _limit;
    _scrollController = ScrollController();
    if (canLoadMore) {
      _scrollController.addListener(_listener);
    }
  }

  void _listener() {
    double percentage = (_scrollController.offset /
            _scrollController.position.maxScrollExtent) *
        100;
    if (_scrollController.offset > 45) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
    if (percentage >= 80) {
      loadMore();
    }
  }

  void _load() async {
    setState(() {
      _state = PageState.loading;
    });

    try {
      var data = await FirebaseFirestore.instance
          .collection(
              widget.homeScreenController?.SearchInOrdersCollectionName ?? "")
          .where("phoneNumber",
              isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber ?? "")
          .orderBy("sentTime", descending: true)
          .limit(_limit)
          .get();

      if (data.docs.isNotEmpty) {
        var newOrders = data.docs;
        orders = [];
        newOrders.forEach((element) {
          orders.add(Order.fromJson(element.data()));
        });

        if (newOrders.length % _limit != 0) canLoadMore = false;
      }

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

  Future<void> loadMore() async {
    if (isLoadingMore || !canLoadMore) return;
    isLoadingMore = true;
    _offset += _limit;

    setState(() {});

    try {
      var data = await FirebaseFirestore.instance
          .collection(
              widget.homeScreenController?.SearchInOrdersCollectionName ?? "")
          .where("phoneNumber",
              isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber ?? "")
          .orderBy("sentTime", descending: true)
          .limit(_offset)
          .get();

      var newOrders = data.docs;

      if (newOrders.isNotEmpty) {
        if ((orders.length) == (newOrders.length)) canLoadMore = false;
        orders = [];
        newOrders.forEach((element) {
          orders.add(Order.fromJson(element.data()));
        });

        if (newOrders.length % _limit != 0) canLoadMore = false;
      } else {
        canLoadMore = false;
      }

      isLoadingMore = false;

      setState(() {});
    } catch (e) {
      print(e);
      setState(() {
        _offset -= _limit;
        isLoadingMore = false;
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

        return customListItem(orders[i], index);
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
    String dateTimeTruncated;
    year = int.tryParse(order.sentTime?.split("-")[0] ?? "0");
    month = int.tryParse(order.sentTime?.split("-")[1] ?? "0");
    day = int.tryParse(order.sentTime?.split("-")[2].split(" ")[0] ?? "0");
    hour = int.tryParse(order.sentTime?.split("at ")[1].split(":")[0] ?? "0");
    minute = int.tryParse(order.sentTime?.split("at ")[1].split(":")[1] ?? "0");
    second = int.tryParse(order.sentTime?.split("at ")[1].split(":")[2] ?? "0");

    String fullDateTime = DateTime(
      year!,
      month!,
      day!,
      hour!,
      minute!,
      second!,
    ).toString().split(".")[0].split(" ")[1];
    dateTimeTruncated = DateTime(
          year!,
          month!,
          day!,
          hour!,
          minute!,
          second!,
        ).toString().split(".")[0].split(" ")[1].split(":")[0] +
        ":" +
        DateTime(
          year!,
          month!,
          day!,
          hour!,
          minute!,
          second!,
        ).toString().split(".")[0].split(" ")[1].split(":")[1];

    return Container(
      margin: EdgeInsets.only(bottom: 52),
      height: 90,
      child: Row(
        children: <Widget>[
          WKNetworkImage(
            order.productsImages?[index],
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
          Builder(
            builder: (BuildContext buildContext) {
              return Expanded(
                child: ListTile(
                  title: InkWell(
                    onTap: () {
                      Clipboard.setData(
                        new ClipboardData(
                            text: order.productsTitles?[index].toString()),
                      ).then((result) {
                        final snackBar = SnackBar(
                          content: Text(Localization.of(
                              context, 'copied_order_id_to_clipboard')),
                          action: SnackBarAction(
                            label: 'Done',
                            onPressed: () {},
                          ),
                        );
                        Scaffold.of(buildContext).showSnackBar(snackBar);
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${Localization.of(context, 'order_summary')} #${order.referenceID.toString()} ",
                              maxLines: 1,
                            ),
                            Image.asset(
                              "assets/images/copy.png",
                              width: 20,
                              height: 20,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        TitleText(
                          text: order.productsTitles?[index],
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150,
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
                        width: 150,
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
                  trailing: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TitleText(
                            text:
                                int.tryParse(dateTimeTruncated.split(":")[0])! <
                                        12
                                    ? "$day/$month/$year "
                                    // +
                                    //     (replaceVariable(
                                    //           Localization.of(
                                    //             context,
                                    //             "sent_at_am",
                                    //           ),
                                    //           'value',
                                    //           dateTimeTruncated,
                                    //         ) ??
                                    //         "")
                                    : "$day/$month/$year ",
                            // +
                            //     (replaceVariable(
                            //           Localization.of(
                            //             context,
                            //             "sent_at_pm",
                            //           ),
                            //           'value',
                            //           dateTimeTruncated,
                            //         ) ??
                            //         ""),
                            style:
                                Theme.of(context).textTheme.subtitle1?.copyWith(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 173, 173, 173),
                                    ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: getShipmentStatusColor(
                                  order.shipmentStatus![0]),
                              borderRadius: BorderRadius.circular(10)),
                          child: TitleText(
                            text: getShipmentStatusString(
                                context, order.shipmentStatus![0]),
                            fontSize: 12,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget customListItem(Order order, int index) {
    String dateTimeTruncated;
    year = int.tryParse(order.sentTime?.split("-")[0] ?? "0");
    month = int.tryParse(order.sentTime?.split("-")[1] ?? "0");
    day = int.tryParse(order.sentTime?.split("-")[2].split(" ")[0] ?? "0");
    hour = int.tryParse(order.sentTime?.split("at ")[1].split(":")[0] ?? "0");
    minute = int.tryParse(order.sentTime?.split("at ")[1].split(":")[1] ?? "0");
    second = int.tryParse(order.sentTime?.split("at ")[1].split(":")[2] ?? "0");

    String fullDateTime = DateTime(
      year!,
      month!,
      day!,
      hour!,
      minute!,
      second!,
    ).toString().split(".")[0].split(" ")[1];
    dateTimeTruncated = DateTime(
          year!,
          month!,
          day!,
          hour!,
          minute!,
          second!,
        ).toString().split(".")[0].split(" ")[1].split(":")[0] +
        ":" +
        DateTime(
          year!,
          month!,
          day!,
          hour!,
          minute!,
          second!,
        ).toString().split(".")[0].split(" ")[1].split(":")[1];

    return Container(
      margin: EdgeInsets.only(bottom: 52),
      // height: 90,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16.0),
            child: WKNetworkImage(
              order.productsImages?[index],
              fit: BoxFit.contain,
              width: 60,
              height: 60,
              defaultWidget: Image.asset(
                "assets/images/login_logo.png",
                width: 60,
                height: 60,
              ),
              placeHolder: AssetImage('assets/images/placeholder.png'),
            ),
          ),
          Builder(
            builder: (BuildContext buildContext) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: order.referenceID.toString(),
                      ),
                    ).then((result) {
                      final snackBar = SnackBar(
                        content: Text(
                          Localization.of(
                              context, 'copied_order_id_to_clipboard'),
                        ),
                        action: SnackBarAction(
                          label: 'Done',
                          onPressed: () {},
                        ),
                      );
                      Scaffold.of(buildContext).showSnackBar(snackBar);
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${Localization.of(context, 'order_summary')} #${order.referenceID.toString()} ",
                            maxLines: 1,
                          ),
                          Image.asset(
                            "assets/images/copy.png",
                            width: 20,
                            height: 20,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: 8.0),
                        child: TitleText(
                          text: order.productsTitles?[index],
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 150,
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
                        width: 150,
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
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TitleText(
                  text: int.tryParse(dateTimeTruncated.split(":")[0])! < 12
                      ? "$day/$month/$year "
                      : "$day/$month/$year ",
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontSize: 12,
                        color: Color.fromARGB(255, 173, 173, 173),
                      ),
                ),
              ),
              Container(
                width: 100,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: getShipmentStatusColor(order.shipmentStatus![0]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TitleText(
                  text: getShipmentStatusString(
                      context, order.shipmentStatus![0]),
                  fontSize: 12,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: Localization.of(context, 'orders_sc'),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: Localization.of(context, 'history_sc'),
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
          // Padding(
          //   padding: EdgeInsetsDirectional.only(end: 24),
          //   child: GestureDetector(
          //     onTap: () {
          //       // _selectDate();
          //     },
          //     child: SvgPicture.asset(
          //       'assets/svgs/calendar.svg',
          //       width: 20,
          //       color: Colors.black54,
          //     ),
          //   ),
          // ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UBScaffold(
        backgroundColor: Colors.transparent,
        state: AppState(
          pageState: _state,
          onRetry: _load,
        ),
        builder: (context) => NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  top: 16.0,
                  start: 12,
                ), // Adjust the padding as needed
                sliver: SliverAppBar(
                  pinned: true,
                  toolbarHeight: 30.0,
                  expandedHeight: 30.0,
                  backgroundColor: Color(0xfffbfbfb),
                  iconTheme: IconThemeData(color: Colors.black54),
                ),
              ),
            ];
          },
          body: Container(
            margin: EdgeInsets.only(top: 36),
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
              // Wrap the content in a SingleChildScrollView
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // _appBar(),
                  _title(),
                  Container(
                    padding: AppTheme.padding,
                    child: (orders.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 75.0),
                            child: Center(
                                child: Text(
                              Localization.of(context, 'no_orders_history'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            )),
                          )
                        : Column(
                            children: <Widget>[
                              _cartItems(),
                              isLoadingMore
                                  ? Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
