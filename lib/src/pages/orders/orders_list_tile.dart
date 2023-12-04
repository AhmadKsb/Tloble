import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';

import '../../models/employee.dart';
import 'order_screen.dart';

class OrdersListTile extends StatefulWidget {
  final Orders? order;
  final HomeScreenController? controller;
  final String? selectedTime;
  final String? selectedPhoneNumber;
  final bool? isLastRow;
  final ValueChanged<bool>? shouldRefresh;

  const OrdersListTile({
    Key? key,
    this.order,
    this.controller,
    this.selectedTime,
    this.selectedPhoneNumber,
    this.isLastRow = false,
    this.shouldRefresh,
  }) : super(key: key);

  @override
  _OrdersListTileState createState() => _OrdersListTileState();
}

class _OrdersListTileState extends State<OrdersListTile> {
  int? day, month, year, hour, minute, second;

  @override
  initState() {
    super.initState();
  }

  Widget _buildBody() {
    if (widget.order?.acceptedTime?.isNotEmpty ?? false) {
      day = int.tryParse(
          widget.order?.acceptedTime?.split("-")[2].split(" ")[0] ?? "");
      month = int.tryParse(widget.order?.acceptedTime?.split("-")[1] ?? "");
      year = int.tryParse(
          widget.order?.acceptedTime?.split("-")[0].split(" ")[0] ?? "");
      hour = int.tryParse(
          widget.order?.acceptedTime?.split("at ")[1].split(":")[0] ?? "");
      minute = int.tryParse(
          widget.order?.acceptedTime?.split("at ")[1].split(":")[1] ?? "");
      second = int.tryParse(
          widget.order?.acceptedTime?.split("at ")[1].split(":")[2] ?? "");
    }
    // String fullDateTime = widget.order.acceptedTime.isNotEmpty
    //     ? DateTime(
    //         year,
    //         month,
    //         day,
    //         hour,
    //         minute,
    //         second,
    //       ).toString().split(".")[0].split(" ")[1]
    //     : '';
    String dateTimeTruncated = (widget.order?.acceptedTime?.isNotEmpty ?? false)
        ? DateTime(
              year ?? 0,
              month ?? 0,
              day ?? 0,
              hour ?? 0,
              minute ?? 0,
              second ?? 0,
            ).toString().split(".")[0].split(" ")[1].split(":")[0] +
            ":" +
            DateTime(
              year ?? 0,
              month ?? 0,
              day ?? 0,
              hour ?? 0,
              minute ?? 0,
              second ?? 0,
            ).toString().split(".")[0].split(" ")[1].split(":")[1]
        : '';

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 15,
        end: 15,
        bottom: (widget.isLastRow ?? false) ? 32 : 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: (widget.order?.acceptedTime?.isNotEmpty ?? false)
              ? Colors.grey.withOpacity(0.5)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.0),
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(5.0),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 5,
              ),
            ),
            InkWell(
              onTap: _onHistoryTapped,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 8.0,
                                  ),
                                  child: Text(
                                    replaceVariable(
                                          Localization.of(
                                            context,
                                            "order_from",
                                          ),
                                          'value',
                                          (Localizations.localeOf(context)
                                                      .languageCode ==
                                                  'ar')
                                              ? ((widget.order?.customerName
                                                      ?.replaceAll('+', '') ??
                                                  ''))
                                              : ((widget.order?.customerName
                                                      ?.replaceAll('+', '') ??
                                                  "")),
                                        ) ??
                                        "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.copyWith(
                                          fontSize: 15,
                                          color:
                                              Color.fromARGB(255, 34, 34, 34),
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 8),
                          (widget.order?.acceptedTime?.isNotEmpty ?? false)
                              ? Text(
                                  "${int.tryParse(dateTimeTruncated.split(":")[0])! < 12 ? replaceVariable(
                                      Localization.of(
                                        context,
                                        "accepted_at_am",
                                      ),
                                      'value',
                                      dateTimeTruncated,
                                    ) : replaceVariable(
                                      Localization.of(
                                        context,
                                        "accepted_at_pm",
                                      ),
                                      'value',
                                      dateTimeTruncated,
                                    )} ${Localization.of(context, 'by')} ${widget.controller?.employees.firstWhere((element) => element.name?.toLowerCase() == widget.order?.acceptedBy?.toLowerCase(), orElse: () => Employee()).name}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                )
                              : Container(),
                          SizedBox(height: 8),
                          // Container(
                          //   height: 25,
                          //   child: Text(
                          //     widget.order.acceptedTime.isNotEmpty ||
                          //             (widget.controller?.isAdmin ?? false)
                          //         ? "${widget.order.action.toLowerCase() == 'buy' ? '\$ ' : ""}${widget.order.amount}${widget.order.action.toLowerCase() == 'buy' ? '' : " ${widget.controller.mainCurrency}"}"
                          //         : "${widget.order.action.toLowerCase() == 'buy' ? '\$ ' : ""}*****${widget.order.action.toLowerCase() == 'buy' ? '' : " ${widget.controller.mainCurrency}"}",
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .bodyText2
                          //         .copyWith(
                          //             fontSize: 14,
                          //             color: Color.fromARGB(255, 34, 34, 34)),
                          //   ),
                          // ),
                          // if (widget.order.moneyOut != null &&
                          //     widget.order.moneyOut > 0)
                          //   Container(
                          //     height: 25,
                          //     child: Text(
                          //       '${widget.order.action.toLowerCase() == 'buy' ? replaceVariable(
                          //           Localization.of(
                          //             context,
                          //             'usdt_sent',
                          //           ),
                          //           'mainCurrency',
                          //           widget.controller.mainCurrency,
                          //         ) : Localization.of(context, 'cash_paid')} \$ ${widget.order.moneyOut}',
                          //       style: Theme.of(context)
                          //           .textTheme
                          //           .bodyText2
                          //           .copyWith(
                          //               fontSize: 14,
                          //               color: Color.fromARGB(255, 34, 34, 34)),
                          //     ),
                          //   ),
                          // if (widget.order.moneyIn != null &&
                          //     widget.order.moneyIn > 0)
                          //   Container(
                          //     height: 25,
                          //     child: Text(
                          //       '${widget.order.action.toLowerCase() == 'buy' ? Localization.of(context, 'cash_received') : replaceVariable(
                          //           Localization.of(
                          //             context,
                          //             'usdt_received',
                          //           ),
                          //           'mainCurrency',
                          //           widget.controller.mainCurrency,
                          //         )} \$ ${widget.order.moneyIn}',
                          //       style: Theme.of(context)
                          //           .textTheme
                          //           .bodyText2
                          //           .copyWith(
                          //               fontSize: 14,
                          //               color: Color.fromARGB(255, 34, 34, 34)),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: getShipmentStatusColor(
                                  widget.order?.shipmentStatus?[0]),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            getShipmentStatusForEmployeeString(
                                  context,
                                  widget.order?.shipmentStatus?[0],
                                ) ??
                                "",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        (widget.order?.sentTime?.isNotEmpty ?? false)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  getTimeDifference(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeDifference() {
    var dayy = int.tryParse(
        widget.order?.sentTime?.split("-")[2].split(" ")[0] ?? "0");
    var monthh = int.tryParse(widget.order?.sentTime?.split("-")[1] ?? "0");
    var yearr = int.tryParse(
        widget.order?.sentTime?.split("-")[0].split(" ")[0] ?? "0");
    var hourr = int.tryParse(
        widget.order?.sentTime?.split("at ")[1].split(":")[0] ?? "0");
    var minutee = int.tryParse(
        widget.order?.sentTime?.split("at ")[1].split(":")[1] ?? "0");
    var secondd = int.tryParse(
        widget.order?.sentTime?.split("at ")[1].split(":")[2] ?? "0");

    Duration difference = (widget.order?.sentTime?.isNotEmpty ?? false)
        ? DateTime.now().difference(
            DateTime(
              yearr ?? 0,
              monthh ?? 0,
              dayy ?? 0,
              hourr ?? 0,
              minutee ?? 0,
              secondd ?? 0,
            ),
          )
        : Duration();

    if (difference.inMinutes > 60) {
      if (difference.inMinutes > 1440) {
        int numberOfHours =
            difference.inMinutes - (difference.inMinutes ~/ 1440 * 1440);
        return "${difference.inMinutes ~/ 1440}${Localization.of(context, 'd')} ${numberOfHours ~/ 60}${Localization.of(context, 'h')} ${difference.inMinutes % 60}min ago";
      }
      return "${difference.inMinutes ~/ 60}${Localization.of(context, 'h')} ${difference.inMinutes % 60}${Localization.of(context, 'min_ago')}";
    }
    return "${difference.inMinutes % 60}${Localization.of(context, 'min_ago')}";
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  void _onHistoryTapped() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
          homeScreenController: widget.controller!,
          order: widget.order!,
        ),
      ),
    );
    if (widget.shouldRefresh != null) widget.shouldRefresh!(true);
  }
}
