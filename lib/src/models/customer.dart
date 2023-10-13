class Customer {
  String phoneNumber;
  String notificationToken;
  num totalMoneyIn;
  num totalMoneyOut;
  num coins;

  Customer({
    this.totalMoneyIn,
    this.totalMoneyOut,
    this.phoneNumber,
    this.notificationToken,
    this.coins,
  });

  factory Customer.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) return null;

    return Customer(
      phoneNumber: json.containsKey('phoneNumber')
          ? json['phoneNumber']
          : json['phone number'],
      notificationToken: json.containsKey('notificationToken')
          ? json['notificationToken']
          : json['notification_token'],
      totalMoneyIn: num.tryParse(json['totalMoneyIn'].toString()),
      totalMoneyOut: num.tryParse(json['totalMoneyOut'].toString()),
      coins: num.tryParse(json['coins'].toString()),
    );
  }

  static List<Customer> fromJsonList(List json) {
    List<Customer> customers =
        json?.map((customer) => Customer.fromJson(customer))?.toList();
    return customers;
  }

  Map<String, dynamic> toJson({bool received = false}) {
    Map<String, dynamic> json = {
      'phone number': phoneNumber,
      'notification_token': notificationToken,
      'totalMoneyIn': totalMoneyIn ?? 0,
      'totalMoneyOut': totalMoneyOut ?? 0,
      'coins': coins ?? 0,
    };

    return json;
  }
}
