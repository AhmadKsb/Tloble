class Feedback {
  String? name;
  String? email;
  String? phoneNumber;
  String? feedback;
  String? dateTime;
  bool? alreadyContacted;

  Feedback({
    this.name,
    this.email,
    this.phoneNumber,
    this.feedback,
    this.dateTime,
    this.alreadyContacted = false,
  });

  factory Feedback.fromJson(Map<dynamic, dynamic> json) {

    return Feedback(
      name: json.containsKey('name') ? json['name'] : null,
      email: json.containsKey('email') ? json['email'] : null,
      phoneNumber: json.containsKey('phoneNumber') ? json['phoneNumber'] : null,
      feedback: json.containsKey('feedback') ? json['feedback'] : null,
      dateTime: json.containsKey('dateTime') ? json['dateTime'] : null,
      alreadyContacted: json.containsKey('alreadyContacted')
          ? json['alreadyContacted'] is String
              ? (json['alreadyContacted'] == "true" ? true : false)
              : json['alreadyContacted']
          : null,
    );
  }

  static List<Feedback> fromJsonList(List json) {
    List<Feedback>? feedbacks =
        json.map((feedback) => Feedback.fromJson(feedback)).toList();
    return feedbacks;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name ?? "",
      'email': email ?? "",
      'phoneNumber': phoneNumber ?? "",
      'feedback': feedback ?? "",
      'dateTime': dateTime ?? "",
      'alreadyContacted': alreadyContacted ?? "",
    };
    return json;
  }
}
