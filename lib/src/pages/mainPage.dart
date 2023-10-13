import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/mixins/home_screen_controller_mixin.dart';
import 'package:flutter_ecommerce_app/src/models/employee.dart';
import 'package:flutter_ecommerce_app/src/models/order.dart';
import 'package:flutter_ecommerce_app/src/pages/home_page.dart';
import 'package:flutter_ecommerce_app/src/pages/shopping_cart_page.dart';
import 'package:flutter_ecommerce_app/src/pages/BottomSheets/unban_user_bottomsheet.dart';
import 'package:flutter_ecommerce_app/src/pages/upcoming_orders.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:flutter_ecommerce_app/src/widgets/extentions.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../main.dart';
import '../firebase_notification.dart';
import 'BottomSheets/add_employee_bottomsheet.dart';
import 'BottomSheets/send_notification_bottomsheet.dart';
import 'authentication/login.dart';
import 'BottomSheets/ban_user_bottomsheet.dart';
import 'check_customers_order.dart';
import 'contact_us/contact_us_screen.dart';
import 'customer_history_screen.dart';
import 'feedback/feedback_list_screen.dart';
import 'feedback/send_us_your_feedbacks_screen.dart';
import 'orders/all_orders_screen.dart';
import 'orders/paid_orders_screen.dart';

GlobalKey coachMarkKey = GlobalObjectKey("coachMarkKey");

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with HomeScreenControllerMixin
    implements HomeScreenControllerView {
  bool isHomePageSelected = true;
  bool isButtonLoading = false;
  var image;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  List<String> adminPanelNames = [];

  void initState() {
    super.initState();
    _loadController();
    // homeScreenController = HomeScreenController(
    //   {},
    //   null,
    //   {},
    // );
    // homeScreenController.setView(this);
  }

  Future<void> _loadController() async {
    setHomeScreenControllerView(this);
    await loadHomeScreenController();
  }

  Future<void> _load() async {
    if (adminPanelNames.isEmpty &&
        (homeScreenController.feedbackReceiversList?.isNotEmpty ?? false))
      await _buildAdminPanelWidgets();
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (homeScreenController.admins?.isNotEmpty ?? false)
            RotatedBox(
              quarterTurns: 4,
              child: _icon(Icons.sort, color: Colors.black54),
            ),
          if (homeScreenController.admins?.isEmpty ?? true)
            SizedBox(height: 44),
          InkWell(
            onTap: () async {
              final isArabic =
                  (Localizations.localeOf(context).languageCode == 'ar');
              MyApp.setLocale(
                context,
                Locale(isArabic ? "en" : "ar"),
              );
              prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                'swiftShop_language',
                isArabic ? "en" : "ar",
              );

              Phoenix.rebirth(context);
            },
            child: Container(
              padding: EdgeInsetsDirectional.only(start: 42),
              child: Text(
                (Localizations.localeOf(context).languageCode == 'ar')
                    ? "English"
                    : "العربية",
                style: TextStyle(
                    fontSize:
                        (Localizations.localeOf(context).languageCode == 'ar')
                            ? 14
                            : 16),
              ),
            ),
          ),
          // ClipRRect(
          //   borderRadius: BorderRadius.all(Radius.circular(13)),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).backgroundColor,
          //       boxShadow: <BoxShadow>[
          //         BoxShadow(
          //             color: Color(0xfff8f8f8),
          //             blurRadius: 10,
          //             spreadRadius: 10),
          //       ],
          //     ),
          //     child: Image.asset("assets/user.png"),
          //   ),
          // ).ripple(() {}, borderRadius: BorderRadius.all(Radius.circular(13)))
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return GestureDetector(
      onTap: () {
        setState(() {});
        scaffoldKey.currentState.openDrawer();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            color: Theme.of(context).backgroundColor,
            boxShadow: AppTheme.shadow),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
        margin: AppTheme.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitleText(
                  text: isHomePageSelected
                      ? Localization.of(context, "order")
                      : index == 1
                          ? Localization.of(context, "upcoming")
                          : Localization.of(context, "shopping"),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: isHomePageSelected
                      ? Localization.of(context, "now")
                      : index == 1
                          ? Localization.of(context, "orders")
                          : Localization.of(context, "cart"),
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            Spacer(),
            !isHomePageSelected
                ? (homeScreenController.productsLinks.isEmpty || index != 2
                    ? SizedBox.shrink()
                    : Container(
                        padding: EdgeInsets.all(10),
                        child: IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () async {
                            await showConfirmationBottomSheet(
                              context: context,
                              flare: 'assets/flare/pending.flr',
                              title: Localization.of(
                                context,
                                'are_you_sure_you_want_to_clear_your_shopping_cart',
                              ),
                              confirmMessage:
                                  Localization.of(context, 'confirm'),
                              confirmAction: () async {
                                await Navigator.of(context).pop();
                                homeScreenController.productsTitles = [];
                                homeScreenController.productsLinks = [];
                                homeScreenController.productsQuantities = [];
                                homeScreenController.productsColors = [];
                                homeScreenController.productsSizes = [];
                                homeScreenController.productsPrices = [];
                                homeScreenController.productsImages = [];

                                homeScreenController.refreshView();

                                setState(() {});
                              },
                              cancelMessage: Localization.of(context, 'cancel'),
                            );
                          },
                          color: LightColor.orange,
                        ),
                      ))
                : SizedBox()
          ],
        ));
  }

  var index;
  void onBottomIconPressed(int indexx) {
    index = indexx;
    if (index == 0) {
      setState(() {
        isHomePageSelected = true;
      });
    } else {
      setState(() {
        isHomePageSelected = false;
      });
    }
  }

  dynamic getManagementListTileWidget(String listTileName) async {
    if (listTileName == Localization.of(context, 'all_orders')) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AllOrdersScreen(
            controller: homeScreenController,
          ),
        ),
      );
      setState(() {});
    } else if (listTileName == Localization.of(context, 'paid_orders')) {
      showBottomSheetList<String>(
        context: context,
        title: Localization.of(context, 'select_an_item'),
        items: [
          Localization.of(context, 'paid'),
          Localization.of(context, 'awaiting_shipment'),
          Localization.of(context, 'orderOnTheWay'),
          Localization.of(context, 'awaitingCustomerPickup'),
        ],
        itemBuilder: (listTileName) {
          return ListTile(
            title: Text(
              "${listTileName ?? ''}",
            ),
          );
        },
        itemHeight: 60,
        onItemSelected: (listTileName) async {
          if (listTileName.toLowerCase() ==
              Localization.of(context, 'paid').toLowerCase()) {
            await Navigator.popUntil(
                context, (Route<dynamic> route) => route.isFirst);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaidOrdersScreen(
                  controller: homeScreenController,
                  shipmentStatus: ShipmentStatus.paid,
                ),
              ),
            );
          } else if (listTileName.toLowerCase() ==
              Localization.of(context, 'awaiting_shipment').toLowerCase()) {
            await Navigator.popUntil(
                context, (Route<dynamic> route) => route.isFirst);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaidOrdersScreen(
                  controller: homeScreenController,
                  shipmentStatus: ShipmentStatus.awaitingShipment,
                ),
              ),
            );
          } else if (listTileName.toLowerCase() ==
              Localization.of(context, 'orderOnTheWay').toLowerCase()) {
            await Navigator.popUntil(
                context, (Route<dynamic> route) => route.isFirst);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaidOrdersScreen(
                  controller: homeScreenController,
                  shipmentStatus: ShipmentStatus.orderOnTheWay,
                ),
              ),
            );
          } else if (listTileName.toLowerCase() ==
              Localization.of(context, 'awaitingCustomerPickup')
                  .toLowerCase()) {
            await Navigator.popUntil(
                context, (Route<dynamic> route) => route.isFirst);

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaidOrdersScreen(
                  controller: homeScreenController,
                  shipmentStatus: ShipmentStatus.awaitingCustomerPickup,
                ),
              ),
            );
          }
          // await Navigator.of(context).pop();
          // getManagementListTileWidget(listTileName);
        },
      );
    } else if (listTileName ==
        Localization.of(context, 'check_customers_order')) {
      showBottomsheet(
        context: context,
        height: MediaQuery.of(context).size.height * 0.4,
        dismissOnTouchOutside: false,
        isScrollControlled: true,
        upperWidget: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                onTap: () {
                  setState(() {
                    return isButtonLoading ? null : Navigator.of(context).pop();
                  });
                })
          ],
        ),
        body: CheckCustomersOrderBottomsheet(
          controller: homeScreenController,
          isBottomSheetLoading: (isLoad) {
            setState(() {
              isButtonLoading = isLoad;
            });
          },
        ),
      );
      setState(() {});
    } else if (listTileName == Localization.of(context, 'feedbacks')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FeedbackListScreen(controller: homeScreenController),
        ),
      );
    } else if (listTileName == Localization.of(context, 'send_notification')) {
      showBottomsheet(
        context: context,
        height: MediaQuery.of(context).size.height * 0.4,
        dismissOnTouchOutside: false,
        isScrollControlled: true,
        upperWidget: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                onTap: () {
                  setState(() {
                    return isButtonLoading ? null : Navigator.of(context).pop();
                  });
                })
          ],
        ),
        body: SendNotificationBottomsheet(
          controller: homeScreenController,
          isBottomSheetLoading: (isLoad) {
            setState(() {
              isButtonLoading = isLoad;
            });
          },
          changed: (hasChanged) {},
        ),
      );
      setState(() {});
    } else if (listTileName == Localization.of(context, 'add_employee')) {
      showBottomsheet(
        context: context,
        height: MediaQuery.of(context).size.height * 0.4,
        dismissOnTouchOutside: false,
        isScrollControlled: true,
        upperWidget: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                onTap: () {
                  setState(() {
                    return isButtonLoading ? null : Navigator.of(context).pop();
                  });
                })
          ],
        ),
        body: AddEmployeeBottomsheet(
          controller: homeScreenController,
          isBottomSheetLoading: (isLoad) {
            setState(() {
              isButtonLoading = isLoad;
            });
          },
          changed: (hasChanged) {
            if (hasChanged) {
              _load();
            }
          },
        ),
      );
    } else if (listTileName == Localization.of(context, 'fire_employee')) {
      showBottomSheetList<Employee>(
        context: context,
        title: Localization.of(context, 'fire_employee'),
        items: homeScreenController.employees,
        itemBuilder: (employee) {
          return ListTile(
            title: Text(
              "${employee.name ?? ''}",
            ),
          );
        },
        itemHeight: 50,
        onItemSelected: (driver) async {
          FocusManager.instance.primaryFocus?.unfocus();
          scaffoldKey.currentState.openDrawer();
          await Navigator.of(context).pop();
          await showConfirmationBottomSheet(
            context: context,
            flare: 'assets/flare/pending.flr',
            title: replaceVariable(
              Localization.of(
                context,
                'are_you_sure_you_want_to_fire',
              ),
              'value',
              driver.name,
            ),
            confirmMessage: Localization.of(context, 'confirm'),
            confirmAction: () async {
              try {
                List<dynamic> newEmployeesList = [];
                for (int i = 0;
                    i < homeScreenController.employees.length;
                    i++) {
                  newEmployeesList
                      .add(homeScreenController.employees[i].phoneNumber);
                }
                newEmployeesList
                    .removeWhere((element) => element == driver.phoneNumber);

                await Navigator.of(context).pop();

                await Future.wait([
                  FirebaseFirestore.instance
                      .collection('app info')
                      .doc('app')
                      .update({
                    'Employees': newEmployeesList,
                  }),
                  FirebaseFirestore.instance
                      .collection('Employees')
                      .doc(driver.phoneNumber)
                      .delete(),
                ]);
                showSuccessBottomsheet(
                  message:
                      Localization.of(context, 'employee_fired_successfully'),
                );
              } catch (e) {
                await Navigator.of(context).pop();
                showErrorBottomsheet(context, e.toString());
              }
            },
            cancelMessage: Localization.of(context, 'cancel'),
          );
        },
      );
    } else if (listTileName == Localization.of(context, 'ban_user')) {
      showBottomsheet(
        context: context,
        height: MediaQuery.of(context).size.height * 0.4,
        dismissOnTouchOutside: false,
        isScrollControlled: true,
        upperWidget: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                onTap: () {
                  setState(() {
                    return isButtonLoading ? null : Navigator.of(context).pop();
                  });
                })
          ],
        ),
        body: BanUserBottomsheet(
          controller: homeScreenController,
          isBottomSheetLoading: (isLoad) {
            setState(() {
              isButtonLoading = isLoad;
            });
          },
        ),
      );
      setState(() {});
    } else if (listTileName == Localization.of(context, 'unban_user')) {
      showBottomsheet(
        context: context,
        height: MediaQuery.of(context).size.height * 0.4,
        dismissOnTouchOutside: false,
        isScrollControlled: true,
        upperWidget: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                onTap: () {
                  setState(() {
                    return isButtonLoading ? null : Navigator.of(context).pop();
                  });
                })
          ],
        ),
        body: UnbanUserBottomsheet(
          controller: homeScreenController,
          isBottomSheetLoading: (isLoad) {
            setState(() {
              isButtonLoading = isLoad;
            });
          },
        ),
      );
      setState(() {});
    }
  }

  bool get phoneNumberIsNull =>
      FirebaseAuth.instance.currentUser?.phoneNumber == null;

  void _buildAdminPanelWidgets() {
    adminPanelNames = [];

    adminPanelNames
      ..addAll(
        [
          Localization.of(context, 'all_orders'),
          Localization.of(context, 'paid_orders'),
          if (homeScreenController.canUserCheckOtherCustomersOrders)
            Localization.of(context, 'check_customers_order'),
          if ((homeScreenController.feedbackReceiversList
                  ?.contains(FirebaseAuth.instance.currentUser?.phoneNumber) ??
              false))
            Localization.of(context, 'feedbacks'),
          if (homeScreenController.isAdmin)
            Localization.of(context, 'send_notification'),
          if (homeScreenController.isAdmin)
            if (homeScreenController.isAdmin)
              Localization.of(context, 'add_employee'),
          if (homeScreenController.isAdmin)
            if (homeScreenController.isAdmin)
              Localization.of(context, 'fire_employee'),
          if (homeScreenController.isAdmin)
            if (homeScreenController.isAdmin)
              Localization.of(context, 'ban_user'),
          if (homeScreenController.isAdmin)
            if (homeScreenController.isAdmin)
              Localization.of(context, 'unban_user'),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    _load();
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 64,
            ),

            /// TODO, to add back we have to fix GET CUSTOMER (order customerName coming null)
            // if (phoneNumberIsNull)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(end: 6),
            //     child: ListTile(
            //       title: Text(
            //         Localization.of(context, 'login'),
            //         style: TextStyle(fontWeight: FontWeight.w400),
            //       ),
            //       onTap: () async {
            //         bool didLogin = await Navigator.of(context).push(
            //           MaterialPageRoute(
            //             builder: (context) =>
            //                 FirebaseNotification(child: LoginPage()),
            //           ),
            //         );
            //         if (didLogin ?? false) {
            //           await Navigator.of(context).pop();
            //           setState(() {});
            //           showSuccessBottomsheet();
            //         }
            //       },
            //     ),
            //   ),

            if ((homeScreenController?.employees?.firstWhere(
                      (element) =>
                          element.phoneNumber ==
                          FirebaseAuth.instance.currentUser?.phoneNumber,
                      orElse: () => null,
                    ) !=
                    null) ??
                false)
              ListTile(
                title: Text(
                  Localization.of(context, 'admin_panel'),
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  showBottomSheetList<String>(
                    context: context,
                    title: Localization.of(context, 'select_an_item'),
                    items: adminPanelNames,
                    itemBuilder: (listTileName) {
                      return ListTile(
                        title: Text(
                          "${listTileName ?? ''}",
                        ),
                      );
                    },
                    itemHeight: 60,
                    onItemSelected: (listTileName) async {
                      await Navigator.of(context).pop();
                      getManagementListTileWidget(listTileName);
                    },
                  );
                },
              ),
            // if (!phoneNumberIsNull && _controller.isAdmin)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(end: 6),
            //     child: ListTile(
            //       title: Text(
            //         Localization.of(context, 'all_orders'),
            //         style: TextStyle(fontWeight: FontWeight.w400),
            //       ),
            //       onTap: () async {
            //         await Navigator.of(context).push(
            //           MaterialPageRoute(
            //             builder: (context) => AllOrdersScreen(
            //               controller: _controller,
            //             ),
            //           ),
            //         );
            //         setState(() {});
            //       },
            //     ),
            //   ),
            if (!phoneNumberIsNull &&
                (!(homeScreenController?.hideContents ?? true)))
              Padding(
                padding: EdgeInsetsDirectional.only(end: 6),
                child: ListTile(
                  title: Text(
                    Localization.of(context, 'orders_history'),
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomerHistoryScreen(
                          homeScreenController: homeScreenController,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
              ),

            // if (!phoneNumberIsNull &&
            //     _controller.canUserCheckOtherCustomersOrders)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(end: 6),
            //     child: ListTile(
            //       title: Text(
            //         Localization.of(context, 'check_customers_order'),
            //         style: TextStyle(fontWeight: FontWeight.w400),
            //       ),
            //       onTap: () async {
            //         showBottomsheet(
            //           context: context,
            //           height: MediaQuery.of(context).size.height * 0.4,
            //           dismissOnTouchOutside: false,
            //           isScrollControlled: true,
            //           upperWidget: Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: <Widget>[
            //               GestureDetector(
            //                   child: Padding(
            //                     padding: EdgeInsets.symmetric(
            //                       horizontal: 16.0,
            //                       vertical: 16.0,
            //                     ),
            //                     child: Icon(
            //                       Icons.close,
            //                       color: Colors.black,
            //                       size: 30,
            //                     ),
            //                   ),
            //                   onTap: () {
            //                     setState(() {
            //                       return isButtonLoading
            //                           ? null
            //                           : Navigator.of(context).pop();
            //                     });
            //                   })
            //             ],
            //           ),
            //           body: CheckCustomersOrderBottomsheet(
            //             controller: _controller,
            //             isBottomSheetLoading: (isLoad) {
            //               setState(() {
            //                 isButtonLoading = isLoad;
            //               });
            //             },
            //           ),
            //         );
            //         setState(() {});
            //       },
            //     ),
            //   ),
            // if (!phoneNumberIsNull &&
            //     (_controller.feedbackReceiversList?.contains(
            //             FirebaseAuth.instance.currentUser?.phoneNumber) ??
            //         false))
            //   ListTile(
            //     title: Text(
            //       Localization.of(context, 'feedbacks'),
            //       style: TextStyle(fontWeight: FontWeight.w400),
            //     ),
            //     onTap: () async {
            //       await Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               FeedbackListScreen(controller: _controller),
            //         ),
            //       );
            //     },
            //   ),
            if (!phoneNumberIsNull)
              ListTile(
                title: Text(
                  Localization.of(context, 'send_feedback'),
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(
                        controller: homeScreenController,
                      ),
                    ),
                  );
                },
              ),
            // if (!phoneNumberIsNull && _controller.isAdmin)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(end: 6),
            //     child: ListTile(
            //       title: Text(
            //         Localization.of(context, 'send_notification'),
            //         style: TextStyle(fontWeight: FontWeight.w400),
            //       ),
            //       onTap: () async {
            //         showBottomsheet(
            //           context: context,
            //           height: MediaQuery.of(context).size.height * 0.4,
            //           dismissOnTouchOutside: false,
            //           isScrollControlled: true,
            //           upperWidget: Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: <Widget>[
            //               GestureDetector(
            //                   child: Padding(
            //                     padding: EdgeInsets.symmetric(
            //                       horizontal: 16.0,
            //                       vertical: 16.0,
            //                     ),
            //                     child: Icon(
            //                       Icons.close,
            //                       color: Colors.black,
            //                       size: 30,
            //                     ),
            //                   ),
            //                   onTap: () {
            //                     setState(() {
            //                       return isButtonLoading
            //                           ? null
            //                           : Navigator.of(context).pop();
            //                     });
            //                   })
            //             ],
            //           ),
            //           body: SendNotificationBottomsheet(
            //             controller: _controller,
            //             isBottomSheetLoading: (isLoad) {
            //               setState(() {
            //                 isButtonLoading = isLoad;
            //               });
            //             },
            //             changed: (hasChanged) {},
            //           ),
            //         );
            //         setState(() {});
            //       },
            //     ),
            //   ),
            // if (!phoneNumberIsNull && _controller.isAdmin)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(end: 6),
            //     child: ListTile(
            //       title: Text(
            //         Localization.of(context, 'ban_user'),
            //         style: TextStyle(fontWeight: FontWeight.w400),
            //       ),
            //       onTap: () async {
            //         showBottomsheet(
            //           context: context,
            //           height: MediaQuery.of(context).size.height * 0.4,
            //           dismissOnTouchOutside: false,
            //           isScrollControlled: true,
            //           upperWidget: Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: <Widget>[
            //               GestureDetector(
            //                   child: Padding(
            //                     padding: EdgeInsets.symmetric(
            //                       horizontal: 16.0,
            //                       vertical: 16.0,
            //                     ),
            //                     child: Icon(
            //                       Icons.close,
            //                       color: Colors.black,
            //                       size: 30,
            //                     ),
            //                   ),
            //                   onTap: () {
            //                     setState(() {
            //                       return isButtonLoading
            //                           ? null
            //                           : Navigator.of(context).pop();
            //                     });
            //                   })
            //             ],
            //           ),
            //           body: BanUserBottomsheet(
            //             controller: _controller,
            //             isBottomSheetLoading: (isLoad) {
            //               setState(() {
            //                 isButtonLoading = isLoad;
            //               });
            //             },
            //           ),
            //         );
            //         setState(() {});
            //       },
            //     ),
            //   ),
            // if (!phoneNumberIsNull && _controller.isAdmin)
            //   Padding(
            //     padding: EdgeInsetsDirectional.only(end: 6),
            //     child: ListTile(
            //       title: Text(
            //         Localization.of(context, 'unban_user'),
            //         style: TextStyle(fontWeight: FontWeight.w400),
            //       ),
            //       onTap: () async {
            //         showBottomsheet(
            //           context: context,
            //           height: MediaQuery.of(context).size.height * 0.4,
            //           dismissOnTouchOutside: false,
            //           isScrollControlled: true,
            //           upperWidget: Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: <Widget>[
            //               GestureDetector(
            //                   child: Padding(
            //                     padding: EdgeInsets.symmetric(
            //                       horizontal: 16.0,
            //                       vertical: 16.0,
            //                     ),
            //                     child: Icon(
            //                       Icons.close,
            //                       color: Colors.black,
            //                       size: 30,
            //                     ),
            //                   ),
            //                   onTap: () {
            //                     setState(() {
            //                       return isButtonLoading
            //                           ? null
            //                           : Navigator.of(context).pop();
            //                     });
            //                   })
            //             ],
            //           ),
            //           body: UnbanUserBottomsheet(
            //             controller: _controller,
            //             isBottomSheetLoading: (isLoad) {
            //               setState(() {
            //                 isButtonLoading = isLoad;
            //               });
            //             },
            //           ),
            //         );
            //         setState(() {});
            //       },
            //     ),
            //   ),
            ListTile(
              title: Text(
                Localization.of(context, 'contact_us'),
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactUsScreen(
                      controller: homeScreenController,
                    ),
                  ),
                );
              },
            ),
            if (!phoneNumberIsNull)
              Padding(
                padding: EdgeInsetsDirectional.only(end: 6),
                child: ListTile(
                  title: Text(
                    Localization.of(context, 'logout'),
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    showConfirmationBottomSheet(
                      context: context,
                      flare: 'assets/flare/pending.flr',
                      title: Localization.of(
                        context,
                        'are_you_sure_you_want_to_log_out',
                      ),
                      confirmMessage: Localization.of(context, 'confirm'),
                      confirmAction: () async {
                        try {
                          // await FirebaseMessaging.instance.unsubscribeFromTopic(
                          //     'swiftShop_notifications_${FirebaseAuth.instance.currentUser?.phoneNumber.toString().substring(1)}');

                          await FirebaseAuth.instance
                              .signOut()
                              .then((value) =>
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => MainPage(),
                                      ),
                                      (route) => false))
                              .catchError((onError) {
                            showErrorBottomsheet(context, onError.toString());
                          });
                        } catch (e) {
                          // showErrorBottomsheet(context, e.toString());
                        }
                      },
                      cancelMessage: Localization.of(
                        context,
                        'cancel',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      body: UBScaffold(
        backgroundColor: Colors.transparent,
        state: AppState(
          pageState: homeScreenControllerState,
          onRetry: _load,
        ),
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 48),
              height: AppTheme.fullHeight(context) - 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xfffbfbfb),
                    Color(0xfff7f7f7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _appBar(),
                  if (!homeScreenController.hideContents) _title(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInToLinear,
                      switchOutCurve: Curves.easeOutBack,
                      child: isHomePageSelected
                          ? MyHomePage(
                              homeScreenController: homeScreenController)
                          : index == 1
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: UpcomingOrdersScreen(
                                    homeScreenController: homeScreenController,
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: ShoppingCartPage(
                                    homeScreenController: homeScreenController,
                                  ),
                                ),
                    ),
                  )
                ],
              ),
            ),
            if (WidgetsBinding.instance.window.viewInsets.bottom < 1)
              Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: CustomBottomNavigationBar(
                    onIconPresedCallback: onBottomIconPressed,
                    homeScreenController: homeScreenController,
                    // selectedTab: index,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void refreshState() {
    setState(() {});
  }

  void showSuccessBottomsheet({String message}) async {
    if (!mounted) return;
    String animResource;
    animResource = 'assets/flare/success.flr';
    setState(() {
      Vibration.vibrate();
    });

    await showBottomsheet(
      context: context,
      isScrollControlled: true,
      dismissOnTouchOutside: true,
      height: MediaQuery.of(context).size.height * 0.25,
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 80,
              child: animResource != null
                  ? FlareActor(
                      animResource,
                      animation: 'animate',
                      fit: BoxFit.fitWidth,
                    )
                  : Container(),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  message ?? Localization.of(context, "login_successful"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
      bottomWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: RaisedButtonV2(
              label: Localization.of(context, 'done'),
              // disabled: isLoading ?? false,
              onPressed: () async {
                await Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void jumpToCartScreen() {
    // setState(() {
    //   index = 2;
    //   isHomePageSelected = false;
    // });
  }
}
