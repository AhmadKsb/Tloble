class BinanceTransactions {
  String? amount;
  String? coin;
  String? network;
  int? status;
  String? address;
  String? txId;

  BinanceTransactions({
    this.amount,
    this.coin,
    this.network,
    this.status,
    this.address,
    this.txId,
  });

  factory BinanceTransactions.fromJson(Map<dynamic, dynamic> json) {

    return BinanceTransactions(
      amount: json.containsKey('amount') ? json['amount'] : null,
      coin: json.containsKey('coin') ? json['coin'] : null,
      network: json.containsKey('network') ? json['network'] : null,
      status: json.containsKey('status') ? json['status'] : null,
      address: json.containsKey('address') ? json['address'] : null,
      txId: json.containsKey('txId') ? json['txId'] : null,
    );
  }

  static List<BinanceTransactions> fromJsonList(List json) {
    List<BinanceTransactions>? transactions = json
        .map((transaction) => BinanceTransactions.fromJson(transaction))
        .toList();
    return transactions;
  }
}
