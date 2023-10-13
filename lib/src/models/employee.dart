class Driver {
  String name;
  String phoneNumber;
  num usdtOut;
  num cashOut;
  num cashIn;
  num usdtIn;
  num totalWeeklyMoneyIn;
  num totalWeeklyMoneyOut;
  String token;
  bool showLargeOrders;

  Driver({
    this.name,
    this.phoneNumber,
    this.cashIn,
    this.cashOut,
    this.usdtIn,
    this.usdtOut,
    this.token,
    this.totalWeeklyMoneyIn,
    this.totalWeeklyMoneyOut,
    this.showLargeOrders,
  });

  factory Driver.fromJson(Map<dynamic, dynamic> json) {
    return Driver(
      name: json['name'],
      phoneNumber: json['phone_number'],
      usdtOut: json['usdt_out'],
      cashOut: json['cash_out'],
      cashIn: json['cash_in'],
      usdtIn: json['usdt_in'],
      totalWeeklyMoneyIn: json['total_money_in'],
      totalWeeklyMoneyOut: json['total_money_out'],
      token: json['token'],
      showLargeOrders: json['showLargeOrders'],
    );
  }

  static List<Driver> fromJsonList(List json) {
    List<Driver> orders =
        json?.map((driver) => Driver.fromJson(driver.data()))?.toList();
    return orders;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'phone_number': phoneNumber,
      'usdt_out': usdtOut,
      'cash_out': cashOut,
      'cash_in': cashIn,
      'usdt_in': usdtIn,
      'total_money_in': totalWeeklyMoneyIn,
      'total_money_out': totalWeeklyMoneyOut,
      'token': token,
      'showLargeOrders': showLargeOrders,
    };
    return json;
  }
}
