class CryptoCurrency {
  String symbol;
  String price;

  CryptoCurrency({
    this.symbol,
    this.price,
  });

  factory CryptoCurrency.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) return null;

    return CryptoCurrency(
      symbol: json.containsKey('symbol') ? json['symbol'] : null,
      price: json.containsKey('price') ? json['price'] : null,
    );
  }

  static List<CryptoCurrency> fromJsonList(List json) {
    List<CryptoCurrency> cryptocurrencies = json
        ?.map((cryptocurrency) => CryptoCurrency.fromJson(cryptocurrency))
        ?.toList();
    return cryptocurrencies;
  }
}
