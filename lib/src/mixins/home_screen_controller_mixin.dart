import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/models/customer.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ecommerce_app/src/models/employee.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A mixin that exposes a method to update a currency list on the Flutter Layer
/// side.
mixin HomeScreenControllerMixin {
  HomeScreenController homeScreenController = HomeScreenController(
    {},
    null,
    {},
  );

  List<Employee> employeesList = [];

  SharedPreferences? prefs;
  String? notificationToken;
  late PageState homeScreenControllerState;

  Customer? customer;

  /// Loads the controller
  Future<void> loadHomeScreenController() async {
    homeScreenControllerState = PageState.loading;
    homeScreenController.refreshView();

    prefs = await SharedPreferences.getInstance();
    await homeScreenController.getSharedPreferences();

    homeScreenController.getUpdatedCart();

    String? activateNotification = prefs?.getString('tloble_notification');

    if (activateNotification == null || activateNotification != 'activate') {
      FirebaseMessaging.instance.subscribeToTopic('tloble_notification');
      prefs?.setString(
        'tloble_notification',
        'activate',
      );
    }

    try {
      List data = await Future.wait(
        [
          FirebaseFirestore.instance
              .collection('app info')
              .get(const GetOptions(source: Source.server)),
          PackageInfo.fromPlatform(),
          FirebaseMessaging.instance.getToken(),
          SharedPreferences.getInstance(),
          FirebaseFirestore.instance
              .collection('Employees')
              .get(const GetOptions(source: Source.server)),
          if (isNotEmpty(FirebaseAuth.instance.currentUser?.phoneNumber))
            FirebaseFirestore.instance
                .collection('Customers')
                .doc(FirebaseAuth.instance.currentUser?.phoneNumber ?? '')
                .get(const GetOptions(source: Source.server)),
        ],
      );

      var employeesDocs = (data[4] as QuerySnapshot).docs;
      employeesList = Employee.fromJsonList(employeesDocs);
      homeScreenController.employees = employeesList;

      if (isNotEmpty(FirebaseAuth.instance.currentUser?.phoneNumber)) {
        customer = Customer.fromJson(
            (data[5] as DocumentSnapshot).data() == null
                ? null
                : data[5].data());
        homeScreenController.customer = customer;
      }

      homeScreenController.fillFieldsFromData(
          appInfoSnapshott: ((data[0] as QuerySnapshot)
              .docs
              .firstWhere((document) => document.id == 'app')).data());

      prefs?.setStringList(
        'tloble_feedback_receivers',
        List<String>.from(homeScreenController.feedbackReceiversList
                ?.where((element) => true) ??
            []),
      );

      prefs?.setStringList(
        'tloble_employees',
        List<String>.from(
            homeScreenController.employeesList?.where((element) => true) ?? []),
      );

      notificationToken = data[2];

      homeScreenController.versionNumber = data[1]?.version ?? '';
      homeScreenController.buildNumber = data[1]?.buildNumber ?? '';
      homeScreenController.version =
          (homeScreenController.versionNumber ?? "") +
              '+' +
              (homeScreenController.buildNumber ?? "");
      print("App version: ${homeScreenController.version}");

      homeScreenControllerState = PageState.loaded;
      homeScreenController.refreshView();
    } catch (e) {
      print(e);

      homeScreenControllerState = PageState.error;
      homeScreenController.refreshView();
    }
  }

  void setHomeScreenControllerView(HomeScreenControllerView view) {
    homeScreenController.setView(view);
  }
}
