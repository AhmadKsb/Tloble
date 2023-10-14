class Employee {
  String? name;
  String? phoneNumber;
  String? token;

  Employee({
    this.name,
    this.phoneNumber,
    this.token,
  });

  factory Employee.fromJson(Map<dynamic, dynamic> json) {
    return Employee(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      token: json['token'],
    );
  }

  static List<Employee> fromJsonList(List json) {
    List<Employee>? orders =
        json.map((driver) => Employee.fromJson(driver.data())).toList();
    return orders;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'phoneNumber': phoneNumber,
      'token': token,
    };
    return json;
  }
}
