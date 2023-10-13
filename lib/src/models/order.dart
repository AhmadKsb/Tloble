class Order {
  String action;
  num amount;
  num moneyIn;
  num moneyOut;
  String details;
  String driver;
  num latitude;
  num longitude;
  String name;
  String notificationToken;
  String phoneNumber;
  num referenceID;
  bool shareLocation;
  bool accepted;
  String orderTime;
  String location;
  String sentTime;
  String acceptedTime;
  String customerOrderDateTime;
  num coins;

  Order({
    this.action,
    this.amount,
    this.moneyIn,
    this.moneyOut,
    this.details,
    this.driver,
    this.latitude,
    this.longitude,
    this.name,
    this.notificationToken,
    this.phoneNumber,
    this.referenceID,
    this.shareLocation,
    this.orderTime,
    this.location,
    this.sentTime,
    this.acceptedTime,
    this.accepted,
    this.coins,
    this.customerOrderDateTime,
  });

  factory Order.fromJson(Map<dynamic, dynamic> json) {
    return Order(
      action: json['action'],
      amount: num.tryParse(json['amount']),
      details: json['details'],
      driver: json['driver'],
      latitude: json['latitude'] != null
          ? num.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? num.tryParse(json['longitude'].toString())
          : null,
      name: json['name'],
      notificationToken: json.containsKey('notificationToken')
          ? json['notificationToken']
          : json['notification_token'],
      phoneNumber: json.containsKey('phoneNumber')
          ? json['phoneNumber']
          : json['phone number'],
      referenceID: num.tryParse(json['referenceID'].toString()),
      coins: num.tryParse(json['coins'].toString()),
      shareLocation: json.containsKey('shareLocation')
          ? json['shareLocation'].toString().toLowerCase() == 'true'
          : json['share location'].toString().toLowerCase() == 'true',
      orderTime: json['time'],
      location: json['location'],
      moneyIn: json['money_in'],
      moneyOut: json['money_out'],
      sentTime: json['sent_time'],
      acceptedTime: json['acceptedTime'],
      customerOrderDateTime: json['customerOrderDateTime'],
      accepted: json['accepted'].toString().toLowerCase() == 'true',
    );
  }

  static List<Order> fromJsonList(List json) {
    List<Order> orders = json?.map((order) => Order.fromJson(order))?.toList();
    return orders;
  }

  Map<String, dynamic> toJson({bool received = false}) {
    Map<String, dynamic> json = {
      'name': name,
      'amount': amount.toString(),
      'action': action,
      'longitude': longitude,
      'latitude': latitude,
      'details': details,
      'phone number': phoneNumber,
      'share location': shareLocation,
      'driver': driver,
      'referenceID': referenceID,
      'coins': coins,
      'notification_token': notificationToken,
      'time': orderTime,
      'received': received,
      'location': location,
      'money_in': moneyIn,
      'money_out': moneyOut,
      'sent_time': sentTime,
      'acceptedTime': acceptedTime,
      'accepted': accepted,
      'customerOrderDateTime': customerOrderDateTime,
    };

    return json;
  }
}
