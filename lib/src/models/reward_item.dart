import 'package:cloud_firestore/cloud_firestore.dart';

class RewardItem {
  String originalName;
  String name;
  String coinsNeeded;
  String updatedAt;

  RewardItem({
    this.originalName,
    this.name,
    this.coinsNeeded,
    this.updatedAt,
  });

  factory RewardItem.fromJson(QueryDocumentSnapshot jsonData) {
    if (jsonData == null) return null;

    Map json = (jsonData.data() as Map);

    return RewardItem(
      originalName: json['originalName'] != null ? json['originalName'] : null,
      name: json['name'] != null ? json['name'] : null,
      updatedAt: json['updatedAt'] != null ? json['updatedAt'] : null,
      coinsNeeded: json['coinsNeeded'] != null ? json['coinsNeeded'] : null,
    );
  }

  static List<RewardItem> fromJsonList(List json) {
    List<RewardItem> orders =
        json?.map((driver) => RewardItem?.fromJson(driver.data()))?.toList();
    return orders;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'originalName': originalName,
      'name': name,
      'updatedAt': updatedAt,
      'coinsNeeded': coinsNeeded,
    };
    return json;
  }
}
