class Signals {
  String id;
  String firstname;
  String lastname;
  List<dynamic> usedtxnId;
  String startDate;
  String endDate;
  int paygroup;

  Signals({
    this.id,
    this.firstname,
    this.lastname,
    this.usedtxnId,
    this.startDate,
    this.endDate,
    this.paygroup,
  });

  factory Signals.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) return null;

    return Signals(
      id: json.containsKey('_id') ? json['_id'] : null,
      firstname: json.containsKey('firstname') ? json['firstname'] : null,
      lastname: json.containsKey('lastname') ? json['lastname'] : null,
      usedtxnId: json.containsKey('usedtxId') ? json['usedtxId'] : null,
      startDate: json.containsKey('startDate') ? json['startDate'] : null,
      endDate: json.containsKey('endDate') ? json['endDate'] : null,
      paygroup: json.containsKey('paygroup') ? json['paygroup'] : null,
    );
  }

  static List<Signals> fromJsonList(List json) {
    List<Signals> signals =
        json?.map((signal) => Signals.fromJson(signal))?.toList();
    return signals;
  }

  Map<String, dynamic> toJson({bool received = false}) {
    Map<String, dynamic> json = {
      '_id': id,
      'firstname': firstname?.toString(),
      'lastname': lastname,
      'usedtxId': usedtxnId,
      'startDate': startDate?.toString(),
      'endDate': endDate?.toString(),
      'paygroup': paygroup,
    };

    return json;
  }
}
