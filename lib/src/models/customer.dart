class Customer {
  String? name;
  String? phoneNumber;
  String? notificationToken;
  num? coins;

  Customer({
    this.name,
    this.phoneNumber,
    this.notificationToken,
    this.coins,
  });

  factory Customer.fromJson(Map<dynamic, dynamic> json) {
    return Customer(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      notificationToken: json['notificationToken'],
      coins: num.tryParse(json['coins'].toString()),
    );
  }

  static List<Customer> fromJsonList(List json) {
    List<Customer>? customers =
        json.map((customer) => Customer.fromJson(customer)).toList();
    return customers;
  }

  Map<String, dynamic> toJson({bool received = false}) {
    Map<String, dynamic> json = {
      'name': name,
      'phoneNumber': phoneNumber,
      'notificationToken': notificationToken,
      'coins': coins ?? 0,
    };

    return json;
  }
}
