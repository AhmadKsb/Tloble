// import 'dart:async';
// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:country_pickers/utils/utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flare_flutter/flare_actor.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:highlighter_coachmark/highlighter_coachmark.dart';
// import 'package:location/location.dart';
// import 'package:marquee_text/marquee_text.dart';
// import 'package:package_info/package_info.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:store_redirect/store_redirect.dart';
// import 'package:vibration/vibration.dart';
// import 'package:wkbeast/authentication/login.dart';
// import 'package:wkbeast/contact_us/contact_us_screen.dart';
// import 'package:wkbeast/localization/localization.dart';
// import 'package:wkbeast/main.dart';
// import 'package:wkbeast/models/customer.dart';
// import 'package:wkbeast/models/driver.dart';
// import 'package:wkbeast/my_orders/my_orders_screen.dart';
// import 'package:wkbeast/screens/feedback/feedback_list_screen.dart';
// import 'package:wkbeast/screens/feedback/send_us_your_feedbacks_screen.dart';
// import 'package:wkbeast/screens/home/maps_screen.dart';
// import 'package:wkbeast/screens/home/minimum_order_bottomsheet.dart';
// import 'package:wkbeast/screens/home/send_notification_bottomsheet.dart';
// import 'package:wkbeast/screens/home/unban_user_bottomsheet.dart';
// import 'package:wkbeast/screens/orders/all_large_orders_screen.dart';
// import 'package:wkbeast/screens/orders/all_small_orders_screen.dart';
// import 'package:wkbeast/screens/rates/rates_screen.dart';
// import 'package:wkbeast/screens/rewards/rewards_screen.dart';
// import 'package:wkbeast/screens/salaries/salaries_screen.dart';
// import 'package:wkbeast/screens/signals/signals_screen.dart';
// import 'package:wkbeast/services/mongodb_service.dart';
// import 'package:wkbeast/utils/BottomSheets/bottom_sheet_helper.dart';
// import 'package:wkbeast/utils/BottomSheets/operation_status.dart';
// import 'package:wkbeast/utils/Dropdown/dropdown_search.dart';
// import 'package:wkbeast/utils/UBScaffold/page_state.dart';
// import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';
// import 'package:wkbeast/utils/buttons/raised_button.dart';
// import 'package:wkbeast/utils/buttons/switch.dart';
// import 'package:wkbeast/utils/buttons/toggle_button.dart';
// import 'package:wkbeast/utils/custom_alert_dialog.dart';
// import 'package:wkbeast/utils/custom_base_dialog.dart';
// import 'package:wkbeast/utils/keyboard_actions_form.dart';
// import 'package:wkbeast/utils/string_util.dart';
// import 'package:wkbeast/utils/util.dart';
// import 'package:wkbeast/utils/wk_text_field.dart';
// import 'package:wkbeast/widgets/firebase_notification.dart';
//
// import '../../controllers/home_screen_controller.dart';
// import '../../models/order.dart';
// import '../balances/balances_screen.dart';
// import '../history/history_screen.dart';
// import '../mining/mining_screen.dart';
// import 'add_city_bottomsheet.dart';
// import 'add_crypto_coin.dart';
// import 'add_to_ahmad_salary.dart';
// import 'ban_user_bottomsheet.dart';
// import 'check_customer_balance_bottomsheet.dart';
// import 'modify_coins_bottomsheet.dart';
// import 'new_driver_bottomsheet.dart';
//
// class HomeScreen extends StatefulWidget {
//   final User user;
//
//   HomeScreen({Key key, this.user}) : super(key: key);
//   static const String route = '/home';
//
//   static void restartApp(BuildContext context) {
//     context.findAncestorStateOfType<_HomeScreenState>().restartApp();
//   }
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   AppLifecycleState appState = AppLifecycleState.resumed;
//   bool requestTimerRunning = false;
//
//   var scaffoldKey = GlobalKey<ScaffoldState>();
//   final TextEditingController _nameController = TextEditingController(),
//       _amountController = TextEditingController(),
//       _moreDetailsController = TextEditingController();
//
//   FocusNode nameNode = new FocusNode(),
//       amountNode = new FocusNode(),
//       moreDetailsNode = new FocusNode();
//
//   bool locationEnabled,
//       shareLocation = true,
//       isBuy = true,
//       isLoading = false,
//       isDriver = false,
//       isButtonLoading = false,
//       showLargeOrders = false,
//       checkboxValue = false;
//
//   SharedPreferences prefs;
//
//   num rate = 1;
//   var refreshKey = GlobalKey<RefreshIndicatorState>();
//   bool _isRefreshing = false;
//   GlobalKey _drawerKey = GlobalObjectKey("drawerKey"); // used by FAB
//
//   var location = new Location();
//   String amount,
//       versionNumber,
//       buildNumber,
//       version,
//       errorMessage,
//       notificationToken,
//       newsText = "";
//   int amountWithFee, amountWithoutFee;
//   LocationData currentLocation;
//   PageState _state;
//   Driver selectedDriver;
//   List<Driver> driversList = [];
//   List<String> adminPanelNames = [];
//   List<String> managementNames = [];
//   List<String> towns;
//   String selectedCity;
//   Timer _timer;
//   Timer _loadTimer;
//
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   HomeScreenController _controller;
//   Customer customer;
//   String selectedCountryPhoneCode;
//   String selectedCountryIsoCode;
//
//   Key key = UniqueKey();
//
//   void restartApp() {
//     setState(() {
//       key = UniqueKey();
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     if (!mounted) return;
//     WidgetsBinding.instance.addObserver(this);
//     _load();
//   }
//
//   Future<void> _load() async {
//     //textDirection: textDirection ??
//     //           (Localizations.localeOf(context).languageCode == 'ar')
//     //               ? TextDirection.rtl
//     //               : TextDirection.ltr),
//
//     setState(() {
//       _state = PageState.loading;
//     });
//     // Intl.defaultLocale = "ar";
//     // await Localization(Locale("ar")).load();
//
//     prefs = await SharedPreferences.getInstance();
//     String activateNotification = prefs.getString('swiftShop_notification');
//     selectedCountryPhoneCode = prefs.getString('swiftShop_phoneCode');
//     selectedCountryIsoCode = prefs.getString('swiftShop_isoCode');
//
//     if (activateNotification == null || activateNotification != 'activated') {
//       FirebaseMessaging.instance.subscribeToTopic('notifications');
//       prefs.setString(
//         'swiftShop_notification',
//         'activated',
//       );
//     }
//
//     try {
//       List data = await Future.wait(
//       [
//       FirebaseFirestore.instance.collection('app info').snapshots().first,
//           PackageInfo.fromPlatform(),
//     FirebaseMessaging.instance.getToken(),
//     SharedPreferences.getInstance(),
//     if (isN`otEmpty(widget.user?.phoneNumber))
//     FirebaseFirestore.instance
//         .collection('customers')
//         .doc(widget.user?.phoneNumber ?? '')
//         .snapshots()
//         .first
//     ],
//     );
//
//     if (isNotEmpty(widget.user?.phoneNumber))
//     customer = Customer.fromJson(
//     (data[4] as DocumentSnapshot).data() == null
//     ? null
//         : data[4].data());
//
//     _controller = HomeScreenController(
//     ((data[0] as QuerySnapshot)
//         .docs
//         .firstWhere((document) => document.id == 'rates')).data(),
//     ((data[0] as QuerySnapshot)
//         .docs
//         .firstWhere((document) => document.id == 'app')).data(),
//     ((data[0] as QuerySnapshot)
//         .docs
//         .firstWhere((document) => document.id == 'sell rates')).data(),
//     );
//
//     if (_controller?.showCryptoCurrencyNews ?? false)
//     await _getCryptocurrencies();
//
//     if (_controller?.shouldLoadAgainAfterTimer ?? false) _loadAgain();
//
//     prefs.setStringList(
//     'swiftShop_drivers',
//     List<String>.from(
//     _controller.driversDrawerList.where((element) => true)),
//     );
//
//     prefs.setStringList(
//     'swiftShop_feedback_receivers',
//     List<String>.from(
//     _controller.feedbackReceiversList.where((element) => true)),
//     );
//
//     isDriver = _controller.driversDrawerList
//         .contains(widget.user?.phoneNumber ?? '');
//
//     if (_controller?.isAdmin ?? false || isDriver) {
//     List data2 = await Future.wait(
//     [
//     FirebaseFirestore.instance.collection('drivers').snapshots().first,
//     ],
//     );
//     var driversDocs = (data2[0] as QuerySnapshot).docs;
//     driversDocs.sort((a, b) => (a['name']).compareTo(b['name']));
//     driversList = Driver.fromJsonList(driversDocs);
//     _controller.driversList = driversList;
//     showLargeOrders = driversList
//         .firstWhere((driver) =>
//     driver.phoneNumber == widget.user?.phoneNumber ?? '')
//         .showLargeOrders;
//     }
//
//     notificationToken = data[2];
//
//     versionNumber = data[1]?.version ?? '';
//     buildNumber = data[1]?.buildNumber ?? '';
//     version = versionNumber + '+' + buildNumber;
//     print("App version: $version");
//
//     checkForUpdate();
//
//     _buildAdminPanelWidgets();
//     _buildCoachMarkCampaign(prefs);
//
//     setState(() {
//     _state = PageState.loaded;
//     });
//     } catch (e) {
//     print(e);
//     setState(() {
//     _state = PageState.error;
//     });
//     }
//
//     locationEnabled = await location.serviceEnabled();
//     if (!locationEnabled) {
//     await location.requestService();
//     locationEnabled = await location.serviceEnabled();
//     }
//     if (locationEnabled) {
//     try {
//     currentLocation = await location.getLocation();
//     } catch (e) {
//     print(e);
//     }
//     }
//   }
//
//   Future<void> _loadAgain() async {
//     _loadTimer =
//         Timer(Duration(minutes: _controller.loadUpdateDuration), () async {
//           try {
//             cancelLoadTimer();
//             await _load();
//           } catch (e) {
//             cancelLoadTimer();
//             await _load();
//             print("Error ${e.toString()}");
//           }
//         });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     nameNode?.dispose();
//     amountNode?.dispose();
//     moreDetailsNode?.dispose();
//     _timer?.cancel();
//     _loadTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> refresh() async {
//     if (_isRefreshing) return;
//     _isRefreshing = true;
//     _load();
//     _isRefreshing = false;
//     setState(() {
//       refreshKey = GlobalKey<RefreshIndicatorState>();
//     });
//   }
//
//   void _buildCoachMarkCampaign(SharedPreferences prefs) {
//     if (_controller.showCoachMark) {
//       String coachMark = _controller.coachMarkCampaign ?? '';
//       String showCoachMarkCampaign = prefs.getString(coachMark);
//
//       if (showCoachMarkCampaign == null ||
//           showCoachMarkCampaign != 'alreadyshown') {
//         WidgetsBinding.instance.addPostFrameCallback(
//               (_) {
//             CoachMark coachMarkTile = CoachMark();
//             RenderBox target = _drawerKey?.currentContext?.findRenderObject();
//
//             Rect markRect = target.localToGlobal(Offset.zero) & target.size;
//             markRect = markRect.inflate(5.0);
//
//             coachMarkTile.show(
//               targetContext: _drawerKey.currentContext,
//               markRect: markRect,
//               markShape: BoxShape.rectangle,
//               onClose: () {
//                 if (_controller.showCampaignOnLaunch) {
//                   String campaignName = _controller.campaignName ?? '';
//                   String showCampaign = prefs.getString(campaignName);
//
//                   if (showCampaign == null || showCampaign != 'alreadyshown') {
//                     showCampaignDialog();
//                     prefs.setString(
//                       campaignName,
//                       'alreadyshown',
//                     );
//                   }
//                 }
//               },
//               children: [
//                 Center(
//                   child: Text(
//                     (Localizations.localeOf(context).languageCode == 'ar')
//                         ? _controller.coachMarkTextAR
//                         : _controller.coachMarkText,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 24.0,
//                       fontStyle: FontStyle.italic,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//               duration: null,
//             );
//           },
//         );
//         prefs.setString(
//           coachMark,
//           'alreadyshown',
//         );
//       } else {
//         if (_controller.showCampaignOnLaunch) {
//           String campaignName = _controller.campaignName ?? '';
//           String showCampaign = prefs.getString(campaignName);
//
//           if (showCampaign == null || showCampaign != 'alreadyshown') {
//             showCampaignDialog();
//             prefs.setString(
//               campaignName,
//               'alreadyshown',
//             );
//           }
//         }
//       }
//     } else {
//       if (_controller.showCampaignOnLaunch) {
//         String campaignName = _controller.campaignName ?? '';
//         String showCampaign = prefs.getString(campaignName);
//
//         if (showCampaign == null || showCampaign != 'alreadyshown') {
//           showCampaignDialog();
//           prefs.setString(
//             campaignName,
//             'alreadyshown',
//           );
//         }
//       }
//     }
//   }
//
//   void _buildAdminPanelWidgets() {
//     adminPanelNames = [];
//     managementNames = [];
//
//     if (_controller?.isAdmin ?? false)
//       adminPanelNames
//         ..addAll(
//           [
//             Localization.of(context, 'orders'),
//             Localization.of(context, 'large_orders'),
//             Localization.of(context, 'balances'),
//             Localization.of(context, 'salaries'),
//             if (_controller?.showAddToAhmadSalary ?? false)
//               Localization.of(context, 'add_to_ahmads_salary'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'add_city'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'add_cryptocurrency'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'minimum_order'),
//             Localization.of(context, 'add_coins'),
//             Localization.of(context, 'send_notification'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'ban_user'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'unban_user'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'add_driver'),
//             if (_controller?.showMisc ?? false)
//               Localization.of(context, 'kick_driver'),
//           ],
//         );
//
//     managementNames
//       ..addAll(
//         [
//           if (isDriver ||
//               ((_controller?.isAdmin ?? false) ||
//                   (_controller?.allowedToCheckCustomersBalance ?? false)))
//             Localization.of(context, 'rates'),
//           if (isDriver) Localization.of(context, 'map'),
//           if (isDriver) Localization.of(context, 'orders'),
//           if (_controller?.showLargeOrders)
//             Localization.of(context, 'large_orders'),
//           if (isDriver || (_controller?.isAdmin ?? false))
//             Localization.of(context, 'history'),
//           if (_controller?.feedbackReceiver)
//             Localization.of(context, 'feedbacks'),
//           if ((_controller?.allowedToCheckCustomersBalance ?? false) ||
//               ((_controller?.isAdmin ?? false)))
//             Localization.of(context, 'check_customers_coins'),
//         ],
//       );
//   }
//
//   dynamic getManagementListTileWidget(String listTileName) async {
//     if (listTileName == Localization.of(context, 'rates')) {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => RatesScreen(controller: _controller),
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'large_orders')) {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LargeOrdersScreen(controller: _controller),
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'balances')) {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BalancesScreen(controller: _controller),
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'salaries')) {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SalariesScreen(),
//         ),
//       );
//     } else if (listTileName ==
//         Localization.of(context, 'add_to_ahmads_salary')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: AddToAhmadSalaryBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'add_city')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: AddCityBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'add_cryptocurrency')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: AddCryptoCurrencyBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'minimum_order')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 16.0,
//                 ),
//                 child: Icon(
//                   Icons.close,
//                   color: Colors.black,
//                   size: 25,
//                 ),
//               ),
//               onTap: () {
//                 setState(() {
//                   return isButtonLoading ? null : Navigator.of(context).pop();
//                 });
//               },
//             ),
//           ],
//         ),
//         body: MinimumOrderBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'add_coins')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.45,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: ModifyCoinsBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName ==
//         Localization.of(context, 'check_customers_coins')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 16.0,
//                 ),
//                 child: Icon(
//                   Icons.close,
//                   color: Colors.black,
//                   size: 25,
//                 ),
//               ),
//               onTap: () {
//                 setState(() {
//                   return isButtonLoading ? null : Navigator.of(context).pop();
//                 });
//               },
//             ),
//           ],
//         ),
//         body: CheckCustomerBalanceBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {},
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'send_notification')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: SendNotificationBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {},
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'ban_user')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: BanUserBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'unban_user')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: UnbanUserBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'add_driver')) {
//       showBottomsheet(
//         context: context,
//         height: MediaQuery.of(context).size.height * 0.4,
//         dismissOnTouchOutside: false,
//         isScrollControlled: true,
//         upperWidget: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             GestureDetector(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 16.0,
//                   ),
//                   child: Icon(
//                     Icons.close,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     return isButtonLoading ? null : Navigator.of(context).pop();
//                   });
//                 })
//           ],
//         ),
//         body: NewDriverBottomsheet(
//           controller: _controller,
//           isBottomSheetLoading: (isLoad) {
//             setState(() {
//               isButtonLoading = isLoad;
//             });
//           },
//           changed: (hasChanged) {
//             if (hasChanged) {
//               _load();
//             }
//           },
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'kick_driver')) {
//       showBottomSheetList<Driver>(
//         context: context,
//         title: Localization.of(context, 'kick_driver'),
//         items: driversList,
//         itemBuilder: (driver) {
//           return ListTile(
//             title: Text(
//               "${driver.name ?? ''}",
//             ),
//           );
//         },
//         itemHeight: 50,
//         onItemSelected: (driver) async {
//           FocusManager.instance.primaryFocus?.unfocus();
//           scaffoldKey.currentState.openDrawer();
//           await Navigator.of(context).pop();
//           await showConfirmationBottomSheet(
//             context: context,
//             flare: 'assets/flare/pending.flr',
//             title: replaceVariable(
//               Localization.of(
//                 context,
//                 'are_you_sure_you_want_to_kick',
//               ),
//               'value',
//               driver.name,
//             ),
//             confirmMessage: Localization.of(context, 'confirm'),
//             confirmAction: () async {
//               setState(() {
//                 _state = PageState.loading;
//               });
//               try {
//                 List<dynamic> newDriversList = _controller.driversDrawerList;
//                 newDriversList
//                     .removeWhere((element) => element == driver.phoneNumber);
//
//                 await Navigator.of(context).pop();
//
//                 await Future.wait([
//                   FirebaseFirestore.instance
//                       .collection('app info')
//                       .doc('app')
//                       .update({
//                     'drivers': newDriversList,
//                   }),
//                   FirebaseFirestore.instance
//                       .collection('drivers')
//                       .doc(driver.phoneNumber)
//                       .delete(),
//                 ]);
//                 _load();
//               } catch (e) {
//                 await Navigator.of(context).pop();
//                 showErrorBottomsheet(e.toString());
//                 setState(() {
//                   _state = PageState.error;
//                 });
//               }
//             },
//             cancelMessage: Localization.of(context, 'cancel'),
//           );
//         },
//       );
//     } else if (listTileName == Localization.of(context, 'history')) {
//       if (_controller.isAdmin &&
//           driversList.isNotEmpty &&
//           (driversList != null)) {
//         showBottomSheetList<Driver>(
//           context: context,
//           title: Localization.of(context, 'select_a_driver'),
//           items: driversList,
//           itemBuilder: (driver) {
//             return ListTile(
//               title: Text(
//                 "${driver.name ?? ''}",
//               ),
//             );
//           },
//           itemHeight: 60,
//           onItemSelected: (driver) async {
//             selectedDriver = driver;
//             FocusManager.instance.primaryFocus?.unfocus();
//             scaffoldKey.currentState.openDrawer();
//             await Navigator.of(context).pop();
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HistoryScreen(
//                   controller: _controller,
//                   selectedPhoneNumber: driver?.phoneNumber?.trim(),
//                 ),
//               ),
//             );
//           },
//         );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HistoryScreen(
//               controller: _controller,
//             ),
//           ),
//         );
//       }
//     } else if (listTileName == Localization.of(context, 'feedbacks')) {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => FeedbackListScreen(controller: _controller),
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'map')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MapsScreen(
//             controller: _controller,
//           ),
//         ),
//       );
//     } else if (listTileName == Localization.of(context, 'orders')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SmallOrdersScreen(
//             controller: _controller,
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     appState = state;
//
//     if (state == AppLifecycleState.resumed) {
//       if (!requestTimerRunning) _getUpdateCryptocurrencies();
//     }
//   }
//
//   Future<void> _getUpdateCryptocurrencies() async {
//     _timer = Timer(Duration(seconds: _controller.newsUpdateDuration), () async {
//       try {
//         if (appState == AppLifecycleState.resumed) {
//           cancelTimer();
//           await _getCryptocurrencies();
//         } else {
//           cancelTimer();
//         }
//       } catch (e) {
//         cancelTimer();
//         _getUpdateCryptocurrencies();
//         print("Error ${e.toString()}");
//       }
//     });
//     requestTimerRunning = true;
//   }
//
//   void cancelTimer() {
//     _timer.cancel();
//     requestTimerRunning = false;
//   }
//
//   void cancelLoadTimer() {
//     _loadTimer.cancel();
//     requestTimerRunning = false;
//   }
//
//   String getCryptoCurrencyStringFixed(String cryptoCurrency, int decimals) =>
//       num.tryParse(cryptoCurrency)?.toStringAsFixed(decimals);
//
//   Future<void> _getCryptocurrencies() async {
//     var cryptoCurrencies = await MongoDBService()
//         .getAllCryptoCurrencies(_controller?.cryptoCurrencies);
//     newsText = "";
//     for (int i = 0; i < cryptoCurrencies.length; i++) {
//       var splitCryptoCurrencySymbol = cryptoCurrencies[i]
//           .symbol
//           ?.toLowerCase()
//           ?.split(_controller.mainCurrency?.toLowerCase());
//       var cryptoCurrencyPrice = num.tryParse(cryptoCurrencies[i].price.substring(0, 1)) >
//           0
//           ? getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 2)
//           : num.tryParse(getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 3)
//           ?.substring(
//           getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 3).length -
//               1,
//           getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 3)
//               ?.length)) >
//           1
//           ? getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 3)
//           : num.tryParse(getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 4).substring(
//           getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 4)
//               .length -
//               1,
//           getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 4)
//               .length)) >
//           1
//           ? getCryptoCurrencyStringFixed(cryptoCurrencies[i].price, 4)
//           : num.tryParse(cryptoCurrencies[i].price).toString();
//       newsText += (splitCryptoCurrencySymbol[0]?.toUpperCase() ?? "") +
//           "/" +
//           _controller.mainCurrency +
//           ": \$" +
//           cryptoCurrencyPrice +
//           "    ";
//     }
//     _getUpdateCryptocurrencies();
//     setState(() {});
//   }
//
//   void showCampaignDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           elevation: 8.0,
//           contentPadding: EdgeInsets.all(18.0),
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(),
//                   GestureDetector(
//                     child: Padding(
//                       padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
//                       child: Icon(
//                         Icons.close,
//                         color: Colors.black,
//                         size: 25,
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//               Container(
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
//                   child: Text(
//                     (Localizations.localeOf(context).languageCode == 'ar')
//                         ? _controller.campaignContentsAR.replaceAll("\\n", "\n")
//                         : _controller.campaignContents.replaceAll("\\n", "\n"),
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void checkForUpdate() {
//     List<String> versionSplitAtPlus = version.split('+');
//     List<String> versionSplitAtDot = versionSplitAtPlus[0].split('.');
//     String currentVersion = versionSplitAtDot[0] +
//         versionSplitAtDot[1] +
//         versionSplitAtDot[2] +
//         versionSplitAtPlus[1];
//
//     if (_controller.forceUpdate ?? false) {
//       if (Theme.of(context).platform == TargetPlatform.iOS) {
//         List<String> iosVersionSplitAtPlus =
//         _controller.iosAppVersion.split('+');
//         List<String> iosVersionSplitAtDot = iosVersionSplitAtPlus[0].split('.');
//         String consoleString = iosVersionSplitAtDot[0] +
//             iosVersionSplitAtDot[1] +
//             iosVersionSplitAtDot[2] +
//             iosVersionSplitAtPlus[1];
//         if (num.parse(consoleString) > num.parse(currentVersion))
//           showUpdateBottomSheet(
//             Localization.of(context, 'newer_version_available'),
//           );
//       } else {
//         List<String> androidVersionSplitAtPlus =
//         _controller.androidAppVersion.split('+');
//         List<String> androidVersionSplitAtDot =
//         androidVersionSplitAtPlus[0].split('.');
//         String consoleString = androidVersionSplitAtDot[0] +
//             androidVersionSplitAtDot[1] +
//             androidVersionSplitAtDot[2] +
//             androidVersionSplitAtPlus[1];
//         if (num.parse(consoleString) > num.parse(currentVersion))
//           showUpdateBottomSheet(
//             Localization.of(context, 'newer_version_available'),
//           );
//       }
//     }
//   }
//
//   int getCoinsCharsCount() => customer?.coins != null
//       ? ((customer?.coins?.toStringAsFixed(2)?.split('.')[0]?.length) ?? 0)
//       : 0;
//
//   @override
//   Widget build(BuildContext context) {
//     // Localization(Locale("ar"));
//     // Intl.defaultLocale = Locale("ar").toString();
//     // HomeScreen.of(context).setLocale(Locale.fromSubtags(languageCode: 'en'));
//
//     return KeyedSubtree(
//       key: key,
//       child: Scaffold(
//         key: scaffoldKey,
//         drawerEnableOpenDragGesture: false,
//         // floatingActionButton: FloatingActionButton(
//         //     onPressed: () {
//         //       PaymentCard card = PaymentCard(
//         //         'Ahmad Kassabieh',
//         //         '4242424242424242',
//         //         '100',
//         //         '12',
//         //         '2025',
//         //       );
//         //
//         //       CheckoutPayment payment = CheckoutPayment();
//         //
//         //       payment.makePayment(card, 1000);
//         //     },
//         //     tooltip: "Increment",
//         //     child: Icon(Icons.payment)),
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: <Widget>[
//               SizedBox(
//                 height: 64,
//               ),
//               // ListTile(
//               //   title: Text(
//               //     'Payment',
//               //   ),
//               //   onTap: () {
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(
//               //         builder: (context) => PaymentScreen(
//               //           controller: _controller,
//               //         ),
//               //       ),
//               //     );
//               //   },
//               // ),
//               if (_controller?.isAdmin ?? false)
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'admin_panel'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     showBottomSheetList<String>(
//                       context: context,
//                       title: Localization.of(context, 'select_an_item'),
//                       items: adminPanelNames,
//                       itemBuilder: (listTileName) {
//                         return ListTile(
//                           title: Text(
//                             "${listTileName ?? ''}",
//                           ),
//                         );
//                       },
//                       itemHeight: 60,
//                       onItemSelected: (listTileName) async {
//                         await Navigator.of(context).pop();
//                         getManagementListTileWidget(listTileName);
//                       },
//                     );
//                   },
//                 ),
//               if (isDriver ||
//                   ((_controller?.isAdmin ?? false) ||
//                       (_controller?.allowedToCheckCustomersBalance ?? false)))
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'management'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     showBottomSheetList<String>(
//                       context: context,
//                       title: Localization.of(context, 'select_an_item'),
//                       items: managementNames,
//                       itemBuilder: (listTileName) {
//                         return ListTile(
//                           title: Text(
//                             "${listTileName ?? ''}",
//                           ),
//                         );
//                       },
//                       itemHeight: 60,
//                       onItemSelected: (listTileName) async {
//                         await Navigator.of(context).pop();
//                         getManagementListTileWidget(listTileName);
//                       },
//                     );
//                   },
//                 ),
//               if ((_controller?.isAdmin ?? false) ||
//                   (_controller?.allowedPeopleToAddOrRemoveMiningItems?.contains(
//                       FirebaseAuth.instance.currentUser?.phoneNumber) ??
//                       false) ||
//                   (_controller?.showMiningListTile ?? false))
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'mining'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     if ((_controller?.isAdmin ?? false) ||
//                         (_controller?.allowedPeopleToAddOrRemoveMiningItems
//                             ?.contains(FirebaseAuth
//                             .instance.currentUser?.phoneNumber) ??
//                             false) ||
//                         (_controller?.isMiningEnabled ?? false)) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => MiningScreen(
//                             controller: _controller,
//                           ),
//                         ),
//                       );
//                     } else {
//                       showConfirmationBottomSheet(
//                         context: context,
//                         flare: 'assets/flare/pending.flr',
//                         title: (Localizations.localeOf(context).languageCode ==
//                             'ar')
//                             ? _controller.miningDisabledMessageAR
//                             : _controller.miningDisabledMessage,
//                         confirmMessage: Localization.of(context, "close"),
//                         confirmAction: () async {
//                           Navigator.of(context).pop();
//                         },
//                       );
//                     }
//                   },
//                 ),
//               if ((_controller?.isAdmin ?? false) ||
//                   (_controller?.allowedPeopleToAddOrRemoveRewardItems?.contains(
//                       FirebaseAuth.instance.currentUser?.phoneNumber) ??
//                       false) ||
//                   (_controller?.showRewardsListTile ?? false))
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'rewards'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () async {
//                     if ((_controller?.isAdmin ?? false) ||
//                         (_controller?.allowedPeopleToAddOrRemoveRewardItems
//                             ?.contains(FirebaseAuth
//                             .instance.currentUser?.phoneNumber) ??
//                             false) ||
//                         (_controller?.isRewardsEnabled ?? false)) {
//                       bool shouldRefresh = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => RewardsScreen(
//                             controller: _controller,
//                             customer: customer,
//                           ),
//                         ),
//                       );
//                       if ((shouldRefresh != null) && shouldRefresh) {
//                         _load();
//                       }
//                     } else {
//                       showConfirmationBottomSheet(
//                         context: context,
//                         flare: 'assets/flare/pending.flr',
//                         title: (Localizations.localeOf(context).languageCode ==
//                             'ar')
//                             ? _controller.rewardsDisabledMessageAR
//                             : _controller.rewardsDisabledMessage,
//                         confirmMessage: Localization.of(context, "close"),
//                         confirmAction: () async {
//                           Navigator.of(context).pop();
//                         },
//                       );
//                     }
//                   },
//                 ),
//               if (_controller?.showMyOrdersListTile ?? false)
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'my_orders'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MyOrdersScreen(
//                           controller: _controller,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               if (_controller?.showTelegramListTile ?? false)
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'join_our_signals_group'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SignalsScreen(
//                           controller: _controller,
//                           showOverview: true,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               if ((widget.user?.phoneNumber != null &&
//                   (_controller?.showSendUsYourFeedbacks ?? false)) ||
//                   (_controller?.feedbackReceiver ?? false))
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'send_us_your_feedbacks'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => FeedbackScreen(
//                           controller: _controller,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ListTile(
//                 title: Text(
//                   Localization.of(context, 'contact_us'),
//                   style: TextStyle(fontWeight: FontWeight.w400),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ContactUsScreen(
//                         controller: _controller,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               if ((_controller?.showChangeLanguage ?? false) ||
//                   (_controller?.isAdmin ?? false))
//                 ListTile(
//                   title: Text(
//                     Localization.of(context, 'change_language'),
//                     style: TextStyle(fontWeight: FontWeight.w400),
//                   ),
//                   onTap: () {
//                     String language = prefs.getString("swiftShop_language");
//
//                     showBottomSheetList<String>(
//                       context: context,
//                       title: Localization.of(context, 'select_a_language'),
//                       items: ["english", "arabic"],
//                       itemBuilder: (listTileName) {
//                         String language = prefs.getString("swiftShop_language");
//
//                         return ListTile(
//                           title: Text(
//                             "${Localization.of(context, listTileName) ?? ''}",
//                           ),
//                           trailing: isNotEmpty(language)
//                               ? (language == "en" && listTileName == "english"
//                               ? Icon(Icons.check)
//                               : (language == "ar" &&
//                               listTileName == "arabic"
//                               ? Icon(Icons.check)
//                               : SizedBox.shrink()))
//                               : (isEmpty(language) && listTileName == "english")
//                               ? Icon(Icons.check)
//                               : SizedBox.shrink(),
//                         );
//                       },
//                       itemHeight: 60,
//                       onItemSelected: (listTileName) async {
//                         if ((language == null) ||
//                             (((listTileName == "english") &&
//                                 (language != "en")) ||
//                                 ((listTileName != "english") &&
//                                     (language == "en")))) {
//                           await prefs.setString(
//                             'swiftShop_language',
//                             listTileName == "english" ? "en" : "ar",
//                           );
//                           MyApp.setLocale(
//                             context,
//                             Locale(listTileName == "english" ? "en" : "ar"),
//                           );
//                           Phoenix.rebirth(context);
//                         }
//                       },
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//         body: UBScaffold(
//           state: AppState(
//             pageState: _state,
//             onRetry: _load,
//           ),
//           appBar: AppBar(
//             title: Text(
//               _state == PageState.loaded
//                   ? isBuy
//                   ? '${Localization.of(context, "buy")} ${_controller.mainCurrency}'
//                   : '${Localization.of(context, "sell")} ${_controller.mainCurrency}'
//                   : '',
//               style: Theme.of(context)
//                   .textTheme
//                   .headline5
//                   .copyWith(color: Colors.white),
//             ),
//             centerTitle: true,
//             leadingWidth: 112,
//             leading: _state == PageState.loaded
//                 ? Row(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 if (widget.user?.phoneNumber == null)
//                   Padding(
//                     padding: EdgeInsetsDirectional.only(start: 16),
//                     child: GestureDetector(
//                       child: Icon(
//                         Icons.arrow_back_ios,
//                       ),
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ),
//                 Padding(
//                   padding: EdgeInsetsDirectional.only(start: 8),
//                   child: IconButton(
//                     key: _drawerKey,
//                     icon: Icon(
//                       Icons.menu_rounded,
//                       size: 28,
//                     ),
//                     onPressed: _state == PageState.loaded
//                         ? () {
//                       FocusManager.instance.primaryFocus?.unfocus();
//                       scaffoldKey.currentState.openDrawer();
//                     }
//                         : null,
//                   ),
//                 ),
//               ],
//             )
//                 : SizedBox.shrink(),
//             backgroundColor: Color.fromARGB(255, 210, 34, 49),
//             actions: ((widget.user?.phoneNumber != null) &&
//                 (_state == PageState.loaded))
//                 ? [
//               Padding(
//                 padding: EdgeInsetsDirectional.only(end: 6),
//                 child: IconButton(
//                   icon: Icon(Icons.power_settings_new),
//                   onPressed: () async {
//                     showConfirmationBottomSheet(
//                       context: context,
//                       flare: 'assets/flare/pending.flr',
//                       title: Localization.of(
//                         context,
//                         'are_you_sure_you_want_to_log_out',
//                       ),
//                       confirmMessage: Localization.of(context, 'confirm'),
//                       confirmAction: () async {
//                         setState(() {
//                           _state = PageState.loading;
//                         });
//                         try {
//                           await _firebaseAuth
//                               .signOut()
//                               .then((value) => Navigator.of(context)
//                               .pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     FirebaseNotification(
//                                         child: LoginPage()),
//                               ),
//                                   (route) => false))
//                               .catchError((onError) {
//                             showErrorBottomsheet(onError.toString());
//                             setState(() {
//                               _state = PageState.error;
//                             });
//                           });
//                         } catch (e) {
//                           showErrorBottomsheet(e.toString());
//                           setState(() {
//                             _state = PageState.error;
//                           });
//                         }
//                       },
//                       cancelMessage: Localization.of(
//                         context,
//                         'cancel',
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ]
//                 : null,
//           ),
//           builder: (context) => KeyboardFormActions(
//             keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
//             nextFocus: false,
//             keyboardBarColor: Colors.black54,
//             actions: [
//               KeyboardFormAction(
//                 focusNode: nameNode,
//               ),
//               KeyboardFormAction(
//                 focusNode: amountNode,
//               ),
//               KeyboardFormAction(
//                 focusNode: moreDetailsNode,
//               )
//             ],
//             child: RefreshIndicator(
//               key: refreshKey,
//               onRefresh: refresh,
//               child: ListView.builder(
//                 itemCount: 1,
//                 itemBuilder: (b, i) => Form(
//                   key: _formKey,
//                   child: Padding(
//                     padding: EdgeInsets.zero,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: <Widget>[
//                         if (_controller?.showCryptoCurrencyNews ?? false)
//                           Padding(
//                             padding: EdgeInsets.only(bottom: 8.0),
//                             child: Container(
//                               color: Colors.black87,
//                               height: 25,
//                               child: Padding(
//                                 padding: EdgeInsets.only(top: 4.0),
//                                 child: MarqueeText(
//                                   text: TextSpan(
//                                     text: newsText ?? "",
//                                   ),
//                                   style: TextStyle(
//                                     color: Color.fromARGB(255, 255, 215, 0),
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   speed: 30,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               width: 65 +
//                                   (getCoinsCharsCount() /
//                                       2 *
//                                       getMultiplicationValue),
//                             ),
//                             Padding(
//                               padding: EdgeInsetsDirectional.only(start: 0),
//                               child: ToggleButton(
//                                   label1: Localization.of(context, 'buy'),
//                                   label2: Localization.of(context, 'sell'),
//                                   pos: isBuy ? 0 : 1,
//                                   onChanged: (int pos) {
//                                     setState(() {
//                                       isBuy = !isBuy;
//
//                                       if (amount != null && amount.isNotEmpty) {
//                                         if (int.tryParse(amount) >= 50 &&
//                                             int.tryParse(amount) < 100) {
//                                           rate = isBuy
//                                               ? _controller.fiftyToHundred
//                                               : _controller.sellFiftyToHundred;
//                                         } else if (int.tryParse(amount) >=
//                                             100 &&
//                                             int.tryParse(amount) < 1000) {
//                                           rate = isBuy
//                                               ? _controller.hundredToThousand
//                                               : _controller
//                                               .sellHundredToThousand;
//                                         } else if (int.tryParse(amount) >=
//                                             1000 &&
//                                             int.tryParse(amount) < 3000) {
//                                           rate = isBuy
//                                               ? _controller
//                                               .thousandToThreeThousand
//                                               : _controller
//                                               .sellThousandToThreeThousand;
//                                         } else if (int.tryParse(amount) >=
//                                             3000 &&
//                                             int.tryParse(amount) < 5000) {
//                                           rate = isBuy
//                                               ? _controller
//                                               .threeThousandToFiveThousand
//                                               : _controller
//                                               .sellThreeThousandToFiveThousand;
//                                         } else if (int.tryParse(amount) >=
//                                             5000) {
//                                           rate = isBuy
//                                               ? _controller
//                                               .fiveThousandToTenThousand
//                                               : _controller
//                                               .sellFiveThousandToTenThousand;
//                                         }
//                                         amountWithoutFee =
//                                             (double.tryParse(amount) -
//                                                 ((double.tryParse(amount) *
//                                                     rate) /
//                                                     100))
//                                                 .floor();
//                                         amountWithFee =
//                                             (double.tryParse(amount) +
//                                                 ((double.tryParse(amount) *
//                                                     rate) /
//                                                     100))
//                                                 .ceil();
//                                       }
//                                     });
//                                   }),
//                             ),
//                             GestureDetector(
//                               onTap: () async {
//                                 if ((_controller?.isAdmin ?? false) ||
//                                     (_controller
//                                         ?.allowedPeopleToAddOrRemoveRewardItems
//                                         ?.contains(FirebaseAuth.instance
//                                         .currentUser?.phoneNumber) ??
//                                         false) ||
//                                     (_controller?.isRewardsEnabled ?? false)) {
//                                   bool shouldRefresh = await Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => RewardsScreen(
//                                         controller: _controller,
//                                         customer: customer,
//                                       ),
//                                     ),
//                                   );
//                                   if ((shouldRefresh != null) &&
//                                       shouldRefresh) {
//                                     _load();
//                                   }
//                                 } else {
//                                   showConfirmationBottomSheet(
//                                     context: context,
//                                     flare: 'assets/flare/pending.flr',
//                                     title: (Localizations.localeOf(context)
//                                         .languageCode ==
//                                         'ar')
//                                         ? _controller.rewardsDisabledMessageAR
//                                         : _controller.rewardsDisabledMessage,
//                                     confirmMessage: Localization.of(
//                                       context,
//                                       'close',
//                                     ),
//                                     confirmAction: () async {
//                                       Navigator.of(context).pop();
//                                     },
//                                   );
//                                 }
//                               },
//                               child: Container(
//                                 width: 65 +
//                                     (getCoinsCharsCount() /
//                                         2 *
//                                         getMultiplicationValue),
//                                 child: Row(
//                                   children: [
//                                     Image.asset(
//                                       "assets/images/coins.png",
//                                       height: 20.0,
//                                       width: 20.0,
//                                     ),
//                                     Padding(
//                                       padding:
//                                       EdgeInsetsDirectional.only(start: 6),
//                                       child: Text(
//                                         customer?.coins?.toStringAsFixed(2) ??
//                                             "0",
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         layoutContainer(
//                           child: TextFormField(
//                             textDirection:
//                             (Localizations.localeOf(context).languageCode ==
//                                 'ar'
//                                 ? TextDirection.rtl
//                                 : TextDirection.ltr),
//                             focusNode: nameNode,
//                             controller: _nameController,
//                             maxLength: 30,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                 RegExp(
//                                     r"[a-zA-Z !$'()*+-./:<=>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"),
//                               ),
//                             ],
//                             enabled: !isLoading,
//                             validator: (String value) {
//                               if (value?.trim()?.isEmpty ?? true) {
//                                 return Localization.of(
//                                   context,
//                                   'name_cannot_be_empty',
//                                 );
//                               }
//                               return null;
//                             },
//                             decoration: inputDecoration(
//                                 Localization.of(context, 'name')),
//                             textAlign: TextAlign.start,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 18,
//                         ),
//                         layoutContainer(
//                           child: TextFormField(
//                             textDirection:
//                             (Localizations.localeOf(context).languageCode ==
//                                 'ar'
//                                 ? TextDirection.rtl
//                                 : TextDirection.ltr),
//                             enabled: false,
//                             decoration: InputDecoration(
//                               labelText: widget.user?.phoneNumber != null
//                                   ? _getPhoneNumberLabelText()
//                                   : "",
//                               labelStyle: TextStyle(
//                                 color: Colors.black,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black),
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black),
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               hintText:
//                               Localization.of(context, 'phone_number'),
//                               prefixIcon: Container(
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsetsDirectional.only(
//                                         start: 8,
//                                         end: 8,
//                                       ),
//                                       child: Image.asset(
//                                         CountryPickerUtils
//                                             ?.getFlagImageAssetPath(
//                                           selectedCountryIsoCode ?? "LB",
//                                         ),
//                                         height: 20.0,
//                                         width: 35.0,
//                                         package: "country_pickers",
//                                       ),
//                                     ),
//                                     // if (widget.user?.phoneNumber != null)
//                                     //   Padding(
//                                     //     padding:
//                                     //         EdgeInsetsDirectional.only(end: 2),
//                                     //     child: Text(
//                                     //       "+${selectedCountryPhoneCode ?? "961"}",
//                                     //       style: TextStyle(fontSize: 16),
//                                     //     ),
//                                     //   ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             textAlign: TextAlign.start,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 18,
//                         ),
//                         layoutContainer(
//                           child: TextFormField(
//                             textDirection:
//                             (Localizations.localeOf(context).languageCode ==
//                                 'ar'
//                                 ? TextDirection.rtl
//                                 : TextDirection.ltr),
//                             controller: _amountController,
//                             enabled: !isLoading,
//                             focusNode: amountNode,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                 RegExp(r"[0-9]"),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 amount = value;
//                                 if (value != null && value.isNotEmpty) {
//                                   if (int.tryParse(amount) >= 50 &&
//                                       int.tryParse(amount) < 100) {
//                                     rate = isBuy
//                                         ? _controller.fiftyToHundred
//                                         : _controller.sellFiftyToHundred;
//                                   } else if (int.tryParse(amount) >= 100 &&
//                                       int.tryParse(amount) < 1000) {
//                                     rate = isBuy
//                                         ? _controller.hundredToThousand
//                                         : _controller.sellHundredToThousand;
//                                   } else if (int.tryParse(amount) >= 1000 &&
//                                       int.tryParse(amount) < 3000) {
//                                     rate = isBuy
//                                         ? _controller.thousandToThreeThousand
//                                         : _controller
//                                         .sellThousandToThreeThousand;
//                                   } else if (int.tryParse(amount) >= 3000 &&
//                                       int.tryParse(amount) < 5000) {
//                                     rate = isBuy
//                                         ? _controller
//                                         .threeThousandToFiveThousand
//                                         : _controller
//                                         .sellThreeThousandToFiveThousand;
//                                   } else if (int.tryParse(amount) >= 5000) {
//                                     rate = isBuy
//                                         ? _controller.fiveThousandToTenThousand
//                                         : _controller
//                                         .sellFiveThousandToTenThousand;
//                                   }
//                                   amountWithoutFee = (double.tryParse(amount) -
//                                       ((double.tryParse(amount) * rate) /
//                                           100))
//                                       .floor();
//                                   amountWithFee = (double.tryParse(amount) +
//                                       ((double.tryParse(amount) * rate) /
//                                           100))
//                                       .ceil();
//                                 }
//                               });
//                             },
//                             validator: (String value) {
//                               if (value.isEmpty) {
//                                 return Localization.of(
//                                   context,
//                                   'amount_cannot_be_empty',
//                                 );
//                               } else if (int.tryParse(value) <
//                                   _controller.minimumOrder) {
//                                 var firstReplace = replaceVariable(
//                                   Localization.of(
//                                     context,
//                                     'minimum_order_amount',
//                                   ),
//                                   'valueone',
//                                   _controller.minimumOrder?.toString(),
//                                 );
//
//                                 var secondReplace = replaceVariable(
//                                   firstReplace,
//                                   'valuetwo',
//                                   _controller.mainCurrency?.toString(),
//                                 );
//
//                                 return secondReplace;
//                               }
//                               return null;
//                             },
//                             maxLength: 8,
//                             decoration: inputDecoration(
//                               Localization.of(context, 'amount'),
//                               prefixIcon: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Padding(
//                                     padding:
//                                     EdgeInsets.symmetric(horizontal: 8),
//                                     child: Text('${_controller.mainCurrency}'),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsetsDirectional.only(end: 8),
//                                     child: Container(
//                                       width: 1,
//                                       height: 35,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             textAlign: TextAlign.start,
//                           ),
//                         ),
//                         (amount?.isEmpty ?? true)
//                             ? Container()
//                             : (_controller.checkForMinimumOrder
//                             ? ((isBuy ||
//                             _controller.showSellRate ||
//                             (isDriver ||
//                                 ((_controller?.isAdmin ??
//                                     false) ||
//                                     (_controller
//                                         ?.allowedToCheckCustomersBalance ??
//                                         false)))) &&
//                             (amount?.isNotEmpty ?? false
//                                 ? int.tryParse(amount)
//                                 : 0) >=
//                                 _controller.minimumOrder)
//                             : ((isBuy ||
//                             _controller.showSellRate ||
//                             (isDriver ||
//                                 ((_controller?.isAdmin ??
//                                     false) ||
//                                     (_controller
//                                         ?.allowedToCheckCustomersBalance ??
//                                         false)))) &&
//                             (amount?.isNotEmpty ?? false)))
//                             ? Container(
//                           width: MediaQuery.of(context).size.width,
//                           margin: EdgeInsets.only(
//                             left: 40.0,
//                             right: 40.0,
//                             top: 10.0,
//                           ),
//                           alignment: Alignment.center,
//                           padding: EdgeInsetsDirectional.only(
//                             start: 0.0,
//                             end: 10.0,
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(bottom: 12.0),
//                             child: Text(
//                               int.tryParse(amount) >= 10000
//                                   ? Localization.of(
//                                 context,
//                                 'note_ask_for_rate',
//                               )
//                                   : youEitherPay(
//                                   getTextFormatted(
//                                       amount.toString()),
//                                   getTextFormatted(
//                                       amountWithoutFee.toString(),
//                                       first: false),
//                                   getTextFormatted(
//                                       amountWithFee.toString()),
//                                   getTextFormatted(
//                                       amount.toString(),
//                                       first: false)),
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyText1
//                                   .copyWith(
//                                   color: Color.fromARGB(
//                                       255, 210, 34, 49)),
//                             ),
//                           ),
//                         )
//                             : Container(),
//                         layoutContainer(
//                           child: Row(
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsetsDirectional.only(end: 4.0),
//                                 child: ToggleSwitch(
//                                   value: shareLocation,
//                                   onChanged: (bool val) {
//                                     setState(() {
//                                       shareLocation = !shareLocation;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               Container(
//                                 width: MediaQuery.of(context).size.width / 1.8,
//                                 child: Text(
//                                   Localization.of(context, 'share_location'),
//                                   overflow: TextOverflow.clip,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         layoutContainer(
//                           child: DropdownSearch<String>(
//                             validator: (v) => (currentLocation?.longitude ==
//                                 null ||
//                                 currentLocation?.latitude == null ||
//                                 !shareLocation) &&
//                                 (v == null || v.isEmpty)
//                                 ? Localization.of(context,
//                                 'share_your_location_or_select_your_city')
//                                 : null,
//                             hint: Localization.of(context, 'select_a_city'),
//                             maxHeight:
//                             MediaQuery.of(context).size.height * 0.65,
//                             searchBoxDecoration: InputDecoration(
//                               hintText: Localization.of(context, 'search'),
//                               border: OutlineInputBorder(),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black),
//                               ),
//                               labelStyle: TextStyle(
//                                 color: Colors.black,
//                               ),
//                               contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 16),
//                               prefixIcon: Container(
//                                 padding: EdgeInsets.all(12),
//                                 child: SvgPicture.asset(
//                                   'assets/svgs/search.svg',
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                             mode: Mode.MENU,
//                             showSelectedItem: true,
//                             items: _getCities(),
//                             label: Localization.of(context, 'city'),
//                             showSearchBox: true,
//                             showClearButton: true,
//                             onChanged: (city) {
//                               setState(() {
//                                 selectedCity = city;
//                               });
//                             },
//                             popupItemDisabled: (String s) => s.startsWith('I'),
//                             selectedItem:
//                             Localization.of(context, selectedCity),
//                             onBeforeChange: (a, b) {
//                               if (b == null) {
//                                 AlertDialog alert = AlertDialog(
//                                   title: Text(
//                                     Localization.of(context, 'city'),
//                                   ),
//                                   content: Text(
//                                     Localization.of(context,
//                                         'are_you_sure_you_want_to_clear_your_selection'),
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       child: Text(
//                                         Localization.of(context, 'cancel'),
//                                       ),
//                                       onPressed: () {
//                                         Navigator.of(context).pop(false);
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: Text(
//                                         Localization.of(context, 'confirm'),
//                                       ),
//                                       onPressed: () {
//                                         Navigator.of(context).pop(true);
//                                       },
//                                     ),
//                                   ],
//                                 );
//
//                                 return showDialog<bool>(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return alert;
//                                   },
//                                 );
//                               }
//
//                               return Future.value(true);
//                             },
//                           ),
//                         ),
//                         layoutContainer(
//                           child: WKTextField(
//                             key: Key('search_by_minable_item_name'),
//                             hintText: Localization.of(
//                               context,
//                               'more_details_about_your_location',
//                             ),
//                             hintTextSize: 14,
//                             controller: _moreDetailsController,
//                             focusNode: moreDetailsNode,
//                             enabled: !isLoading,
//                             minLines: 3,
//                             maxLines: 5,
//                             maxLength: 150,
//                             textAlign: TextAlign.start,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                 RegExp(
//                                     r"[a-zA-Z0-9 .,()-_!?@+=;:!$'()*+-./:<=>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 62,
//                             vertical: 16,
//                           ),
//                           child: RaisedButtonV2(
//                             disabled: isLoading,
//                             isLoading: isLoading,
//                             onPressed: () async {
//                               if (!_controller.isBanned) {
//                                 bool isRoot = await checkIfSuperUser();
//                                 if ((_controller?.checkForRoot ?? true) &&
//                                     isRoot) {
//                                   await showActionBottomSheet(
//                                     context: context,
//                                     status: OperationStatus.error,
//                                     message: replaceVariable(
//                                       Localization.of(
//                                         context,
//                                         'jailbreak_info',
//                                       ),
//                                       'value',
//                                       _controller.contactUsNumber,
//                                     ),
//                                     popOnPress: true,
//                                     dismissOnTouchOutside: false,
//                                     buttonMessage:
//                                     Localization.of(context, 'ok'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                   );
//                                   return;
//                                 } else {
//                                   if (_formKey.currentState.validate()) {
//                                     if (widget.user?.phoneNumber == null) {
//                                       showErrorBottomsheet(
//                                         Localization.of(
//                                           context,
//                                           'please_login_to_use_this_feature',
//                                         ),
//                                       );
//                                     } else {
//                                       if (!(_controller.isAdmin) &&
//                                           _controller.showCustomError) {
//                                         await showActionBottomSheet(
//                                           context: context,
//                                           status: OperationStatus.error,
//                                           message:
//                                           (Localizations.localeOf(context)
//                                               .languageCode ==
//                                               'ar')
//                                               ? _controller.customErrorAR
//                                               : _controller.customError,
//                                           popOnPress: true,
//                                           dismissOnTouchOutside: false,
//                                           buttonMessage: Localization.of(
//                                             context,
//                                             'ok',
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         );
//                                         return;
//                                       }
//
//                                       if (!(_controller.isAdmin) &&
//                                           _controller.isHoliday) {
//                                         await showActionBottomSheet(
//                                           context: context,
//                                           status: OperationStatus.error,
//                                           message: Localization.of(
//                                             context,
//                                             'we_are_currently_closed',
//                                           ),
//                                           popOnPress: true,
//                                           dismissOnTouchOutside: false,
//                                           buttonMessage: Localization.of(
//                                             context,
//                                             'ok',
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         );
//                                         return;
//                                       }
//
//                                       if (!(_controller.isAdmin) &&
//                                           _controller.checkForOpeningHours) {
//                                         DateTime currentDateTime =
//                                         DateTime.now();
//                                         String errorMsg = (_controller
//                                             .weekdayOpeningHours ==
//                                             _controller
//                                                 .weekendOpeningHours) &&
//                                             (_controller
//                                                 .weekdayClosingHours ==
//                                                 _controller
//                                                     .weekendClosingHours)
//                                             ? _controller.isSundayOff
//                                             ? replaceVariable(
//                                           replaceVariable(
//                                             Localization.of(
//                                               context,
//                                               'Our opening hours are Monday till Saturday from',
//                                             ),
//                                             'valueone',
//                                             _controller
//                                                 .weekdayOpeningHours,
//                                           ),
//                                           'valuetwo',
//                                           _controller
//                                               .weekdayClosingHours,
//                                         )
//                                         // 'Our opening hours are Monday till Saturday from ${_controller.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM.\n Please submit an order during our working hours.'
//                                             : replaceVariable(
//                                           replaceVariable(
//                                             Localization.of(
//                                               context,
//                                               'Our opening hours are everyday from',
//                                             ),
//                                             'valueone',
//                                             _controller
//                                                 .weekdayOpeningHours,
//                                           ),
//                                           'valuetwo',
//                                           _controller
//                                               .weekdayClosingHours,
//                                         )
//                                         // 'Our opening hours are everyday from ${_controller.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM. \nPlease submit an order during our working hours.'
//                                             : _controller.isSundayOff
//                                             ? replaceVariable(
//                                           replaceVariable(
//                                             replaceVariable(
//                                               replaceVariable(
//                                                 Localization.of(
//                                                   context,
//                                                   'Our opening hours are Monday till Friday from',
//                                                 ),
//                                                 'valueone',
//                                                 _controller
//                                                     .weekdayOpeningHours,
//                                               ),
//                                               'valuetwo',
//                                               _controller
//                                                   .weekdayClosingHours,
//                                             ),
//                                             'valuethree',
//                                             _controller
//                                                 .weekendOpeningHours,
//                                           ),
//                                           'valuefour',
//                                           _controller
//                                               .weekendClosingHours,
//                                         )
//
//                                         // 'Our opening hours are Monday till Friday from ${_controller.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM and Saturday from ${_controller.weekendOpeningHours}:00 AM till ${_controller.weekendClosingHours}:00 PM. \nPlease submit an order during our working hours.'
//                                             : replaceVariable(
//                                           replaceVariable(
//                                             replaceVariable(
//                                               replaceVariable(
//                                                 Localization.of(
//                                                   context,
//                                                   'Our opening hours are Monday till Friday fromm',
//                                                 ),
//                                                 'valueone',
//                                                 _controller
//                                                     .weekdayOpeningHours,
//                                               ),
//                                               'valuetwo',
//                                               _controller
//                                                   .weekdayClosingHours,
//                                             ),
//                                             'valuethree',
//                                             _controller
//                                                 .weekendOpeningHours,
//                                           ),
//                                           'valuefour',
//                                           _controller
//                                               .weekendClosingHours,
//                                         );
//                                         // 'Our opening hours are Monday till Friday from ${_controller.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM, Saturday and Sunday from ${_controller.weekendOpeningHours}:00 AM till ${_controller.weekendClosingHours}:00 PM. \nPlease submit an order during our working hours.';
//                                         if ((currentDateTime.weekday) == 7 ||
//                                             (currentDateTime.weekday) == 6) {
//                                           if ((currentDateTime.weekday) == 7 &&
//                                               _controller.isSundayOff) {
//                                             await showActionBottomSheet(
//                                               context: context,
//                                               status: OperationStatus.error,
//                                               message: errorMsg,
//                                               popOnPress: true,
//                                               dismissOnTouchOutside: false,
//                                               buttonMessage:
//                                               Localization.of(context, 'ok')
//                                                   .toUpperCase(),
//                                               onPressed: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                             );
//                                             return;
//                                           }
//                                           if (currentDateTime.hour <
//                                               int.tryParse(_controller
//                                                   .weekendOpeningHours) ||
//                                               currentDateTime.hour >=
//                                                   int.tryParse(_controller
//                                                       .weekendClosingHours)) {
//                                             await showActionBottomSheet(
//                                               context: context,
//                                               status: OperationStatus.error,
//                                               message: errorMsg,
//                                               popOnPress: true,
//                                               dismissOnTouchOutside: false,
//                                               buttonMessage: Localization.of(
//                                                 context,
//                                                 'ok',
//                                               ).toUpperCase(),
//                                               onPressed: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                             );
//                                             return;
//                                           }
//                                         }
//                                         if (currentDateTime.hour <
//                                             int.tryParse(_controller
//                                                 .weekdayOpeningHours) ||
//                                             currentDateTime.hour >=
//                                                 int.tryParse(_controller
//                                                     .weekdayClosingHours)) {
//                                           await showActionBottomSheet(
//                                             context: context,
//                                             status: OperationStatus.error,
//                                             message: errorMsg,
//                                             popOnPress: true,
//                                             dismissOnTouchOutside: false,
//                                             buttonMessage: Localization.of(
//                                               context,
//                                               'ok',
//                                             ).toUpperCase(),
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                           );
//                                           return;
//                                         }
//                                       }
//                                       await showConfirmationBottomSheet(
//                                         context: context,
//                                         flare: 'assets/flare/pending.flr',
//                                         title: Localization.of(
//                                           context,
//                                           'are_you_sure_you_want_to_submit_this_request',
//                                         ),
//                                         message: ((Localizations.localeOf(
//                                             context)
//                                             .languageCode ==
//                                             'ar')
//                                             ? _controller.submissionTextAR
//                                             : _controller.submissionText)
//                                             .replaceAll(r'\n', '\n')
//                                             .replaceAll(r"\'", "\'"),
//                                         confirmMessage:
//                                         Localization.of(context, 'confirm'),
//                                         confirmAction: () async {
//                                           try {
//                                             setState(() {
//                                               isLoading = true;
//                                             });
//                                             Navigator.of(context).pop();
//
//                                             var referenceID =
//                                             Random().nextInt(9999999);
//
//                                             await _submitOrder(referenceID);
//
//                                             setState(() {
//                                               isLoading = false;
//                                             });
//                                             showSuccessBottomsheet(
//                                               referenceID.toString(),
//                                             );
//                                           } catch (e) {
//                                             showErrorBottomsheet(
//                                               Localization.of(context,
//                                                   'an_error_has_occurred'),
//                                             );
//                                             setState(() {
//                                               isLoading = false;
//                                             });
//                                           }
//                                         },
//                                         cancelMessage:
//                                         Localization.of(context, 'cancel'),
//                                       );
//                                     }
//                                   }
//                                 }
//                               } else {
//                                 await showActionBottomSheet(
//                                   context: context,
//                                   status: OperationStatus.error,
//                                   message: replaceVariable(
//                                     Localization.of(
//                                       context,
//                                       'banned_disclaimer',
//                                     ),
//                                     'value',
//                                     _controller.contactUsNumber,
//                                   ),
//                                   popOnPress: true,
//                                   dismissOnTouchOutside: false,
//                                   buttonMessage: Localization.of(
//                                     context,
//                                     'ok',
//                                   ).toUpperCase(),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 );
//                                 return;
//                               }
//                             },
//                             label: Localization.of(context, 'submit'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String youEitherPay(String v1, String v2, String v3, String v4) {
//     var firstReplace = replaceVariable(
//       Localization.of(
//         context,
//         'note_you_either_pay',
//       ),
//       'valueone',
//       v1,
//     );
//
//     var secondReplace = replaceVariable(
//       firstReplace,
//       'valuetwo',
//       v2,
//     );
//
//     var thirdReplace = replaceVariable(
//       secondReplace,
//       'valuethree',
//       v3,
//     );
//
//     var fourthReplace = replaceVariable(
//       thirdReplace,
//       'valuefour',
//       v4,
//     );
//
//     return fourthReplace;
//   }
//
//   get getMultiplicationValue =>
//       (Localizations.localeOf(context).languageCode == 'ar') ? 15 : 12;
//
//   Future<void> _submitOrder(int referenceID) async {
//     CollectionReference orders =
//     FirebaseFirestore.instance.collection('ordersv2');
//
//     var data = await FirebaseFirestore.instance
//         .collection('customers')
//         .doc(widget.user?.phoneNumber ?? '')
//         .snapshots()
//         .first;
//
//     customer = Customer.fromJson(data.data() == null ? null : data.data());
//
//     await Future.wait([
//       // http.get(((num.tryParse(amount) >
//       //             _controller
//       //                 .smallAmountsLimit)
//       //         ? _controller
//       //             .largeAmountsGoogleSheetURL
//       //         : _controller
//       //             .smallAmountsGoogleSheetURL) +
//       //     "?requestID=%23 $referenceID&type=${isBuy ? 'Buy' : 'Sell'}&name=${_nameController?.text?.trim() ?? ''}&phoneNumber=${widget.user?.phoneNumber}&amount=${num.tryParse(amount)}&amountWithFee=$amountWithFee&amountWithoutFee=$amountWithoutFee"),
//       if (customer == null)
//         FirebaseFirestore.instance
//             .collection('customers')
//             .doc(widget.user.phoneNumber)
//             .set(Customer(
//           phoneNumber: widget.user.phoneNumber,
//           notificationToken: notificationToken,
//           coins: customer?.coins ?? 0,
//           totalMoneyIn: customer?.totalMoneyIn ?? 0,
//           totalMoneyOut: customer?.totalMoneyOut ?? 0,
//         ).toJson()),
//       FirebaseFirestore.instance
//           .collection('customers')
//           .doc(widget.user.phoneNumber)
//           .collection("MyOrders")
//           .doc(
//           '${DateTime.now().year}${getNumberWithPrefixZero(DateTime.now().month)}${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}')
//           .set(
//         Order(
//           name: _nameController?.text?.trim(),
//           amount: num.tryParse(amount),
//           action: isBuy ? 'buy' : 'sell',
//           longitude: currentLocation?.longitude,
//           latitude: currentLocation?.latitude,
//           details: _moreDetailsController?.text?.trim(),
//           phoneNumber: widget.user.phoneNumber,
//           shareLocation: shareLocation,
//           driver: '',
//           referenceID: referenceID,
//           accepted: false,
//           notificationToken: notificationToken,
//           location: selectedCity ?? '',
//           sentTime:
//           '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
//           coins: 0,
//           customerOrderDateTime:
//           '${DateTime.now().year}${getNumberWithPrefixZero(DateTime.now().month)}${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}',
//         ).toJson(),
//       ),
//       orders
//           .doc(
//         ((num.tryParse(amount) > _controller.smallAmountsLimit)
//             ? 'largeOrders'
//             : 'smallOrders'),
//       )
//           .collection(
//           "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}")
//           .doc(
//           '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}')
//           .set(
//         Order(
//           name: _nameController?.text?.trim(),
//           amount: num.tryParse(amount),
//           action: isBuy ? 'buy' : 'sell',
//           longitude: currentLocation?.longitude,
//           latitude: currentLocation?.latitude,
//           details: _moreDetailsController?.text?.trim(),
//           phoneNumber: widget.user.phoneNumber,
//           shareLocation: shareLocation,
//           driver: '',
//           referenceID: referenceID,
//           accepted: false,
//           notificationToken: notificationToken,
//           location: selectedCity ?? '',
//           sentTime:
//           '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
//           coins: 0,
//           customerOrderDateTime:
//           '${DateTime.now().year}${getNumberWithPrefixZero(DateTime.now().month)}${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}',
//         ).toJson(),
//       ),
//     ]);
//   }
//
//   String getTextFormatted(String text, {bool first = true}) {
//     return isBuy
//         ? first
//         ? "\$" + text
//         : text + " ${_controller.mainCurrency}"
//         : first
//         ? text + " ${_controller.mainCurrency}"
//         : "\$" + text;
//   }
//
//   Widget labelTitlePair(String title, String label, {bool showDivider = true}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(title,
//             style: Theme.of(context).textTheme.bodyText1.copyWith(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             )),
//         Text(label,
//             style: Theme.of(context).textTheme.bodyText1.copyWith(
//               fontSize: 12,
//               fontWeight: FontWeight.normal,
//               color: Colors.black,
//             )),
//         SizedBox(height: 8),
//         showDivider ? Divider() : Container(height: 0, width: 0),
//         SizedBox(height: 8),
//       ],
//     );
//   }
//
//   void showErrorBottomsheet(
//       String error, {
//         bool dismissOnTouchOutside = true,
//         bool showDoneButton = true,
//         bool doublePop = false,
//       }) async {
//     if (!mounted) return;
//     await showBottomSheetStatus(
//       context: context,
//       status: OperationStatus.error,
//       message: error,
//       popOnPress: true,
//       dismissOnTouchOutside: dismissOnTouchOutside,
//       showDoneButton: showDoneButton,
//       onPressed: doublePop ? () => Navigator.of(context).pop() : null,
//     );
//   }
//
//   void showUpdateBottomSheet(String error) async {
//     if (!mounted) return;
//     await showActionBottomSheet(
//       context: context,
//       status: OperationStatus.error,
//       message: error,
//       popOnPress: true,
//       dismissOnTouchOutside: false,
//       buttonMessage: Localization.of(context, 'update_app'),
//       onPressed: () {
//         updateApp();
//       },
//     );
//   }
//
//   Widget itemWidget(BuildContext context, int index) {
//     return Text(lebaneseTowns()[index]);
//   }
//
//   void showSuccessBottomsheet(String referenceID) async {
//     checkboxValue = false;
//     String showTelegramDialog = prefs.getString('swiftShop_show_telegram_dialog');
//
//     if (!mounted) return;
//     String animResource;
//     animResource = 'assets/flare/success.flr';
//     setState(() {
//       Vibration.vibrate();
//     });
//
//     await showBottomsheet(
//       context: context,
//       isScrollControlled: true,
//       dismissOnTouchOutside: false,
//       height: MediaQuery.of(context).size.height * 0.6,
//       upperWidget: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Center(
//             child: Container(
//               width: 100,
//               height: 100,
//               child: animResource != null
//                   ? FlareActor(
//                 animResource,
//                 animation: 'animate',
//                 fit: BoxFit.fitWidth,
//               )
//                   : Container(),
//             ),
//           ),
//           SizedBox(height: 8),
//           Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width / 1.5,
//               child: Center(
//                 child: Text(
//                   getRequestSentToOurOfficesText(),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyText1.copyWith(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//       bottomWidget: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 18),
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           child: Padding(
//             padding: EdgeInsets.only(bottom: 24),
//             child: RaisedButtonV2(
//               label: Localization.of(context, 'done'),
//               disabled: isLoading ?? false,
//               onPressed: () async {
//                 setState(() {
//                   _nameController.text = '';
//                   amount = '';
//                   _amountController.text = '';
//                   _moreDetailsController.text = '';
//                   selectedCity = null;
//                 });
//                 await Navigator.of(context).pop();
//
//                 if ((!_controller.showTelegramDialog) &&
//                     (showTelegramDialog == null ||
//                         showTelegramDialog != 'dontshow')) {
//                   showDialog(
//                     context: context,
//                     builder: (_) => StatefulBuilder(
//                       builder: (BuildContext context, StateSetter setState) =>
//                           WKAssetGiffyDialog(
//                             image: Image.asset(
//                               'assets/images/telegramGif.gif',
//                             ),
//                             title: Text(
//                               Localization.of(context,
//                                   'do_you_want_to_join_our_telegram_channel'),
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 22.0,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             description: Text(
//                               Localization.of(
//                                   context, 'by_joining_our_telegram_group') ??
//                                   "",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16.0,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             entryAnimation: EntryAnimation.BOTTOM,
//                             buttonCancelText: Text(
//                               Localization.of(context, 'maybe_later'),
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             buttonOkText: Text(
//                               Localization.of(context, 'sure'),
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             buttonOkColor: Colors.lightBlue,
//                             onCancelButtonPressed: () async {
//                               if (checkboxValue ?? false) {
//                                 await prefs.setString(
//                                   'swiftShop_show_telegram_dialog',
//                                   'dontshow',
//                                 );
//                               }
//                               await Navigator.of(context).pop();
//                             },
//                             onOkButtonPressed: () async {
//                               if (checkboxValue ?? false) {
//                                 await prefs.setString(
//                                   'swiftShop_show_telegram_dialog',
//                                   'dontshow',
//                                 );
//                               }
//                               await Navigator.of(context).pop();
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SignalsScreen(
//                                     controller: _controller,
//                                     showOverview: false,
//                                   ),
//                                 ),
//                               );
//                             },
//                             checkboxWidget: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   checkboxValue = !checkboxValue;
//                                 });
//                               },
//                               child: Row(
//                                 children: [
//                                   Checkbox(
//                                     value: checkboxValue,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         checkboxValue = value;
//                                       });
//                                     },
//                                   ),
//                                   Text(
//                                     Localization.of(context, 'never_ask_me_again'),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             labelTitlePair(
//               Localization.of(context, 'your_request_id'),
//               '\# $referenceID',
//             ),
//             labelTitlePair(
//               Localization.of(context, 'name'),
//               _nameController?.text?.trim(),
//             ),
//             labelTitlePair(
//               Localization.of(context, 'phone_number'),
//               (Localizations.localeOf(context).languageCode == 'ar')
//                   ? ((widget.user?.phoneNumber?.replaceAll('+', '') ?? '') +
//                   '+')
//                   : ('+' +
//                   (widget.user?.phoneNumber?.replaceAll('+', '') ?? "")),
//             ),
//             labelTitlePair(
//               Localization.of(context, 'amount'),
//               '\$ $amount',
//             ),
//             labelTitlePair(
//               Localization.of(context, 'sharing_location'),
//               shareLocation
//                   ? Localization.of(context, 'yes')
//                   : Localization.of(context, 'no'),
//             ),
//             if (selectedCity?.isNotEmpty ?? false)
//               labelTitlePair(
//                 Localization.of(context, 'location'),
//                 Localization.of(context, selectedCity),
//               ),
//             if (_moreDetailsController?.text?.trim()?.isNotEmpty)
//               labelTitlePair(
//                 Localization.of(context, 'more_details_about_your_location'),
//                 _moreDetailsController.text,
//               ),
//             SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget layoutContainer({Widget child}) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       margin: EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
//       alignment: Alignment.center,
//       padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
//       child: Padding(
//         padding: EdgeInsets.only(bottom: 12.0),
//         child: child,
//       ),
//     );
//   }
//
//   String getRequestSentToOurOfficesText() {
//     var firstReplace = replaceVariable(
//       Localization.of(context, 'your_request_has_been_sent_to_our_offices'),
//       'valueone',
//       isBuy
//           ? Localization.of(context, 'the_buy').toLowerCase()
//           : Localization.of(context, 'the_sell').toLowerCase(),
//     );
//
//     return firstReplace;
//   }
//
//   InputDecoration inputDecoration(String hintText, {Widget prefixIcon}) {
//     return InputDecoration(
//       labelText: hintText,
//       counterText: "",
//       labelStyle: TextStyle(
//         color: Colors.black,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.black),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.black),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       prefixIcon: prefixIcon,
//     );
//   }
//
//   void updateApp() async {
//     StoreRedirect.redirect(
//       androidAppId: "com.wkbeast.buy_sell_usdt",
//       iOSAppId: _controller.iOSAppId,
//     );
//   }
//
//   List<String> _getCities() {
//     List<String> beirut = ["Beirut"];
//     List<String> citiesList = lebaneseTowns()
//       ..addAll(List<String>.from(_controller.cities.where((element) => true)))
//       ..sort();
//     return beirut..addAll(citiesList);
//   }
//
//   String _getPhoneNumberLabelText() {
//     return (Localizations.localeOf(context).languageCode == 'ar')
//         ? ('${widget.user?.phoneNumber?.substring(
//       selectedCountryPhoneCode == null
//           ? 4
//           : (selectedCountryPhoneCode?.length ?? 0) + 1,
//     )} ${selectedCountryPhoneCode ?? "961"}' +
//         '+')
//         : ('+${selectedCountryPhoneCode ?? "961"} ${widget.user?.phoneNumber?.substring(
//       selectedCountryPhoneCode == null
//           ? 4
//           : (selectedCountryPhoneCode?.length ?? 0) + 1,
//     )}');
//   }
// }
