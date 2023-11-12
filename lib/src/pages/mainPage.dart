import 'dart:async';

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
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_helper_extension.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:vibration/vibration.dart';

import '../../main.dart';
import '../firebase_notification.dart';
import '../models/customer.dart';
import '../utils/BottomSheets/operation_status.dart';
import 'BottomSheets/add_employee_bottomsheet.dart';
import 'BottomSheets/send_notification_bottomsheet.dart';
import 'BottomSheets/ban_user_bottomsheet.dart';
import 'authentication/login.dart';
import 'check_customers_order.dart';
import 'contact_us/contact_us_screen.dart';
import 'customer_history_screen.dart';
import 'feedback/feedback_list_screen.dart';
import 'feedback/send_us_your_feedbacks_screen.dart';
import 'orders/all_orders_screen.dart';
import 'orders/paid_orders_screen.dart';
import 'dart:ui';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

GlobalKey shoppingCartKey = GlobalObjectKey("shoppingCartKey");
GlobalKey upcomingOrdersKey = GlobalObjectKey("upcomingOrdersKey");
GlobalKey hamburgerIconKey = GlobalObjectKey("hamburgerIconKey");
GlobalKey changeLanguageKey = GlobalObjectKey("changeLanguageKey");

class MainPage extends StatefulWidget {
  MainPage({Key? key, this.title}) : super(key: key);

  final String? title;

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
  late SharedPreferences prefss;
  List<String> adminPanelNames = [];
  Timer? _loadTimer;
  bool _isLoadingLogin = false;

  void initState() {
    super.initState();
    _loadController();
  }

  Future<void> _loadAgain() async {
    _loadTimer = Timer(
        Duration(
            minutes: int.tryParse(
                homeScreenController.loadUpdateDuration.toString())!),
        () async {
      try {
        cancelLoadTimer();
        await _loadController(forceRefresh: true);
      } catch (e) {
        cancelLoadTimer();
        await _loadController(forceRefresh: true);
        print("Error ${e.toString()}");
      }
    });
  }

  void cancelLoadTimer() {
    _loadTimer?.cancel();
  }

  Future<void> _loadController({bool forceRefresh = false}) async {
    if (!forceRefresh) setHomeScreenControllerView(this);
    await loadHomeScreenController();

    checkForUpdate();

    if ((homeScreenController.shouldLoadAgainAfterTimer ?? false)) _loadAgain();
  }

  Future<void> _load() async {
    if (adminPanelNames.isEmpty &&
        (homeScreenController.feedbackReceiversList?.isNotEmpty ?? false))
      _buildAdminPanelWidgets();
  }

  void checkForUpdate() {
    List<String> versionSplitAtPlus =
        homeScreenController.version?.split('+') ?? [];
    List<String> versionSplitAtDot = versionSplitAtPlus[0].split('.');
    String currentVersion = versionSplitAtDot[0] +
        versionSplitAtDot[1] +
        versionSplitAtDot[2] +
        versionSplitAtPlus[1];

    if (homeScreenController.forceUpdate ?? false) {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        List<String> iosVersionSplitAtPlus =
            homeScreenController.iosAppVersion?.split('+') ?? [];
        List<String> iosVersionSplitAtDot = iosVersionSplitAtPlus[0].split('.');
        String consoleString = iosVersionSplitAtDot[0] +
            iosVersionSplitAtDot[1] +
            iosVersionSplitAtDot[2] +
            iosVersionSplitAtPlus[1];
        if (num.parse(consoleString) > num.parse(currentVersion))
          showUpdateBottomSheet(
            Localization.of(context, 'newer_version_available'),
          );
      } else {
        List<String> androidVersionSplitAtPlus =
            homeScreenController.androidAppVersion?.split('+') ?? [];
        List<String> androidVersionSplitAtDot =
            androidVersionSplitAtPlus[0].split('.');
        String consoleString = androidVersionSplitAtDot[0] +
            androidVersionSplitAtDot[1] +
            androidVersionSplitAtDot[2] +
            androidVersionSplitAtPlus[1];
        if (num.parse(consoleString) > num.parse(currentVersion))
          showUpdateBottomSheet(
            Localization.of(context, 'newer_version_available'),
          );
      }
    }
  }

  Future<void> _showCoachMark() async {
    createTutorial();
    Future.delayed(Duration.zero, showTutorial);
  }

  GlobalKey keyButton = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  var selectedTutorialElement;

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      textSkip: isEmpty(selectedTutorialElement) ? "" : "SKIP",
      paddingFocus: 15,
      opacityShadow: 0.7,
      skipWidget: Text(
        Localization.of(context, "next"),
        style: TextStyle(
          color: Colors.white,
          // fontWeight: FontWeight.bold,
          // fontSize: 20.0,
        ),
      ),
      showSkipInLastTarget: false,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        if (isEmpty(selectedTutorialElement)) {
          tutorialCoachMark.goTo(1);
          return false;
        } else {
          return true;
        }
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
        // target.identify == "keyBottomNavigation2";
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        selectedTutorialElement = target.identify;
        print(selectedTutorialElement);
        // print("target: $target");
        // print(
        //     "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        return false;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation1",
        keyTarget: formKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        paddingFocus: 0.5,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: EdgeInsets.only(top: 0, left: 20, right: 20),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: 20.0),
                  //   child: Text(
                  //     Localization.of(context, "product_details"),
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 20.0,
                  //     ),
                  //   ),
                  // ),
                  Text(
                    Localization.of(context, "product_details_description"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 30,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation2",
        keyTarget: addToCart,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        paddingFocus: 0.5,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: 20.0),
                  //   child: Text(
                  //     Localization.of(context, "add_to_cart_coachmark"),
                  //     style: TextStyle(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 20.0),
                  //   ),
                  // ),
                  Text(
                    Localization.of(context, "add_to_cart_coachmark_details"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 30,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation3",
        keyTarget: shoppingCartKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Localization.of(context, "added_to_cart_coachmark"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation4",
        keyTarget: upcomingOrdersKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Localization.of(context, "upcoming_orders_coachmark"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation5",
        keyTarget: changeLanguageKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Localization.of(context, "languageKey"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "keyBottomNavigation6",
        keyTarget: hamburgerIconKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    Localization.of(context, "hamburgerIconDetails"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }

  void showUpdateBottomSheet(String error) async {
    if (!mounted) return;
    await showActionBottomSheet(
      context: context,
      status: OperationStatus.error,
      message: error,
      popOnPress: true,
      dismissOnTouchOutside: false,
      buttonMessage: Localization.of(context, 'update_app'),
      onPressed: () {
        updateApp();
      },
    );
  }

  void updateApp() async {
    StoreRedirect.redirect(
      androidAppId: homeScreenController.androidAppId,
      iOSAppId: homeScreenController.iOSAppId,
    );
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (homeScreenController.admins?.isNotEmpty ?? false)
            RotatedBox(
              key: hamburgerIconKey,
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
              prefss = await SharedPreferences.getInstance();
              await prefss.setString(
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
                key: changeLanguageKey,
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
        scaffoldKey.currentState?.openDrawer();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            color: LightColor.orange,
            boxShadow: AppTheme.shadow),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _title() {
    return Container(
        margin: AppTheme.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TitleText(
                    text: isHomePageSelected
                        ? Localization.of(context, "order")
                        : index == 1
                            ? Localization.of(context, "upcoming_s")
                            : Localization.of(context, "shopping"),
                    fontSize: 27,
                    fontWeight: FontWeight.w400,
                  ),
                  TitleText(
                    text: isHomePageSelected
                        ? Localization.of(context, "now")
                        : index == 1
                            ? Localization.of(context, "ordersss")
                            : Localization.of(context, "cart"),
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
            Spacer(),
            if ((homeScreenController.showCoachMark ?? false) &&
                isHomePageSelected)
              Container(
                // width: 60,
                child: InkWell(
                  onTap: () {
                    _showCoachMark();
                  },
                  child: Text(
                    Localization.of(context, "need_help"),
                    // fontSize: 27,
                    // fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                                try {
                                  // setState(() {
                                  //   isLoading = true;
                                  // });

                                  await homeScreenController.resetCart();

                                  homeScreenController.refreshView();

                                  // setState(() {
                                  //   isLoading = false;
                                  // });
                                } catch (e) {
                                  print("error deleting cart");
                                  // setState(() {
                                  //   isLoading = false;
                                  // });
                                }

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
              "${listTileName}",
            ),
          );
        },
        itemHeight: 60,
        onItemSelected: (listTileName) async {
          await Navigator.of(context).pop;
          if (listTileName.toLowerCase() ==
              Localization.of(context, 'paid').toLowerCase()) {
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
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaidOrdersScreen(
                  controller: homeScreenController,
                  shipmentStatus: ShipmentStatus.awaitingCustomerPickup,
                ),
              ),
            );
          }
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
          await Navigator.of(context).pop;
          FocusManager.instance.primaryFocus?.unfocus();
          scaffoldKey.currentState?.openDrawer();
          Navigator.of(context).pop();
          await showConfirmationBottomSheet(
            context: context,
            flare: 'assets/flare/pending.flr',
            title: replaceVariable(
              Localization.of(
                context,
                'are_you_sure_you_want_to_fire',
              ),
              'value',
              driver.name ?? "",
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
                Navigator.of(context).pop();
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
          if (homeScreenController.canUserCheckOtherCustomersOrders ?? false)
            Localization.of(context, 'check_customers_order'),
          if ((homeScreenController.feedbackReceiversList
                  ?.contains(FirebaseAuth.instance.currentUser?.phoneNumber) ??
              false))
            Localization.of(context, 'feedbacks'),
          if (homeScreenController.isAdmin ?? false)
            Localization.of(context, 'send_notification'),
          if (homeScreenController.isAdmin ?? false)
            if (homeScreenController.isAdmin ?? false)
              Localization.of(context, 'add_employee'),
          if (homeScreenController.isAdmin ?? false)
            if (homeScreenController.isAdmin ?? false)
              Localization.of(context, 'fire_employee'),
          if (homeScreenController.isAdmin ?? false)
            if (homeScreenController.isAdmin ?? false)
              Localization.of(context, 'ban_user'),
          if (homeScreenController.isAdmin ?? false)
            if (homeScreenController.isAdmin ?? false)
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
            if (phoneNumberIsNull &&
                !(homeScreenController.hideLoginFromMainPage ?? true))
              Padding(
                padding: EdgeInsetsDirectional.only(end: 6),
                child: ListTile(
                  title: _isLoadingLogin
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              LightColor.orange,
                            ),
                          ),
                        )
                      : Text(
                          Localization.of(context, 'login'),
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                  onTap: () async {
                    // Navigator.of(context).pop();
                    var customerNamee = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FirebaseNotification(
                          child: LoginPage(
                            homeScreenController: homeScreenController,
                          ),
                        ),
                      ),
                    );
                    try {
                      Customer customer;
                      setState(() {
                        _isLoadingLogin = true;
                      });

                      if (isNotEmpty(customerNamee)) {
                        await Navigator.of(context).pop;
                        await Navigator.of(context).pop;
                        String customerName =
                            customerNamee.toString().split("|1|2|3|")[0];
                        String customerPhoneNumber =
                            customerNamee.toString().split("|1|2|3|")[1];

                        notificationToken =
                            await FirebaseMessaging.instance.getToken();
                        var result = await FirebaseFirestore.instance
                            .collection('Customers')
                            .doc(customerPhoneNumber)
                            .snapshots()
                            .first;
                        if (result.data() == null) {
                          var newCustomer = Customer(
                            name: customerName.toString().capitalize,
                            phoneNumber: customerPhoneNumber,
                            notificationToken: notificationToken,
                            coins: 0,
                          );

                          customer = newCustomer;
                          homeScreenController.customer = newCustomer;

                          await FirebaseFirestore.instance
                              .collection('Customers')
                              .doc(customerPhoneNumber)
                              .set(newCustomer.toJson());
                        } else {
                          customer = Customer.fromJson(
                              result.data() as Map<dynamic, dynamic>);
                          customer = Customer(
                            name: customerName.toString().capitalize,
                            phoneNumber: customer.phoneNumber,
                            notificationToken: notificationToken,
                            coins: customer.coins ?? 0,
                          );

                          homeScreenController.customer = Customer(
                            name: customerName.toString().capitalize,
                            phoneNumber: customer.phoneNumber,
                            notificationToken: notificationToken,
                            coins: customer.coins ?? 0,
                          );

                          await FirebaseFirestore.instance
                              .collection('Customers')
                              .doc(customer.phoneNumber)
                              .set(Customer(
                                name: customerName.toString().capitalize,
                                phoneNumber: customer.phoneNumber,
                                notificationToken: notificationToken,
                                coins: customer.coins ?? 0,
                              ).toJson());
                        }

                        adminPanelNames = [];
                        _load();
                        _buildAdminPanelWidgets();

                        showLoginSuccessBottomsheet(
                          Localization.of(context, "login_successful"),
                          closeOnTapOutside: false,
                          shouldSetState: false,
                          onTap: () async {
                            // Navigator.of(context).pop();
                          },
                        );
                      } else {
                        setState(() {
                          _isLoadingLogin = false;
                        });
                      }
                    } catch (e) {
                      print("error submitting order ${e.toString()}");
                      setState(() {
                        _isLoadingLogin = false;
                      });
                    }
                  },
                ),
              ),

            if (homeScreenController.employees
                    .firstWhere(
                        (element) =>
                            element.phoneNumber ==
                            FirebaseAuth.instance.currentUser?.phoneNumber,
                        orElse: () => Employee(name: null))
                    .name !=
                null)
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
                          "${listTileName}",
                        ),
                      );
                    },
                    itemHeight: 60,
                    onItemSelected: (listTileName) async {
                      await Navigator.of(context).pop;
                      getManagementListTileWidget(listTileName);
                    },
                  );
                },
              ),

            if (!phoneNumberIsNull &&
                (!(homeScreenController.hideContents ?? true)))
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

            if (!phoneNumberIsNull &&
                (homeScreenController.showCheckMyOrder ?? false))
              ListTile(
                title: Text(
                  Localization.of(context, 'check_my_order'),
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                onTap: () {
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
                                return isButtonLoading
                                    ? null
                                    : Navigator.of(context).pop();
                              });
                            })
                      ],
                    ),
                    body: CheckCustomersOrderBottomsheet(
                      controller: homeScreenController,
                      isCustomer: true,
                      isBottomSheetLoading: (isLoad) {
                        setState(() {
                          isButtonLoading = isLoad;
                        });
                      },
                    ),
                  );
                  setState(() {});
                },
              ),

            if (!phoneNumberIsNull)
              ListTile(
                title: Text(
                  Localization.of(context, 'send_feedback_s'),
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
            if (!phoneNumberIsNull &&
                (homeScreenController.showDeactivateAccount ?? false))
              Padding(
                padding: EdgeInsetsDirectional.only(end: 6),
                child: ListTile(
                  title: Text(
                    Localization.of(context, 'deactivate_account'),
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    showConfirmationBottomSheet(
                      context: context,
                      flare: 'assets/flare/pending.flr',
                      title: Localization.of(
                        context,
                        'are_you_sure_you_want_to_deactivate_account',
                      ),
                      confirmMessage:
                          Localization.of(context, 'deactivate_account'),
                      confirmAction: () async {
                        try {
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
          onRetry: _loadController,
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
                  if (!(homeScreenController.hideContents ?? true)) _title(),
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
                child: Container(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: CustomBottomNavigationBar(
                      onIconPresedCallback: onBottomIconPressed,
                      homeScreenController: homeScreenController,
                      // selectedTab: index,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showLoginSuccessBottomsheet(
    String message, {
    bool closeOnTapOutside = true,
    Function? onTap,
    bool shouldSetState = true,
    bool shouldPop = true,
  }) async {
    if (!mounted) return;
    String animResource;
    animResource = 'assets/flare/success.flr';
    // setState(() {
    Vibration.vibrate();
    // });

    await showBottomsheet(
      context: context,
      isScrollControlled: true,
      dismissOnTouchOutside: closeOnTapOutside,
      height: MediaQuery.of(context).size.height *
          (Theme.of(context).platform == TargetPlatform.iOS ? 0.27 : 0.3),
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 80,
              child: FlareActor(
                animResource,
                animation: 'animate',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
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
                if (shouldPop) Navigator.of(context).pop();
                if (onTap != null) onTap();
                if (shouldSetState) setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void refreshState() {
    setState(() {});
  }

  void showSuccessBottomsheet({String? message}) async {
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
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
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
                Navigator.of(context).pop();
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
