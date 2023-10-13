import 'package:flutter/material.dart';
import 'package:wkbeast/controllers/home_screen_controller.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/order.dart';
import 'package:wkbeast/screens/orders/order_screen.dart';
import 'package:wkbeast/utils/string_util.dart';

class OrdersListTile extends StatefulWidget {
  final Order order;
  final HomeScreenController controller;
  final String acceptedTime;
  final String selectedTime;
  final String selectedPhoneNumber;
  final bool isLastRow;
  final bool isAccepted;
  final ValueChanged<bool> shouldRefresh;

  const OrdersListTile({
    Key key,
    this.order,
    this.controller,
    this.acceptedTime,
    this.selectedTime,
    this.selectedPhoneNumber,
    this.isAccepted = false,
    this.isLastRow = false,
    this.shouldRefresh,
  }) : super(key: key);

  @override
  _OrdersListTileState createState() => _OrdersListTileState();
}

class _OrdersListTileState extends State<OrdersListTile> {
  int day, month, year, hour, minute, second;

  @override
  initState() {
    super.initState();
  }

  Widget _buildBody() {
    if (widget.acceptedTime != null) {
      day = int.tryParse(widget.acceptedTime.split("-")[0]);
      month = int.tryParse(widget.acceptedTime.split("-")[1]);
      year = int.tryParse(widget.acceptedTime.split("-")[2].split(" ")[0]);
      hour = int.tryParse(widget.acceptedTime.split("at ")[1].split(":")[0]);
      minute = int.tryParse(widget.acceptedTime.split("at ")[1].split(":")[1]);
      second = int.tryParse(widget.acceptedTime.split("at ")[1].split(":")[2]);
    }
    String fullDateTime = widget.acceptedTime != null
        ? DateTime(
            year,
            month,
            day,
            hour,
            minute,
            second,
          ).toString().split(".")[0].split(" ")[1]
        : '';
    String dateTimeTruncated = widget.acceptedTime != null
        ? DateTime(
              year,
              month,
              day,
              hour,
              minute,
              second,
            ).toString().split(".")[0].split(" ")[1].split(":")[0] +
            ":" +
            DateTime(
              year,
              month,
              day,
              hour,
              minute,
              second,
            ).toString().split(".")[0].split(" ")[1].split(":")[1]
        : '';

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 15,
        end: 15,
        bottom: widget.isLastRow ? 32 : 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isAccepted || widget.order.accepted
              ? Colors.grey.withOpacity(0.4)
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
                decoration: BoxDecoration(
                  color: widget.order.action.toLowerCase() == 'buy'
                      ? Color.fromARGB(255, 210, 34, 49)
                      : Color.fromARGB(255, 50, 205, 50),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                  ),
                ),
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
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  widget.isAccepted ||
                                          (widget.controller?.isAdmin ?? false)
                                      ? replaceVariable(
                                          Localization.of(
                                            context,
                                            "${(widget.order.action).toLowerCase()}_order_from",
                                          ),
                                          'value',
                                          (Localizations.localeOf(context)
                                                      .languageCode ==
                                                  'ar')
                                              ? ((widget.order?.phoneNumber
                                                          ?.replaceAll(
                                                              '+', '') ??
                                                      '') +
                                                  '+')
                                              : ('+' +
                                                  (widget.order?.phoneNumber
                                                          ?.replaceAll(
                                                              '+', '') ??
                                                      "")),
                                        )
                                      : Localization.of(
                                          context,
                                          "${(widget.order.action).toLowerCase()}_order",
                                        ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 34, 34, 34),
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 1),
                          widget.acceptedTime != null
                              ? Text(
                                  int.tryParse(
                                              dateTimeTruncated.split(":")[0]) <
                                          12
                                      ? replaceVariable(
                                          Localization.of(
                                            context,
                                            "accepted_at_am",
                                          ),
                                          'value',
                                          dateTimeTruncated,
                                        )
                                      : replaceVariable(
                                          Localization.of(
                                            context,
                                            "accepted_at_pm",
                                          ),
                                          'value',
                                          dateTimeTruncated,
                                        ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                        fontSize: 12,
                                        color:
                                            Color.fromARGB(255, 173, 173, 173),
                                      ),
                                )
                              : Container(),
                          SizedBox(height: 8),
                          Container(
                            height: 25,
                            child: Text(
                              widget.isAccepted ||
                                      (widget.controller?.isAdmin ?? false)
                                  ? "${widget.order.action.toLowerCase() == 'buy' ? '\$ ' : ""}${widget.order.amount}${widget.order.action.toLowerCase() == 'buy' ? '' : " ${widget.controller.mainCurrency}"}"
                                  : "${widget.order.action.toLowerCase() == 'buy' ? '\$ ' : ""}*****${widget.order.action.toLowerCase() == 'buy' ? '' : " ${widget.controller.mainCurrency}"}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 34, 34, 34)),
                            ),
                          ),
                          if (widget.order.moneyOut != null &&
                              widget.order.moneyOut > 0)
                            Container(
                              height: 25,
                              child: Text(
                                '${widget.order.action.toLowerCase() == 'buy' ? replaceVariable(
                                    Localization.of(
                                      context,
                                      'usdt_sent',
                                    ),
                                    'mainCurrency',
                                    widget.controller.mainCurrency,
                                  ) : Localization.of(context, 'cash_paid')} \$ ${widget.order.moneyOut}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 34, 34, 34)),
                              ),
                            ),
                          if (widget.order.moneyIn != null &&
                              widget.order.moneyIn > 0)
                            Container(
                              height: 25,
                              child: Text(
                                '${widget.order.action.toLowerCase() == 'buy' ? Localization.of(context, 'cash_received') : replaceVariable(
                                    Localization.of(
                                      context,
                                      'usdt_received',
                                    ),
                                    'mainCurrency',
                                    widget.controller.mainCurrency,
                                  )} \$ ${widget.order.moneyIn}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 34, 34, 34)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    widget.acceptedTime != null
                        ? Text(
                            getTimeDifference(),
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 173, 173, 173),
                                    ),
                          )
                        : Container(),
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
    Duration difference = widget.acceptedTime != null
        ? DateTime.now().difference(
            DateTime(
              year,
              month,
              day,
              hour,
              minute,
              second,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
            order: widget.order,
            isAdmin: widget.controller.isAdmin,
            accepted: widget.isAccepted ?? false,
            shouldRefresh: (shouldRfrsh) {
              widget.shouldRefresh(shouldRfrsh);
            }),
      ),
    );
  }
}
