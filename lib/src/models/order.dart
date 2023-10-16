import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'dart:convert';

class Order implements Comparable<Order> {
  num? amount;
  num? firstPayment;
  num? secondPayment;
  List<dynamic>? productsTitles = [];
  List<dynamic>? productsQuantities = [];
  List<dynamic>? productsLinks = [];
  List<dynamic>? productsColors = [];
  List<dynamic>? productsSizes = [];
  List<dynamic>? productsPrices = [];
  List<dynamic>? productsImages = [];
  String? notificationToken;
  String? acceptedBy;
  String? customerName;
  String? phoneNumber;
  String? orderSenderPhoneNumber;
  String? employeeWhoSentTheOrder;
  String? locale;
  num? referenceID;
  String? sentTime;
  String? acceptedTime;
  num? coins;
  bool? sentByEmployee;
  List<ShipmentStatus>? shipmentStatus;
  List<OrderStatus>? orderStatus;

  Order({
    this.amount,
    this.firstPayment,
    this.secondPayment,
    this.productsTitles,
    this.productsQuantities,
    this.productsLinks,
    this.productsColors,
    this.productsSizes,
    this.productsPrices,
    this.productsImages,
    this.notificationToken,
    this.acceptedBy,
    this.customerName,
    this.phoneNumber,
    this.orderSenderPhoneNumber,
    this.employeeWhoSentTheOrder,
    this.locale,
    this.referenceID,
    this.sentTime,
    this.acceptedTime,
    this.coins,
    this.sentByEmployee,
    this.shipmentStatus,
    this.orderStatus,
  });

  @override
  int compareTo(Order other) {
    if (num.parse(shipmentStatus?[0].value ?? "-1") >
        num.parse(other.shipmentStatus?[0].value ?? "-1")) {
      return -1;
    } else if (num.parse(shipmentStatus?[0].value ?? "-1") <
        num.parse(other.shipmentStatus?[0].value ?? "-1")) {
      return 1;
    } else {
      return 0;
    }
  }

  factory Order.fromJson(Map<dynamic, dynamic> json) {
    return Order(
      amount: num.tryParse(json['amount'] ?? "0"),
      firstPayment: num.tryParse(json['firstPayment'] ?? "0"),
      secondPayment: num.tryParse(json['secondPayment'] ?? "0"),
      productsTitles: json['productsTitles'] is String
          ? jsonDecode(json['productsTitles'])
          : json['productsTitles'],
      productsQuantities: json['productsQuantities'] is String
          ? jsonDecode(json['productsQuantities'])
          : json['productsQuantities'],
      productsLinks: json['productsLinks'] is String
          ? jsonDecode(json['productsLinks'])
          : json['productsLinks'],
      productsColors: json['productsColors'] is String
          ? jsonDecode(json['productsColors'])
          : json['productsColors'],
      productsSizes: json['productsSizes'] is String
          ? jsonDecode(json['productsSizes'])
          : json['productsSizes'],
      productsPrices: json['productsPrices'] is String
          ? jsonDecode(json['productsPrices'])
          : json['productsPrices'],
      productsImages: json['productsImages'] is String
          ? jsonDecode(json['productsImages'])
          : json['productsImages'],
      notificationToken: json['notificationToken'],
      acceptedBy: json['acceptedBy'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      orderSenderPhoneNumber: json['orderSenderPhoneNumber'],
      employeeWhoSentTheOrder: json['employeeWhoSentTheOrder'],
      locale: json['locale'],
      referenceID: num.tryParse(json['referenceID'].toString()),
      sentTime: json['sentTime'],
      acceptedTime: json['acceptedTime'],
      sentByEmployee: json['sentByEmployee'],
      coins: num.tryParse((json['coins'] ?? "0").toString()),
      shipmentStatus: json['shipmentStatus'] != null
          ? [
              ShipmentStatus(json['shipmentStatus'] is List
                  ? json['shipmentStatus'][0]
                  : null)
            ]
          : null,
      orderStatus: json['orderStatus'] != null
          ? [
              OrderStatus(
                  json['orderStatus'] is List ? json['orderStatus'][0] : null)
            ]
          : null,
    );
  }

  static List<Order> fromJsonList(List json) {
    List<Order>? orders = json.map((order) => Order.fromJson(order)).toList();
    return orders;
  }

  Map<String, dynamic> toJson({bool received = false}) {
    Map<String, dynamic> json = {
      'amount': amount.toString(),
      'firstPayment': firstPayment.toString(),
      'secondPayment': secondPayment.toString(),
      'sentByEmployee': sentByEmployee,
      'productsTitles': productsTitles,
      'productsQuantities': productsQuantities,
      'productsLinks': productsLinks,
      'productsColors': productsColors,
      'productsSizes': productsSizes,
      'productsPrices': productsPrices,
      'productsImages': productsImages,
      'notificationToken': notificationToken,
      'acceptedBy': acceptedBy,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'orderSenderPhoneNumber': orderSenderPhoneNumber,
      'employeeWhoSentTheOrder': employeeWhoSentTheOrder,
      'locale': locale,
      'referenceID': referenceID,
      'sentTime': sentTime,
      'acceptedTime': acceptedTime,
      'coins': coins,
      'shipmentStatus': [shipmentStatus?[0].value],
      'orderStatus': [orderStatus?[0].value],
    };

    return json;
  }
}

class OrderStatus extends Enum {
  static const contactCustomer = OrderStatus._internal("CC");
  static const accepted = OrderStatus._internal("A");
  static const pending = OrderStatus._internal("P");
  static const pendingArrival = OrderStatus._internal("PA");
  static const rejected = OrderStatus._internal("R");
  static const completed = OrderStatus._internal("C");
  static const unknown = OrderStatus._internal("-1");

  static const List<OrderStatus> values = [
    contactCustomer,
    accepted,
    pending,
    pendingArrival,
    rejected,
    completed,
    unknown,
  ];

  const OrderStatus._internal(String value) : super.internal(value);

  factory OrderStatus(String raw) => values.singleWhere(
        (val) => val.value == raw,
        orElse: () => OrderStatus.unknown,
      );
}

class ShipmentStatus extends Enum {
  static const awaitingCustomer = ShipmentStatus._internal("1");
  static const awaitingPayment = ShipmentStatus._internal("2");
  static const paid = ShipmentStatus._internal("3");
  static const awaitingShipment = ShipmentStatus._internal("4");
  static const orderOnTheWay = ShipmentStatus._internal("5");
  static const awaitingCustomerPickup = ShipmentStatus._internal("6");
  static const customerRejected = ShipmentStatus._internal("7");
  static const completed = ShipmentStatus._internal("8");
  static const unknown = ShipmentStatus._internal("-1");

  static const List<ShipmentStatus> values = [
    awaitingCustomer,
    awaitingPayment,
    paid,
    awaitingShipment,
    orderOnTheWay,
    awaitingCustomerPickup,
    customerRejected,
    completed,
    unknown,
  ];

  const ShipmentStatus._internal(String value) : super.internal(value);

  factory ShipmentStatus(String raw) => values.singleWhere(
        (val) => val.value == raw,
        orElse: () => ShipmentStatus.unknown,
      );
}

abstract class Enum {
  const Enum.internal(this.value);

  final String value;

  static const List<Enum> values = [];
}

String? getShipmentStatusString(BuildContext context, ShipmentStatus status) {
  switch (status) {
    case ShipmentStatus.awaitingCustomer:
      return Localization.of(context, 'awaitingCustomer');
    case ShipmentStatus.paid:
      return Localization.of(context, 'paid');
    case ShipmentStatus.awaitingPayment:
      return Localization.of(context, 'awaitingPayment');
    case ShipmentStatus.awaitingShipment:
      return Localization.of(context, 'underInspection');
    case ShipmentStatus.orderOnTheWay:
      return Localization.of(context, 'orderOnTheWay');
    case ShipmentStatus.awaitingCustomerPickup:
      return Localization.of(context, 'awaitingCustomerPickup');
    case ShipmentStatus.completed:
      return Localization.of(context, 'completed');
    case ShipmentStatus.customerRejected:
      return Localization.of(context, 'customerCancelled');
    case ShipmentStatus.unknown:
      return "Unknown";
    default:
      return "null shipment status";
  }
}

String? getShipmentStatusForEmployeeStringExcel(
  BuildContext context,
  ShipmentStatus? status,
) {
  switch (status) {
    case ShipmentStatus.awaitingCustomer:
      return "Awaiting customer";
    case ShipmentStatus.paid:
      return "Paid";
    case ShipmentStatus.awaitingPayment:
      return "Awaiting payment";
    case ShipmentStatus.awaitingShipment:
      return "In our warehouse outside Lebanon";
    case ShipmentStatus.orderOnTheWay:
      return "Order on the way";
    case ShipmentStatus.awaitingCustomerPickup:
      return "Awaiting customer pickup";
    case ShipmentStatus.completed:
      return "Completed";
    case ShipmentStatus.customerRejected:
      return "Cancelled";
    case ShipmentStatus.unknown:
      return "Unknown";
    default:
      return "null";
  }
}

String? getShipmentStatusForEmployeeString(
  BuildContext context,
  ShipmentStatus? status,
) {
  switch (status) {
    case ShipmentStatus.awaitingCustomer:
      return Localization.of(context, 'awaitingCustomer');
    case ShipmentStatus.paid:
      return Localization.of(context, 'paid');
    case ShipmentStatus.awaitingPayment:
      return Localization.of(context, 'awaitingPayment');
    case ShipmentStatus.awaitingShipment:
      return Localization.of(context, 'in_our_warehouse_outside_lebanon');
    case ShipmentStatus.orderOnTheWay:
      return Localization.of(context, 'orderOnTheWay');
    case ShipmentStatus.awaitingCustomerPickup:
      return Localization.of(context, 'awaitingCustomerPickup');
    case ShipmentStatus.completed:
      return Localization.of(context, 'completed');
    case ShipmentStatus.customerRejected:
      return Localization.of(context, 'customerCancelled');
    case ShipmentStatus.unknown:
      return "Unknown";
    default:
      return "null shipment status";
  }
}

Color getShipmentStatusColor(ShipmentStatus? status) {
  switch (status) {
    case ShipmentStatus.awaitingCustomer:
    case ShipmentStatus.awaitingPayment:
    case ShipmentStatus.awaitingShipment:
    case ShipmentStatus.orderOnTheWay:
      return LightColor.lightGrey.withAlpha(150);
    case ShipmentStatus.paid:
      return LightColor.lightGrey.withAlpha(255);
    case ShipmentStatus.awaitingCustomerPickup:
      return LightColor.yellowColor.withAlpha(150);
    case ShipmentStatus.customerRejected:
      return LightColor.red.withAlpha(150);
    case ShipmentStatus.completed:
      return Colors.green.withAlpha(150);
    case ShipmentStatus.unknown:
      return LightColor.red.withAlpha(150);
    default:
      return LightColor.red.withAlpha(150);
  }
}

extension BoolParsing on String {
  bool tryParseBool() {
    if (this.isEmpty) return false;
    return this.toLowerCase() == 'true';
  }
}
