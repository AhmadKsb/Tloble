import 'package:cloud_firestore/cloud_firestore.dart';

class MiningItem {
  String originalName;
  String name;
  String income;
  String updatedAt;
  String minableCoins;
  String price;
  String powerConsumption;

  MiningItem({
    this.originalName,
    this.name,
    this.income,
    this.updatedAt,
    this.minableCoins,
    this.price,
    this.powerConsumption,
  });

  factory MiningItem.fromJson(QueryDocumentSnapshot jsonData) {
    if (jsonData == null) return null;

    Map json = (jsonData.data() as Map);

    return MiningItem(
      originalName: json['originalName'] != null ? json['originalName'] : null,
      name: json['name'] != null ? json['name'] : null,
      income: json['income'] != null ? json['income'] : null,
      updatedAt: json['updatedAt'] != null ? json['updatedAt'] : null,
      minableCoins: json['minableCoins'] != null ? json['minableCoins'] : null,
      price: json['price'] != null ? json['price'] : null,
      powerConsumption:
          json['powerConsumption'] != null ? json['powerConsumption'] : null,
    );
  }

  static List<MiningItem> fromJsonList(List json) {
    List<MiningItem> orders =
        json?.map((driver) => MiningItem?.fromJson(driver.data()))?.toList();
    return orders;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'originalName': originalName,
      'name': name,
      'income': income,
      'updatedAt': updatedAt,
      'minableCoins': minableCoins,
      'price': price,
      'powerConsumption': powerConsumption,
    };
    return json;
  }
}
