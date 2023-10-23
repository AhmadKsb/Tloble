import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/mixins/home_screen_controller_mixin.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';

import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/operation_status.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/keyboard_actions_form.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:vibration/vibration.dart';
// import 'package:highlighter_coachmark/highlighter_coachmark.dart';

import 'mainPage.dart';

class MyHomePage extends StatefulWidget {
  final User? user;
  final HomeScreenController? homeScreenController;

  MyHomePage({
    Key? key,
    this.user,
    this.homeScreenController,
  }) : super(key: key);
  static const String route = '/home';

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyHomePageState>()?.restartApp();
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, HomeScreenControllerMixin {
  AppLifecycleState appState = AppLifecycleState.resumed;
  bool requestTimerRunning = false;
  late HomeScreenController _controller;

  var image;
  var imageLink;
  var price;
  var itemDescription;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _quantityController = TextEditingController(),
      _productLinkController = TextEditingController(),
      _moreDetailsController = TextEditingController(),
      _colorController = TextEditingController(),
      _sizeController = TextEditingController();

  FocusNode nameNode = new FocusNode(),
      quantityNode = new FocusNode(),
      colorNode = new FocusNode(),
      sizeNode = new FocusNode(),
      productLink = new FocusNode(),
      moreDetailsNode = new FocusNode();

  bool isLoading = false;

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;

  String? amount, errorMessage, notificationToken, newsText = "";
  List<String> adminPanelNames = [];

  final _formKey = GlobalKey<FormState>();
  GlobalKey _addToCart = GlobalObjectKey("addToCart");

  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    WidgetsBinding.instance.addObserver(this);
    _load();
    _showCoachMark();
  }

  Future<void> _showCoachMark() async {
    if (_controller.showCoachMark ?? false) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String coachMark = _controller.coachMarkCampaign ?? '';
      String? showCoachMarkCampaign = sharedPreferences.getString(coachMark);

      if ((_controller.forceShowCoachmark ?? false) ||
          (showCoachMarkCampaign == null ||
              showCoachMarkCampaign != 'coachmarkAlreadyShown')) {
        sharedPreferences.setString(
          _controller.coachMarkCampaign ?? '',
          "coachmarkAlreadyShown",
        );
        createTutorial();
        Future.delayed(Duration.zero, showTutorial);


      }
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _load();
    _isRefreshing = false;
    setState(() {
      refreshKey = GlobalKey<RefreshIndicatorState>();
    });
  }

  Future<void> _load() async {
    if (widget.homeScreenController == null) {
      await loadHomeScreenController();
      _controller = homeScreenController;
    } else {
      _controller = widget.homeScreenController!;
    }
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
      colorShadow: Colors.grey,
      textSkip: isEmpty(selectedTutorialElement) ? "" : "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.6,
      skipWidget: Text(
        Localization.of(context, "next"),
        style: TextStyle(
          color: Colors.white,
          // fontWeight: FontWeight.bold,
          // fontSize: 20.0,
        ),
      ),
      showSkipInLastTarget: true,
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
        keyTarget: _formKey,
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
        keyTarget: _addToCart,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        paddingFocus: 0.5,
        contents: [
          TargetContent(
            align: ContentAlign.top,
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
                      fontSize: 16.0,
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
                      fontSize: 16.0,
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
                      fontSize: 16.0,
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

  void showCampaignDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 8.0,
          contentPadding: EdgeInsets.all(18.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 4),
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
                  child: Text(
                    ((Localizations.localeOf(context).languageCode == 'ar')
                            ? _controller.campaignContentsAR
                                ?.replaceAll("\\n", "\n")
                            : _controller.campaignContents
                                ?.replaceAll("\\n", "\n")) ??
                        "",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _load() async {
  //   setState(() {
  //     _state = PageState.loading;
  //   });
  //
  //   prefs = await SharedPreferences.getInstance();
  //   String activateNotification = prefs.getString('swiftShop_notification');
  //   selectedCountryPhoneCode = prefs.getString('swiftShop_phoneCode');
  //   selectedCountryIsoCode = prefs.getString('swiftShop_isoCode');
  //
  //   if (activateNotification == null || activateNotification != 'activate') {
  //     FirebaseMessaging.instance.subscribeToTopic('swiftShop_notification');
  //     prefs.setString(
  //       'swiftShop_notification',
  //       'activate',
  //     );
  //   }
  //
  //   try {
  //     List data = await Future.wait(
  //       [
  //         FirebaseFirestore.instance.collection('app info').snapshots().first,
  //         PackageInfo.fromPlatform(),
  //         FirebaseMessaging.instance.getToken(),
  //         SharedPreferences.getInstance(),
  //         FirebaseFirestore.instance.collection('Employees').snapshots().first,
  //         if (isNotEmpty(FirebaseAuth.instance.currentUser?.phoneNumber))
  //           FirebaseFirestore.instance
  //               .collection('Customers')
  //               .doc(FirebaseAuth.instance.currentUser?.phoneNumber ?? '')
  //               .snapshots()
  //               .first
  //       ],
  //     );
  //
  //     var employeesDocs = (data[4] as QuerySnapshot).docs;
  //     employeesList = Employee.fromJsonList(employeesDocs);
  //     widget.homeScreenController.employees = employeesList;
  //
  //     if (isNotEmpty(FirebaseAuth.instance.currentUser?.phoneNumber)) {
  //       customer = Customer.fromJson(
  //           (data[5] as DocumentSnapshot).data() == null
  //               ? null
  //               : data[5].data());
  //       widget.homeScreenController.customer = customer;
  //     }
  //
  //     widget.homeScreenController.fillFieldsFromData(
  //         appInfoSnapshott: ((data[0] as QuerySnapshot)
  //             .docs
  //             .firstWhere((document) => document.id == 'app')).data());
  //
  //     prefs.setStringList(
  //       'swiftShop_feedback_receivers',
  //       List<String>.from(widget.homeScreenController.feedbackReceiversList
  //           .where((element) => true)),
  //     );
  //
  //     prefs.setStringList(
  //       'swiftShop_employees',
  //       List<String>.from(
  //           widget.homeScreenController.employeesList.where((element) => true)),
  //     );
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
  //     // _buildAdminPanelWidgets();
  //     // _buildCoachMarkCampaign(prefs);
  //
  //     setState(() {
  //       _state = PageState.loaded;
  //     });
  //   } catch (e) {
  //     print(e);
  //     setState(() {
  //       _state = PageState.error;
  //     });
  //   }
  // }

  Future<void> _loadSephora() async {
    var originalUrl = _productLinkController.text;
    var newLink = "https://www.sephora.ae/en/" +
        _productLinkController.text.split("/")[4];

    print("1NEW LINK $newLink");
    try {
      newLink = "https://www.sephora.ae/en/" +
          _productLinkController.text.split("/")[6];
      print("2NEW LINK $newLink");
    } catch (e) {
      print("new link error");
      print(e);
    }

    try {
      image = null;
      imageLink = null;
      price = null;
      itemDescription = null;
      var screen = await http.get(Uri.parse(newLink), headers: {
        "Referer": "https://www.amazon.ae/",
        "Accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-US,en;q=0.9",
        "Cookie":
            "session-id=257-9305385-2759535; ubid-acbae=260-2832369-0146907; session-id-time=2082787201l; i18n-prefs=USD; lc-acbae=en_AE; session-token=3WTKYSqLAm2xKyExGQt+mD/V+xtQ+vxPyFkgegxMtsc6n+91Wa7uArSaWu+rkwwA3exxquvAuyE6he4VX4T7xAnbEwsvS9eYDEL4RqIB7uSrYXC8S686qeWEZ+ovW8TN5YnoOxhlygBP4aF+hKbA0fs8AhOpCVrxIcb5AM7GXES9FqM8QV1rLv29jel8E0BhduT0HwBjOWixMofwlk77YbKZC9/dWFdfOXMS8VVHyaTX/x84bp//Fpm0mncxTuyF8cvoxQZMZLc94iRwVUNqnuB5CZuym8U5KnKiNR4woobscVqNd/UFg/q2ls4J9Q4WLY4S6iKyHfKkL/HInNuuZo4rSqH/uCU9; csm-hit=tb:s-KRG2MX5B6XX2SGRV0M4Y|1697119950939&t:1697119952988&adb:adblk_no",
        "User-Agent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
        // "Content-Language": "en",
        // "cookie":
        //     "session-id=257-9305385-2759535; ubid-acbae=260-2832369-0146907; session-token=/Kzv84vyt+U13Tu0Ng6I8IDwRoRDnlEVEWL83liTV4VTzbXi/2sHXVrAJ7rQDzLVFAibV40ZLOfeVZMUAJVtQuFiMgYDlAJUSf383PHaNfctuC0+TaR9SCV1FWEejZi1rfY2GPjpTLbbN3rzAlQiPLMQZjlkxxwtv7kUq7hm6ZafAsk1rbIuIAE/3knO3Cx1JMCIPWAKFEkA9kwOtXEnQCT7FUud43icWfMhtlbiDqX2iQfU2Z5RXbVuZFQPJixzt7Q/8Cx6QSg60hiliAXJVUsrYe2Lz6oLCejGPpRQTITEWPF8FcBPhmAsqwqZ7IxBkPDIrX9CsJLss5IJFSnU5jHEVJ3TcGl3; session-id-time=2082787201l; lc-acbae=en_AE; i18n-prefs=USD; csm-hit=tb:B74ATQ2VHYAA7PJ022A9+s-2JP7AH7XW6SWEV9BFKSB|1697025051128&t:1697025051128&adb:adblk_no",
      });

      if (isEmpty(screen.body)) return;

      // "id":"40061304733731"
      // print(screen.body.split("\"id\":\"40061304733731\",\"image\":{\"src\":\"")[1].split("\"}")[0].replaceAll("\\", "").replaceAll("//", ""));
      // imageLink = ;

      var itemDescriptionEN;

      itemDescriptionEN =
          screen.body.split("product-name-bold\"\>")[1].split("\<\/")[0].trim();

      var descriptionOriginal = await http.get(Uri.parse(originalUrl));

      itemDescription = descriptionOriginal.body
          .split("product-name-bold\"\>")[1]
          .split("\<\/")[0]
          .trim();

      print("SECOND $itemDescriptionEN");

      const HtmlEscape htmlEscape = HtmlEscape();
      String escaped = htmlEscape.convert(itemDescriptionEN ?? "");
      var imagee;
      try {
        imageLink = screen.body.split(escaped + "\" src=\"")[1].split("\"")[0];

        imagee = await http.get(Uri.parse(imageLink));
      } catch (e) {}

      // print("GETTING PRICE");
      // price = (num.tryParse(screen.body
      //             .split("price-sales-standard\"\>")[1]
      //             .split(" AED")[0]
      //             ?.replaceAll(',', '')) /
      //         num.tryParse(_controller.aedConversion))
      //     .toStringAsFixed(2);
      // print("PRICE $price");

      image = MemoryImage(
        imagee.bodyBytes,
      );
    } catch (e) {
      // showErrorBottomsheet(
      //   Localization.of(context, 'invalid_link'),
      // );
      print(e);
    }

    setState(() {});
  }

  Future<void> _loadAmazon() async {
    var originalUrl = _productLinkController.text;

    var url = _productLinkController.text;

    try {
      image = null;
      imageLink = null;
      price = null;
      itemDescription = null;
      var screen = await http.get(Uri.parse(url), headers: {
        "Referer": "https://www.amazon.ae/",
        "Accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-US,en;q=0.9",
        "Cookie":
            "session-id=257-9305385-2759535; ubid-acbae=260-2832369-0146907; session-id-time=2082787201l; i18n-prefs=USD; lc-acbae=en_AE; session-token=3WTKYSqLAm2xKyExGQt+mD/V+xtQ+vxPyFkgegxMtsc6n+91Wa7uArSaWu+rkwwA3exxquvAuyE6he4VX4T7xAnbEwsvS9eYDEL4RqIB7uSrYXC8S686qeWEZ+ovW8TN5YnoOxhlygBP4aF+hKbA0fs8AhOpCVrxIcb5AM7GXES9FqM8QV1rLv29jel8E0BhduT0HwBjOWixMofwlk77YbKZC9/dWFdfOXMS8VVHyaTX/x84bp//Fpm0mncxTuyF8cvoxQZMZLc94iRwVUNqnuB5CZuym8U5KnKiNR4woobscVqNd/UFg/q2ls4J9Q4WLY4S6iKyHfKkL/HInNuuZo4rSqH/uCU9; csm-hit=tb:s-KRG2MX5B6XX2SGRV0M4Y|1697119950939&t:1697119952988&adb:adblk_no",
        "User-Agent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
        // "Content-Language": "en",
        // "cookie":
        //     "session-id=257-9305385-2759535; ubid-acbae=260-2832369-0146907; session-token=/Kzv84vyt+U13Tu0Ng6I8IDwRoRDnlEVEWL83liTV4VTzbXi/2sHXVrAJ7rQDzLVFAibV40ZLOfeVZMUAJVtQuFiMgYDlAJUSf383PHaNfctuC0+TaR9SCV1FWEejZi1rfY2GPjpTLbbN3rzAlQiPLMQZjlkxxwtv7kUq7hm6ZafAsk1rbIuIAE/3knO3Cx1JMCIPWAKFEkA9kwOtXEnQCT7FUud43icWfMhtlbiDqX2iQfU2Z5RXbVuZFQPJixzt7Q/8Cx6QSg60hiliAXJVUsrYe2Lz6oLCejGPpRQTITEWPF8FcBPhmAsqwqZ7IxBkPDIrX9CsJLss5IJFSnU5jHEVJ3TcGl3; session-id-time=2082787201l; lc-acbae=en_AE; i18n-prefs=USD; csm-hit=tb:B74ATQ2VHYAA7PJ022A9+s-2JP7AH7XW6SWEV9BFKSB|1697025051128&t:1697025051128&adb:adblk_no",
      });

      if (isEmpty(screen.body)) return;

      // "id":"40061304733731"
      // print(screen.body.split("\"id\":\"40061304733731\",\"image\":{\"src\":\"")[1].split("\"}")[0].replaceAll("\\", "").replaceAll("//", ""));
      // imageLink = ;

      var itemDescriptionEN;

      itemDescriptionEN = screen.body
          .split("product-title-word-break\"\>")[1]
          .split("\<\/")[0]
          .trim();

      const HtmlEscape htmlEscape = HtmlEscape();
      String escaped = htmlEscape.convert(itemDescriptionEN ?? "");

      imageLink = screen.body.split(escaped + "\" src=\"")[1].split("\"")[0];

      var imagee = await http.get(Uri.parse(imageLink));

      price = screen.body
          .split("class=\"a-offscreen\"\>USD")[1]
          .split("<\/")[0]
          .replaceAll(',', '');
      print("PRICE $price");

      image = MemoryImage(
        imagee.bodyBytes,
      );

      var descriptionOriginal = await http.get(Uri.parse(originalUrl));

      itemDescription = descriptionOriginal.body
          .split("product-title-word-break\"\>")[1]
          .split("\<\/")[0]
          .trim();
    } catch (e) {
      // showErrorBottomsheet(
      //   Localization.of(context, 'invalid_link'),
      // );
      print(e);
    }

    setState(() {});
  }

  Future<void> _loadIkea() async {
    var url = _productLinkController.text;

    print(url);

    try {
      image = null;
      imageLink = null;
      price = null;
      itemDescription = null;
      var screen = await http.get(Uri.parse(url), headers: {
        "Content-Language": "en",
        // "cookie":
        // "xman_t=uCXGeTajsChq1zocFti5q1k6fZ/ef5Z3e9MAKG6Zq3zFtXivMtdeyP6fXLnmxl3X; xman_f=Kq1gECXbfYZp2+LHF4728YjcTCJqSRSU6j15emwgj9DRrBuPg16xOMB4c6AjbacaTl5rWEzNeU1h9LcrrQWqAem2FHaBUYZPna1p79MYutfVR38CE7OxFw==; cna=N+iiHdMPJFUCAblhXHxVztzC; xlly_s=1; ali_apache_id=33.1.244.156.1696334375712.039905.6; acs_usuc_t=x_csrf=nywdm9jyyvm3&acs_rt=30cf6bf409f143d6bca5923ad7812197; aeu_cid=b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor; traffic_se_co=%7B%22src%22%3A%22Google%22%2C%22timestamp%22%3A1696334387575%7D; af_ss_a=1; af_ss_b=1; e_id=pt100; _gid=GA1.2.1806542863.1696334390; _gcl_au=1.1.1842478091.1696334391; XSRF-TOKEN=1182f1e0-6227-4172-9e06-805eddd8f930; _gac_UA-17640202-1=1.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _gcl_aw=GCL.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _ym_uid=1696334400247532736; _ym_d=1696334400; _ym_isad=2; AB_DATA_TRACK=450145_617386; AB_ALG=; AB_STG=st_StrategyExp_1694492533501%23stg_687; ali_apache_track=; ali_apache_tracktmp=; _fbp=fb.1.1696359035617.1228727340; RT=\"z=1&dm=aliexpress.com&si=067620ff-c624-47ae-be60-44f4fc6ce2bd&ss=lnap3p21&sl=2&tt=3gi&rl=1&obo=1&ld=x9de&r=1ceb9ekj&ul=x9df&hd=x9dg\"; aep_history=keywords%5E%0Akeywords%09%0A%0Aproduct_selloffer%5E%0Aproduct_selloffer%091005006058768832%091005006058753920%091005006084190108%091005006058797681%091005003609706446%091005005614102888; intl_locale=de_DE; _ym_visorc=b; _m_h5_tk=9e69a87b459aadb5f609153fec2415ff_1696366684726; _m_h5_tk_enc=eb38b8bfc39b43b97b30f2b61705683f; JSESSIONID=359D57CF431A76E3F700EF829E45C534; AKA_A2=A; intl_common_forever=ZFHIR9CDfmspVPJHXKAXdfzdQP6dhXWnKwSZh2zR1AZsIhdlpsQiPg==; _ga_VED1YSGNC7=GS1.1.1696362302.4.1.1696364354.57.0.0; _ga=GA1.1.736258735.1696334390; cto_bundle=hBxs7V9DbUVNT0FrOFRya3k4cHklMkZoUWlPV3o2SCUyQkNzQ2p5R1dubVBiUTkwR0RHQkhQeVExN0psTk94Mng5QWVqUk4zaWRiUTlHVVI2V0ZwY1RvWHk1a2FKRHZVR1dDSlBGV0Nvcmc0eWlPdE5FRTc5NHRXTGJ0ZUhPWXolMkZNTEl1WFpQdWR5amtGSDdpbTYwJTJGZEltemFJV09jVDd6eW95SUxIeXYlMkY4V25uNEx6QVdWbnNkTzJuMkp4Qk1MazBnYTFNOXM1TmUlMkJpS3NQU3lXUWpqb2FpdnhWQ0ZnJTNEJTNE; aep_usuc_f=site=deu&c_tp=USD&region=LB&b_locale=de_DE; tfstk=djpXR3wcLFpPjPOA_liyO8WR8EX1hEMFWls9xhe4XtBAfR_W5O-qmR-O6e-g313c3dTWuHdVgtCv23IFXNFAXsIReGjaWPe9Xls9zUL1smbNWNTwXIorLv-DmOX9f2kEL-vYc9mnY0e92L6GB2uEnCFDEOYICPSRXhZg0z4Jfzw7eJ2PkkfTZwsMFi1-LnQR61mNVs_pDagKJOPQLwaR05Z5tRs580i7s54VqjvR.; l=fBanFBCrPPVU1yo2BO5Zlurza77OzIdfGsPzaNbMiIEGa6KcaFNtpNCtpu39udtjQTfv-etPt6A1OdhW7bU3WxOVMRdEm7a7Txv9-iRLS45..; isg=BMTEvuYsfasiRMngdG5feOBFlUS23ehHWAHa4d5kgA9SCWDTBu5C1pjrSbnRESCf; xman_us_f=x_l=1&x_locale=de_DE&x_c_chg=0&acs_rt=30cf6bf409f143d6bca5923ad7812197&x_as_i=%7B%22aeuCID%22%3A%22b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor%22%2C%22af%22%3A%22CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE%22%2C%22affiliateKey%22%3A%22_DlqYSor%22%2C%22channel%22%3A%22AFFILIATE%22%2C%22cv%22%3A%221%22%2C%22isCookieCache%22%3A%22N%22%2C%22ms%22%3A%221%22%2C%22pid%22%3A%222791977130%22%2C%22tagtime%22%3A1696334387594%7D",
      });

      if (isEmpty(screen.body)) return;

      imageLink = screen.body
          .split(
              "pip-aspect-ratio-box pip-aspect-ratio-box--square pip-media-grid__media-image pip-media-grid__media-image--main")[1]
          .split("src=\"")[1]
          .split("\" ")[0];

      var imagee = await http.get(Uri.parse(imageLink));

      print("IMAGE TITLE");
      try {
        itemDescription = screen.body.split("title\>")[1].split("\<")[0];
      } catch (e) {}

      image = MemoryImage(
        imagee.bodyBytes,
        // fit: BoxFit.fill,
      );
    } catch (e) {
      print(e);
    }

    setState(() {});
  }

  Future<void> _loadTheGivingMovement() async {
    var originalUrl = _productLinkController.text;
    var url = _productLinkController.text;

    if (url.contains("https://ar.")) {
      url = url.replaceAll("https://ar.", "https://");
    }

    print(url);

    try {
      image = null;
      imageLink = null;
      price = null;
      itemDescription = null;
      var screen = await http.get(Uri.parse(url), headers: {
        "Content-Language": "en",
        // "cookie":
        // "xman_t=uCXGeTajsChq1zocFti5q1k6fZ/ef5Z3e9MAKG6Zq3zFtXivMtdeyP6fXLnmxl3X; xman_f=Kq1gECXbfYZp2+LHF4728YjcTCJqSRSU6j15emwgj9DRrBuPg16xOMB4c6AjbacaTl5rWEzNeU1h9LcrrQWqAem2FHaBUYZPna1p79MYutfVR38CE7OxFw==; cna=N+iiHdMPJFUCAblhXHxVztzC; xlly_s=1; ali_apache_id=33.1.244.156.1696334375712.039905.6; acs_usuc_t=x_csrf=nywdm9jyyvm3&acs_rt=30cf6bf409f143d6bca5923ad7812197; aeu_cid=b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor; traffic_se_co=%7B%22src%22%3A%22Google%22%2C%22timestamp%22%3A1696334387575%7D; af_ss_a=1; af_ss_b=1; e_id=pt100; _gid=GA1.2.1806542863.1696334390; _gcl_au=1.1.1842478091.1696334391; XSRF-TOKEN=1182f1e0-6227-4172-9e06-805eddd8f930; _gac_UA-17640202-1=1.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _gcl_aw=GCL.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _ym_uid=1696334400247532736; _ym_d=1696334400; _ym_isad=2; AB_DATA_TRACK=450145_617386; AB_ALG=; AB_STG=st_StrategyExp_1694492533501%23stg_687; ali_apache_track=; ali_apache_tracktmp=; _fbp=fb.1.1696359035617.1228727340; RT=\"z=1&dm=aliexpress.com&si=067620ff-c624-47ae-be60-44f4fc6ce2bd&ss=lnap3p21&sl=2&tt=3gi&rl=1&obo=1&ld=x9de&r=1ceb9ekj&ul=x9df&hd=x9dg\"; aep_history=keywords%5E%0Akeywords%09%0A%0Aproduct_selloffer%5E%0Aproduct_selloffer%091005006058768832%091005006058753920%091005006084190108%091005006058797681%091005003609706446%091005005614102888; intl_locale=de_DE; _ym_visorc=b; _m_h5_tk=9e69a87b459aadb5f609153fec2415ff_1696366684726; _m_h5_tk_enc=eb38b8bfc39b43b97b30f2b61705683f; JSESSIONID=359D57CF431A76E3F700EF829E45C534; AKA_A2=A; intl_common_forever=ZFHIR9CDfmspVPJHXKAXdfzdQP6dhXWnKwSZh2zR1AZsIhdlpsQiPg==; _ga_VED1YSGNC7=GS1.1.1696362302.4.1.1696364354.57.0.0; _ga=GA1.1.736258735.1696334390; cto_bundle=hBxs7V9DbUVNT0FrOFRya3k4cHklMkZoUWlPV3o2SCUyQkNzQ2p5R1dubVBiUTkwR0RHQkhQeVExN0psTk94Mng5QWVqUk4zaWRiUTlHVVI2V0ZwY1RvWHk1a2FKRHZVR1dDSlBGV0Nvcmc0eWlPdE5FRTc5NHRXTGJ0ZUhPWXolMkZNTEl1WFpQdWR5amtGSDdpbTYwJTJGZEltemFJV09jVDd6eW95SUxIeXYlMkY4V25uNEx6QVdWbnNkTzJuMkp4Qk1MazBnYTFNOXM1TmUlMkJpS3NQU3lXUWpqb2FpdnhWQ0ZnJTNEJTNE; aep_usuc_f=site=deu&c_tp=USD&region=LB&b_locale=de_DE; tfstk=djpXR3wcLFpPjPOA_liyO8WR8EX1hEMFWls9xhe4XtBAfR_W5O-qmR-O6e-g313c3dTWuHdVgtCv23IFXNFAXsIReGjaWPe9Xls9zUL1smbNWNTwXIorLv-DmOX9f2kEL-vYc9mnY0e92L6GB2uEnCFDEOYICPSRXhZg0z4Jfzw7eJ2PkkfTZwsMFi1-LnQR61mNVs_pDagKJOPQLwaR05Z5tRs580i7s54VqjvR.; l=fBanFBCrPPVU1yo2BO5Zlurza77OzIdfGsPzaNbMiIEGa6KcaFNtpNCtpu39udtjQTfv-etPt6A1OdhW7bU3WxOVMRdEm7a7Txv9-iRLS45..; isg=BMTEvuYsfasiRMngdG5feOBFlUS23ehHWAHa4d5kgA9SCWDTBu5C1pjrSbnRESCf; xman_us_f=x_l=1&x_locale=de_DE&x_c_chg=0&acs_rt=30cf6bf409f143d6bca5923ad7812197&x_as_i=%7B%22aeuCID%22%3A%22b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor%22%2C%22af%22%3A%22CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE%22%2C%22affiliateKey%22%3A%22_DlqYSor%22%2C%22channel%22%3A%22AFFILIATE%22%2C%22cv%22%3A%221%22%2C%22isCookieCache%22%3A%22N%22%2C%22ms%22%3A%221%22%2C%22pid%22%3A%222791977130%22%2C%22tagtime%22%3A1696334387594%7D",
      });

      if (isEmpty(screen.body)) return;

      var variant = _productLinkController.text.contains("variant")
          ? _productLinkController.text.split("variant=")[1]
          : null;

      imageLink = (_productLinkController.text.contains("variant") &&
              screen.body.contains("\"id\":\"$variant\",\"image\":{\"src\":\""))
          ? ("https://" +
              screen.body
                  .split("\"id\":\"$variant\",\"image\":{\"src\":\"")[1]
                  .split("\"}")[0]
                  .replaceAll("\\", "")
                  .replaceAll("//", ""))
          : screen.body.split("og:image\" content=\"")[1].split("\"")[0];

      var imagee = await http.get(Uri.parse(imageLink));

      print("IMAGE TITLE");
      try {
        var description = await http.get(Uri.parse(originalUrl), headers: {
          "Content-Language": "en",
          // "cookie":
          // "xman_t=uCXGeTajsChq1zocFti5q1k6fZ/ef5Z3e9MAKG6Zq3zFtXivMtdeyP6fXLnmxl3X; xman_f=Kq1gECXbfYZp2+LHF4728YjcTCJqSRSU6j15emwgj9DRrBuPg16xOMB4c6AjbacaTl5rWEzNeU1h9LcrrQWqAem2FHaBUYZPna1p79MYutfVR38CE7OxFw==; cna=N+iiHdMPJFUCAblhXHxVztzC; xlly_s=1; ali_apache_id=33.1.244.156.1696334375712.039905.6; acs_usuc_t=x_csrf=nywdm9jyyvm3&acs_rt=30cf6bf409f143d6bca5923ad7812197; aeu_cid=b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor; traffic_se_co=%7B%22src%22%3A%22Google%22%2C%22timestamp%22%3A1696334387575%7D; af_ss_a=1; af_ss_b=1; e_id=pt100; _gid=GA1.2.1806542863.1696334390; _gcl_au=1.1.1842478091.1696334391; XSRF-TOKEN=1182f1e0-6227-4172-9e06-805eddd8f930; _gac_UA-17640202-1=1.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _gcl_aw=GCL.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _ym_uid=1696334400247532736; _ym_d=1696334400; _ym_isad=2; AB_DATA_TRACK=450145_617386; AB_ALG=; AB_STG=st_StrategyExp_1694492533501%23stg_687; ali_apache_track=; ali_apache_tracktmp=; _fbp=fb.1.1696359035617.1228727340; RT=\"z=1&dm=aliexpress.com&si=067620ff-c624-47ae-be60-44f4fc6ce2bd&ss=lnap3p21&sl=2&tt=3gi&rl=1&obo=1&ld=x9de&r=1ceb9ekj&ul=x9df&hd=x9dg\"; aep_history=keywords%5E%0Akeywords%09%0A%0Aproduct_selloffer%5E%0Aproduct_selloffer%091005006058768832%091005006058753920%091005006084190108%091005006058797681%091005003609706446%091005005614102888; intl_locale=de_DE; _ym_visorc=b; _m_h5_tk=9e69a87b459aadb5f609153fec2415ff_1696366684726; _m_h5_tk_enc=eb38b8bfc39b43b97b30f2b61705683f; JSESSIONID=359D57CF431A76E3F700EF829E45C534; AKA_A2=A; intl_common_forever=ZFHIR9CDfmspVPJHXKAXdfzdQP6dhXWnKwSZh2zR1AZsIhdlpsQiPg==; _ga_VED1YSGNC7=GS1.1.1696362302.4.1.1696364354.57.0.0; _ga=GA1.1.736258735.1696334390; cto_bundle=hBxs7V9DbUVNT0FrOFRya3k4cHklMkZoUWlPV3o2SCUyQkNzQ2p5R1dubVBiUTkwR0RHQkhQeVExN0psTk94Mng5QWVqUk4zaWRiUTlHVVI2V0ZwY1RvWHk1a2FKRHZVR1dDSlBGV0Nvcmc0eWlPdE5FRTc5NHRXTGJ0ZUhPWXolMkZNTEl1WFpQdWR5amtGSDdpbTYwJTJGZEltemFJV09jVDd6eW95SUxIeXYlMkY4V25uNEx6QVdWbnNkTzJuMkp4Qk1MazBnYTFNOXM1TmUlMkJpS3NQU3lXUWpqb2FpdnhWQ0ZnJTNEJTNE; aep_usuc_f=site=deu&c_tp=USD&region=LB&b_locale=de_DE; tfstk=djpXR3wcLFpPjPOA_liyO8WR8EX1hEMFWls9xhe4XtBAfR_W5O-qmR-O6e-g313c3dTWuHdVgtCv23IFXNFAXsIReGjaWPe9Xls9zUL1smbNWNTwXIorLv-DmOX9f2kEL-vYc9mnY0e92L6GB2uEnCFDEOYICPSRXhZg0z4Jfzw7eJ2PkkfTZwsMFi1-LnQR61mNVs_pDagKJOPQLwaR05Z5tRs580i7s54VqjvR.; l=fBanFBCrPPVU1yo2BO5Zlurza77OzIdfGsPzaNbMiIEGa6KcaFNtpNCtpu39udtjQTfv-etPt6A1OdhW7bU3WxOVMRdEm7a7Txv9-iRLS45..; isg=BMTEvuYsfasiRMngdG5feOBFlUS23ehHWAHa4d5kgA9SCWDTBu5C1pjrSbnRESCf; xman_us_f=x_l=1&x_locale=de_DE&x_c_chg=0&acs_rt=30cf6bf409f143d6bca5923ad7812197&x_as_i=%7B%22aeuCID%22%3A%22b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor%22%2C%22af%22%3A%22CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE%22%2C%22affiliateKey%22%3A%22_DlqYSor%22%2C%22channel%22%3A%22AFFILIATE%22%2C%22cv%22%3A%221%22%2C%22isCookieCache%22%3A%22N%22%2C%22ms%22%3A%221%22%2C%22pid%22%3A%222791977130%22%2C%22tagtime%22%3A1696334387594%7D",
        });
        itemDescription =
            description.body.split("og:title\" content=\"")[1].split("\"")[0];
      } catch (e) {}

      price = ((num.tryParse(screen.body
                      .split("og:price:amount\" content=\"")[1]
                      .split("\"")[0]
                      .replaceAll(',', '')) ??
                  1) /
              num.tryParse(_controller.aedConversion ?? "3.67")!)
          .toStringAsFixed(2);
      print("PRICE $price");

      image = MemoryImage(
        imagee.bodyBytes,
        // fit: BoxFit.fill,
      );
    } catch (e) {
      // showErrorBottomsheet(
      //   Localization.of(context, 'invalid_link'),
      // );
      print(e);
    }

    setState(() {});
  }

  Future<void> _loadAliExpressImage() async {
    var originalUrl = _productLinkController.text;
    var url = _productLinkController.text;

    try {
      image = null;
      imageLink = null;
      price = null;
      itemDescription = null;
      var screen = await http.get(Uri.parse(url), headers: {
        "Content-Language": "en-US",
        "cookie":
            "xman_t=uCXGeTajsChq1zocFti5q1k6fZ/ef5Z3e9MAKG6Zq3zFtXivMtdeyP6fXLnmxl3X; xman_f=Kq1gECXbfYZp2+LHF4728YjcTCJqSRSU6j15emwgj9DRrBuPg16xOMB4c6AjbacaTl5rWEzNeU1h9LcrrQWqAem2FHaBUYZPna1p79MYutfVR38CE7OxFw==; cna=N+iiHdMPJFUCAblhXHxVztzC; xlly_s=1; ali_apache_id=33.1.244.156.1696334375712.039905.6; acs_usuc_t=x_csrf=nywdm9jyyvm3&acs_rt=30cf6bf409f143d6bca5923ad7812197; aeu_cid=b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor; traffic_se_co=%7B%22src%22%3A%22Google%22%2C%22timestamp%22%3A1696334387575%7D; af_ss_a=1; af_ss_b=1; e_id=pt100; _gid=GA1.2.1806542863.1696334390; _gcl_au=1.1.1842478091.1696334391; XSRF-TOKEN=1182f1e0-6227-4172-9e06-805eddd8f930; _gac_UA-17640202-1=1.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _gcl_aw=GCL.1696334400.CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE; _ym_uid=1696334400247532736; _ym_d=1696334400; _ym_isad=2; AB_DATA_TRACK=450145_617386; AB_ALG=; AB_STG=st_StrategyExp_1694492533501%23stg_687; ali_apache_track=; ali_apache_tracktmp=; _fbp=fb.1.1696359035617.1228727340; RT=\"z=1&dm=aliexpress.com&si=067620ff-c624-47ae-be60-44f4fc6ce2bd&ss=lnap3p21&sl=2&tt=3gi&rl=1&obo=1&ld=x9de&r=1ceb9ekj&ul=x9df&hd=x9dg\"; aep_history=keywords%5E%0Akeywords%09%0A%0Aproduct_selloffer%5E%0Aproduct_selloffer%091005006058768832%091005006058753920%091005006084190108%091005006058797681%091005003609706446%091005005614102888; intl_locale=de_DE; _ym_visorc=b; _m_h5_tk=9e69a87b459aadb5f609153fec2415ff_1696366684726; _m_h5_tk_enc=eb38b8bfc39b43b97b30f2b61705683f; JSESSIONID=359D57CF431A76E3F700EF829E45C534; AKA_A2=A; intl_common_forever=ZFHIR9CDfmspVPJHXKAXdfzdQP6dhXWnKwSZh2zR1AZsIhdlpsQiPg==; _ga_VED1YSGNC7=GS1.1.1696362302.4.1.1696364354.57.0.0; _ga=GA1.1.736258735.1696334390; cto_bundle=hBxs7V9DbUVNT0FrOFRya3k4cHklMkZoUWlPV3o2SCUyQkNzQ2p5R1dubVBiUTkwR0RHQkhQeVExN0psTk94Mng5QWVqUk4zaWRiUTlHVVI2V0ZwY1RvWHk1a2FKRHZVR1dDSlBGV0Nvcmc0eWlPdE5FRTc5NHRXTGJ0ZUhPWXolMkZNTEl1WFpQdWR5amtGSDdpbTYwJTJGZEltemFJV09jVDd6eW95SUxIeXYlMkY4V25uNEx6QVdWbnNkTzJuMkp4Qk1MazBnYTFNOXM1TmUlMkJpS3NQU3lXUWpqb2FpdnhWQ0ZnJTNEJTNE; aep_usuc_f=site=deu&c_tp=USD&region=LB&b_locale=de_DE; tfstk=djpXR3wcLFpPjPOA_liyO8WR8EX1hEMFWls9xhe4XtBAfR_W5O-qmR-O6e-g313c3dTWuHdVgtCv23IFXNFAXsIReGjaWPe9Xls9zUL1smbNWNTwXIorLv-DmOX9f2kEL-vYc9mnY0e92L6GB2uEnCFDEOYICPSRXhZg0z4Jfzw7eJ2PkkfTZwsMFi1-LnQR61mNVs_pDagKJOPQLwaR05Z5tRs580i7s54VqjvR.; l=fBanFBCrPPVU1yo2BO5Zlurza77OzIdfGsPzaNbMiIEGa6KcaFNtpNCtpu39udtjQTfv-etPt6A1OdhW7bU3WxOVMRdEm7a7Txv9-iRLS45..; isg=BMTEvuYsfasiRMngdG5feOBFlUS23ehHWAHa4d5kgA9SCWDTBu5C1pjrSbnRESCf; xman_us_f=x_l=1&x_locale=de_DE&x_c_chg=0&acs_rt=30cf6bf409f143d6bca5923ad7812197&x_as_i=%7B%22aeuCID%22%3A%22b22a47b58e9345079e335d1b850462e2-1696334387594-03599-_DlqYSor%22%2C%22af%22%3A%22CjwKCAjw9-6oBhBaEiwAHv1QvGhlIfkbK6SYgSUWJ5s3jsq7FliE1_5y6ihnm8R-trxaTay6nkgCzxoCIbMQAvD_BwE%22%2C%22affiliateKey%22%3A%22_DlqYSor%22%2C%22channel%22%3A%22AFFILIATE%22%2C%22cv%22%3A%221%22%2C%22isCookieCache%22%3A%22N%22%2C%22ms%22%3A%221%22%2C%22pid%22%3A%222791977130%22%2C%22tagtime%22%3A1696334387594%7D",
      });

      if (isEmpty(screen.body)) return;

      imageLink = screen.body.split("og:image\" content=\"")[1].split("\"")[0];
      var imagee = await http.get(Uri.parse(
          screen.body.split("og:image\" content=\"")[1].split("\"")[0]));

      print(screen.body.split("og:image\" content=\"")[1].split("\"")[0]);
      print("IMAGE TITLE");
      try {
        var descriptionInOriginalLanguage =
            await http.get(Uri.parse(originalUrl));

        itemDescription = descriptionInOriginalLanguage.body
            .split("\"seoTitle\":\"")[1]
            .split("\"")[0];
      } catch (e) {}

      // price = screen.body
      //     .split("formatedAmount\\\":\\\"US \$")[1]
      //     .split("\\")[0]
      //     ?.replaceAll(',', '');
      // print("PRICE $price");

      image = MemoryImage(
        imagee.bodyBytes,
        // fit: BoxFit.fill,
      );
    } catch (e) {
      // showErrorBottomsheet(
      //   Localization.of(context, 'invalid_link'),
      // );
      print(e);
    }

    setState(() {});
  }

  Future<void> _loadAliBaba() async {
    var originalUrl = _productLinkController.text;

    var url = _productLinkController.text;
    image = null;
    imageLink = null;
    price = null;
    itemDescription = null;
    var screen;
    try {
      screen = await http.get(Uri.parse(url), headers: {
        "Content-Language": "en_US",
        "accept-language": "en_US",
        "Cookie":
            "__wpkreporterwid_=0d87cb9c-9254-486c-32aa-50c60fc91224; ali_apache_id=33.1.238.182.1696359118444.277411.2; cookie2=a5fd6d80e2d16a676ba62a092c7ebe9d; t=4e42a29e8ad86079bebfb773768ca45f; _tb_token_=35e37bf5e5745; xlly_s=1; cna=N+iiHdMPJFUCAblhXHxVztzC; xman_us_f=x_l=0; acs_usuc_t=acs_rt=93d30ffb41aa43a6aae600c699c1dfde; _csrf_token=1696359174720; xman_t=IvWpoP/DMEswhMTT7U/GRs+6Yc4IMApptyFxHbFoLnF109Ox6AycBf0eTyX/W5v7coj41KXDstvyPlgxRIBKyXgu4wSmqGV8gx8Ct3TMFQI=; _m_h5_tk=2f6f118984ad4db5ca6f2d801756c8b6_1696368959607; _m_h5_tk_enc=226161ec66611319371852b52d86b8dc; _samesite_flag_=true; uns_unc_f=trfc_i=ppc^3rr1g6rm^^1hbre94nc; _ga=GA1.1.369562700.1696359318; icbu_s_tag=9_11; xman_f=VGWBBE2t2kfZmh8tAXTLmqDIanBdRCBu9aNi52BI9RuLfK9oqFrg4AMFZHcebbyB0Z/m1SilBgIBnzp1f2pX+L98jiW27ZrLX0VHHyFbskeT4M4et5mQJg==; ali_apache_track="
                "; ali_apache_tracktmp="
                "; sc_g_cfg_f=sc_b_site=US&sc_b_locale=en_US&sc_b_currency=USD; XSRF-TOKEN=7d684ef4-ab7d-45e5-ac22-e160e4805b57; _ga_GKMVMVMZNM=GS1.1.1696365709.2.1.1696365776.0.0.0; JSESSIONID=79D5F2267DE1FD2449F60E01C9F00F76; l=fBOFSc1mPPMZ_uj3BOfZourza77TkIRfguPzaNbMi9fP9BWW5D8hW1HLDR-XCnMNe6opR35htC1BBfTOvPRp2fPhSbJrTYFI3dIvEn3A.; isg=BBYWp2Swb_2gvFtZ0gaEfKrIZ8oYt1rxXvsoP4B_fvmUQ7fd6EVcATY928eva1IJ; ug_se_c=organic_1696365784086; tfstk=dUNwzjwDxjqQzPsICAl4zHNtTbltBbI5mSijor4m5cmGBxGq3lZxnNEbCxl40ok01fa_Yr44vS91XmNEuualWPZjsqfnAz0b5Pa6gxmQcR_thiFe3oavGAV4kIu0ooQtcNBQWPhxigs73_aTWI69FRyvAymmQjj5V_1OLdFIiR12cpBzLuve9tkXqzo31wl1PNfmSDRDaH3ZIR5-xIA4TVzEqO7wD2qHoSewmKkiJ2o58wRyHwwP."
      });
    } catch (e) {
      // showErrorBottomsheet(
      //   Localization.of(context, 'invalid_link'),
      // );
    }

    if (isEmpty(screen?.body)) return;

    try {
      var imagee = await http
          .get(Uri.parse(screen.body.split("\"image\": \"")[1].split("\"")[0]));

      imageLink = screen.body.split("\"image\": \"")[1].split("\"")[0];

      image = MemoryImage(
        imagee.bodyBytes,
        // fit: BoxFit.fill,
      );
    } catch (e) {}

    try {
      var descriptionInOriginalLanguage =
          await http.get(Uri.parse(originalUrl));
      itemDescription = descriptionInOriginalLanguage.body
          .split("\"subject\":\"")[1]
          .split("\"")[0];
    } catch (e) {}

    try {
      //TODO check split on ","
      // price = screen.body
      //     .split("priceRangeHigh\":")[1]
      //     .split(",")[0]
      //     .replaceAll(',', '');
      // print("PRICE1: $price");
    } catch (e) {
      try {
        // price = screen.body
        //     .split("productLadderPrices\":[{")[1]
        //     .split("}")[0]
        //     .split("dollarPrice\":")[1]
        //     .split(",")[0];
        // print("PRICE2: $price");
      } catch (e) {
        // showErrorBottomsheet(
        //   Localization.of(context, 'invalid_link'),
        // );
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameNode.dispose();
    quantityNode.dispose();
    colorNode.dispose();
    sizeNode.dispose();
    productLink.dispose();
    moreDetailsNode.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String hintText, {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: hintText,
      counterText: "",
      labelStyle: TextStyle(
        color: Colors.black,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      prefixIcon: prefixIcon,
    );
  }

  Widget layoutContainer({Widget? child}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(start: 0.0, end: 10.0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: KeyboardFormActions(
          keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
          nextFocus: false,
          keyboardBarColor: Colors.black54,
          actions: [
            KeyboardFormAction(
              focusNode: nameNode,
            ),
            KeyboardFormAction(
              focusNode: quantityNode,
            ),
            KeyboardFormAction(
              focusNode: colorNode,
            ),
            KeyboardFormAction(
              focusNode: sizeNode,
            ),
            KeyboardFormAction(
              focusNode: productLink,
            ),
            KeyboardFormAction(
              focusNode: moreDetailsNode,
            ),
          ],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        if (image != null &&
                            (!(widget.homeScreenController?.hideImage ?? true)))
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: (isLoading || image == null)
                                  ? BoxShape.circle
                                  : BoxShape.rectangle,
                              image: DecorationImage(
                                // fit: widget.fit ?? BoxFit.fill,
                                image: (isLoading || image == null)
                                    ? AssetImage(
                                        "assets/images/image_loading.gif")
                                    : image,
                              ),
                            ),
                          ),
                        // layoutContainer(
                        //   child: TextFormField(
                        //     textDirection:
                        //         (Localizations.localeOf(context).languageCode ==
                        //                 'ar'
                        //             ? TextDirection.rtl
                        //             : TextDirection.ltr),
                        //     enabled: false,
                        //     decoration: InputDecoration(
                        //       labelText: widget.user?.phoneNumber != null
                        //           ? _getPhoneNumberLabelText()
                        //           : "",
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
                        //       hintText:
                        //           Localization.of(context, 'phone_number'),
                        //       prefixIcon: Container(
                        //         child: Row(
                        //           mainAxisSize: MainAxisSize.min,
                        //           children: [
                        //             Padding(
                        //               padding: EdgeInsetsDirectional.only(
                        //                 start: 8,
                        //                 end: 8,
                        //               ),
                        //               child: Image.asset(
                        //                 CountryPickerUtils
                        //                     ?.getFlagImageAssetPath(
                        //                   selectedCountryIsoCode ?? "LB",
                        //                 ),
                        //                 height: 20.0,
                        //                 width: 35.0,
                        //                 package: "country_pickers",
                        //               ),
                        //             ),
                        //             // if (widget.user?.phoneNumber != null)
                        //             //   Padding(
                        //             //     padding:
                        //             //         EdgeInsetsDirectional.only(end: 2),
                        //             //     child: Text(
                        //             //       "+${selectedCountryPhoneCode ?? "961"}",
                        //             //       style: TextStyle(fontSize: 16),
                        //             //     ),
                        //             //   ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //     textAlign: TextAlign.start,
                        //   ),
                        // ),
                        SizedBox(
                          height: 18,
                        ),
                        layoutContainer(
                          child: TextFormField(
                            textDirection:
                                (Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr),
                            controller: _productLinkController,
                            enabled: !isLoading,
                            focusNode: productLink,
                            keyboardType: TextInputType.url,
                            onChanged: (value) async {
                              if (isEmpty(_productLinkController.text) ||
                                  ((_productLinkController.text.length) < 5))
                                return;
                              try {
                                setState(() {
                                  isLoading = true;
                                });
                                await _getProductImage();
                                setState(() {
                                  isLoading = false;
                                });
                              } catch (e) {
                                showErrorBottomsheet(
                                  Localization.of(
                                      context, 'an_error_has_occurred'),
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            autovalidateMode:
                                isEmpty(_productLinkController.text)
                                    ? null
                                    : AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value?.isEmpty ?? false) {
                                return Localization.of(
                                  context,
                                  'link_cannot_be_empty',
                                );
                              }
                              return null;
                            },
                            // maxLength: 8,
                            decoration: inputDecoration(
                              Localization.of(context, 'product_link'),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        layoutContainer(
                          child: TextFormField(
                            textDirection:
                                (Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr),
                            controller: _quantityController,
                            // enabled: !isLoading,
                            focusNode: quantityNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[0-9]"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                amount = value;
                              });
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? false) {
                                return Localization.of(
                                  context,
                                  'quantity_cannot_be_empty',
                                );
                              }
                              return null;
                            },
                            maxLength: 8,
                            decoration: inputDecoration(
                              Localization.of(context, 'quantity_s'),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        layoutContainer(
                          child: TextFormField(
                            textDirection:
                                (Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr),
                            controller: _colorController,
                            focusNode: colorNode,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                    r"[a-zA-Z0-9 .,()-_!?@+=;:$')*+-./<>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"),
                              ),
                            ],
                            decoration: inputDecoration(
                              Localization.of(context, 'color_s'),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        layoutContainer(
                          child: TextFormField(
                            textDirection:
                                (Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr),
                            controller: _sizeController,
                            focusNode: sizeNode,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                    r"[a-zA-Z0-9 .,()-_!?@+=;:$')*+-./<>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"),
                              ),
                            ],
                            decoration: inputDecoration(
                              Localization.of(context, 'size_s'),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        // layoutContainer(
                        //   child: WKTextField(
                        //     key: Key('search_by_minable_item_name'),
                        //     hintText: Localization.of(
                        //       context,
                        //       'more_details_about_your_order',
                        //     ),
                        //     hintTextSize: 14,
                        //     controller: _moreDetailsController,
                        //     focusNode: moreDetailsNode,
                        //     // enabled: !isLoading,
                        //     minLines: 3,
                        //     maxLines: 5,
                        //     maxLength: 150,
                        //     textAlign: TextAlign.start,
                        //     inputFormatters: [
                        //       FilteringTextInputFormatter.allow(
                        //         RegExp(
                        //             r"[a-zA-Z0-9 .,()-_!?@+=;:!$'()*+-./:<=>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Center(
                          child: Padding(
                            key: _addToCart,
                            padding: EdgeInsets.symmetric(
                              horizontal: 62,
                              vertical: 16,
                            ),
                            child: RaisedButtonV2(
                              // buttonKey: _addToCart,
                              disabled: isLoading,
                              isLoading: isLoading,
                              onPressed: () async {
                                if (!(widget.homeScreenController?.isBanned ??
                                    false)) {
                                  if (_formKey.currentState!.validate()) {
                                    // if (widget.user?.phoneNumber == null) {
                                    //   showErrorBottomsheet(
                                    //     Localization.of(
                                    //       context,
                                    //       'please_login_to_use_this_feature',
                                    //     ),
                                    //   );
                                    // } else {
                                    // if (!(widget.homeScreenController.isAdmin) &&
                                    //     widget.homeScreenController.showCustomError) {
                                    //   await showActionBottomSheet(
                                    //     context: context,
                                    //     status: OperationStatus.error,
                                    //     message:
                                    //         (Localizations.localeOf(context)
                                    //                     .languageCode ==
                                    //                 'ar')
                                    //             ? widget.homeScreenController.customErrorAR
                                    //             : widget.homeScreenController.customError,
                                    //     popOnPress: true,
                                    //     dismissOnTouchOutside: false,
                                    //     buttonMessage: Localization.of(
                                    //       context,
                                    //       'ok',
                                    //     ),
                                    //     onPressed: () {
                                    //       Navigator.of(context).pop();
                                    //     },
                                    //   );
                                    //   return;
                                    // }
                                    //
                                    // if (!(widget.homeScreenController.isAdmin) &&
                                    //     widget.homeScreenController.isHoliday) {
                                    //   await showActionBottomSheet(
                                    //     context: context,
                                    //     status: OperationStatus.error,
                                    //     message: Localization.of(
                                    //       context,
                                    //       'we_are_currently_closed',
                                    //     ),
                                    //     popOnPress: true,
                                    //     dismissOnTouchOutside: false,
                                    //     buttonMessage: Localization.of(
                                    //       context,
                                    //       'ok',
                                    //     ),
                                    //     onPressed: () {
                                    //       Navigator.of(context).pop();
                                    //     },
                                    //   );
                                    //   return;
                                    // }
                                    //
                                    // if (!(widget.homeScreenController.isAdmin) &&
                                    //     widget.homeScreenController.checkForOpeningHours) {
                                    //   DateTime currentDateTime =
                                    //       DateTime.now();
                                    //   String errorMsg = (widget.homeScreenController
                                    //                   .weekdayOpeningHours ==
                                    //               widget.homeScreenController
                                    //                   .weekendOpeningHours) &&
                                    //           (widget.homeScreenController
                                    //                   .weekdayClosingHours ==
                                    //               widget.homeScreenController
                                    //                   .weekendClosingHours)
                                    //       ? widget.homeScreenController.isSundayOff
                                    //           ? replaceVariable(
                                    //               replaceVariable(
                                    //                 Localization.of(
                                    //                   context,
                                    //                   'Our opening hours are Monday till Saturday from',
                                    //                 ),
                                    //                 'valueone',
                                    //                 widget.homeScreenController
                                    //                     .weekdayOpeningHours,
                                    //               ),
                                    //               'valuetwo',
                                    //               widget.homeScreenController
                                    //                   .weekdayClosingHours,
                                    //             )
                                    //           // 'Our opening hours are Monday till Saturday from ${widget.homeScreenController.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM.\n Please submit an order during our working hours.'
                                    //           : replaceVariable(
                                    //               replaceVariable(
                                    //                 Localization.of(
                                    //                   context,
                                    //                   'Our opening hours are everyday from',
                                    //                 ),
                                    //                 'valueone',
                                    //                 widget.homeScreenController
                                    //                     .weekdayOpeningHours,
                                    //               ),
                                    //               'valuetwo',
                                    //               widget.homeScreenController
                                    //                   .weekdayClosingHours,
                                    //             )
                                    //       // 'Our opening hours are everyday from ${widget.homeScreenController.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM. \nPlease submit an order during our working hours.'
                                    //       : widget.homeScreenController.isSundayOff
                                    //           ? replaceVariable(
                                    //               replaceVariable(
                                    //                 replaceVariable(
                                    //                   replaceVariable(
                                    //                     Localization.of(
                                    //                       context,
                                    //                       'Our opening hours are Monday till Friday from',
                                    //                     ),
                                    //                     'valueone',
                                    //                     _controller
                                    //                         .weekdayOpeningHours,
                                    //                   ),
                                    //                   'valuetwo',
                                    //                   _controller
                                    //                       .weekdayClosingHours,
                                    //                 ),
                                    //                 'valuethree',
                                    //                 _controller
                                    //                     .weekendOpeningHours,
                                    //               ),
                                    //               'valuefour',
                                    //               _controller
                                    //                   .weekendClosingHours,
                                    //             )
                                    //
                                    //           // 'Our opening hours are Monday till Friday from ${_controller.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM and Saturday from ${_controller.weekendOpeningHours}:00 AM till ${_controller.weekendClosingHours}:00 PM. \nPlease submit an order during our working hours.'
                                    //           : replaceVariable(
                                    //               replaceVariable(
                                    //                 replaceVariable(
                                    //                   replaceVariable(
                                    //                     Localization.of(
                                    //                       context,
                                    //                       'Our opening hours are Monday till Friday fromm',
                                    //                     ),
                                    //                     'valueone',
                                    //                     _controller
                                    //                         .weekdayOpeningHours,
                                    //                   ),
                                    //                   'valuetwo',
                                    //                   _controller
                                    //                       .weekdayClosingHours,
                                    //                 ),
                                    //                 'valuethree',
                                    //                 _controller
                                    //                     .weekendOpeningHours,
                                    //               ),
                                    //               'valuefour',
                                    //               _controller
                                    //                   .weekendClosingHours,
                                    //             );
                                    //   // 'Our opening hours are Monday till Friday from ${_controller.weekdayOpeningHours}:00 AM till ${_controller.weekdayClosingHours}:00 PM, Saturday and Sunday from ${_controller.weekendOpeningHours}:00 AM till ${_controller.weekendClosingHours}:00 PM. \nPlease submit an order during our working hours.';
                                    //   if ((currentDateTime.weekday) == 7 ||
                                    //       (currentDateTime.weekday) == 6) {
                                    //     if ((currentDateTime.weekday) == 7 &&
                                    //         _controller.isSundayOff) {
                                    //       await showActionBottomSheet(
                                    //         context: context,
                                    //         status: OperationStatus.error,
                                    //         message: errorMsg,
                                    //         popOnPress: true,
                                    //         dismissOnTouchOutside: false,
                                    //         buttonMessage:
                                    //             Localization.of(context, 'ok')
                                    //                 .toUpperCase(),
                                    //         onPressed: () {
                                    //           Navigator.of(context).pop();
                                    //         },
                                    //       );
                                    //       return;
                                    //     }
                                    //     if (currentDateTime.hour <
                                    //             int.tryParse(_controller
                                    //                 .weekendOpeningHours) ||
                                    //         currentDateTime.hour >=
                                    //             int.tryParse(_controller
                                    //                 .weekendClosingHours)) {
                                    //       await showActionBottomSheet(
                                    //         context: context,
                                    //         status: OperationStatus.error,
                                    //         message: errorMsg,
                                    //         popOnPress: true,
                                    //         dismissOnTouchOutside: false,
                                    //         buttonMessage: Localization.of(
                                    //           context,
                                    //           'ok',
                                    //         ).toUpperCase(),
                                    //         onPressed: () {
                                    //           Navigator.of(context).pop();
                                    //         },
                                    //       );
                                    //       return;
                                    //     }
                                    //   }
                                    //   if (currentDateTime.hour <
                                    //           int.tryParse(_controller
                                    //               .weekdayOpeningHours) ||
                                    //       currentDateTime.hour >=
                                    //           int.tryParse(_controller
                                    //               .weekdayClosingHours)) {
                                    //     await showActionBottomSheet(
                                    //       context: context,
                                    //       status: OperationStatus.error,
                                    //       message: errorMsg,
                                    //       popOnPress: true,
                                    //       dismissOnTouchOutside: false,
                                    //       buttonMessage: Localization.of(
                                    //         context,
                                    //         'ok',
                                    //       ).toUpperCase(),
                                    //       onPressed: () {
                                    //         Navigator.of(context).pop();
                                    //       },
                                    //     );
                                    //     return;
                                    //   }
                                    // }
                                    await showConfirmationBottomSheet(
                                      context: context,
                                      // flare: 'assets/flare/pending.flr',
                                      title: Localization.of(
                                        context,
                                        'are_you_sure_you_want_to_add_this_item_to_your_cart',
                                      ),
                                      message: isNotEmpty(_colorController.text) &&
                                              isNotEmpty(_sizeController.text)
                                          ? null
                                          : isEmpty(_colorController.text) &&
                                                  isEmpty(_sizeController.text)
                                              ? ((Localizations.localeOf(context)
                                                          .languageCode ==
                                                      'ar')
                                                  ? widget.homeScreenController
                                                      ?.nextTextAR
                                                  : widget.homeScreenController
                                                      ?.nextText)
                                              : (isNotEmpty(
                                                          _colorController.text)
                                                      ? ((Localizations.localeOf(context)
                                                                  .languageCode ==
                                                              'ar')
                                                          ? widget
                                                              .homeScreenController
                                                              ?.nextTextSizeAR
                                                          : widget
                                                              .homeScreenController
                                                              ?.nextTextSize)
                                                      : (Localizations.localeOf(context).languageCode ==
                                                              'ar')
                                                          ? widget
                                                              .homeScreenController
                                                              ?.nextTextColorAR
                                                          : widget
                                                              .homeScreenController
                                                              ?.nextTextColor)
                                                  ?.replaceAll(r'\n', '\n')
                                                  .replaceAll(r"\'", "\'"),
                                      confirmMessage:
                                          Localization.of(context, 'continue'),
                                      confirmAction: () async {
                                        // Navigator.of(context).pop();
                                        widget.homeScreenController
                                            ?.productsTitles
                                            .add(itemDescription ??
                                                Localization.of(
                                                    context, "product"));
                                        widget
                                            .homeScreenController?.productsLinks
                                            .add(_productLinkController.text);
                                        widget.homeScreenController
                                            ?.productsQuantities
                                            .add(_quantityController.text);
                                        widget.homeScreenController
                                            ?.productsColors
                                            .add(_colorController.text);
                                        widget
                                            .homeScreenController?.productsSizes
                                            .add(_sizeController.text);
                                        widget.homeScreenController
                                            ?.productsPrices
                                            .add(price ?? "0");
                                        widget.homeScreenController
                                            ?.productsImages
                                            .add(imageLink ?? "");

                                        _quantityController.text = "";
                                        _productLinkController.text = "";
                                        _moreDetailsController.text = "";
                                        _colorController.text = "";
                                        _sizeController.text = "";
                                        image = null;
                                        imageLink = null;
                                        price = null;
                                        itemDescription = null;

                                        widget.homeScreenController
                                            ?.refreshView();

                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        showSuccessBottomsheet();

                                        // if (widget.homeScreenController
                                        //         .productsTitles.length ==
                                        //     1) {
                                        //   widget.homeScreenController
                                        //       .jumpToCartScreen();
                                        // }

                                        try {
                                          Vibration.vibrate();
                                        } catch (e) {}

                                        setState(() {});
                                      },
                                      cancelMessage:
                                          Localization.of(context, 'cancel'),
                                    );
                                  }
                                }
                                // }
                              },
                              label: Localization.of(context, 'add_to_cart'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getProductImage() async {
    image = null;
    imageLink = null;
    price = null;
    itemDescription = null;

    if (isEmpty(_productLinkController.text)) return;

    _productLinkController.text = _productLinkController.text.trim();

    if (_productLinkController.text.contains("https://")) {
      _productLinkController.text =
          "https://" + _productLinkController.text.split("https://")[1];
    }

    var productImageLink = _productLinkController.text.toLowerCase();

    if (!(productImageLink.contains("https://"))) {
      _productLinkController.text = "https://" + productImageLink;
      productImageLink = "https://" + productImageLink;
    }

    if (productImageLink.contains("aliexpress")) {
      await _loadAliExpressImage();
    } else if (productImageLink.contains("alibaba")) {
      await _loadAliBaba();
    } else if (productImageLink.contains("thegivingmovement")) {
      await _loadTheGivingMovement();
    } else if (productImageLink.contains("ikea")) {
      await _loadIkea();
    } else if (productImageLink.contains("sephora")) {
      await _loadSephora();
    } else if (((productImageLink.contains("amazon")) ||
        (productImageLink.contains("amzn.eu")) ||
        (productImageLink.contains("a.co")))) {
      await _loadAmazon();
    }
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
      dismissOnTouchOutside: false,
      height: MediaQuery.of(context).size.height * 0.27,
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 100,
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
                  message ?? Localization.of(context, 'add_to_cart_successful'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
      bottomWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: RaisedButtonV2(
              label: Localization.of(context, 'done'),
              onPressed: () async {
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  void showErrorBottomsheet(
    String error, {
    bool dismissOnTouchOutside = true,
    bool showDoneButton = true,
    bool doublePop = false,
  }) async {
    if (!mounted) return;
    await showBottomSheetStatus(
      context: context,
      status: OperationStatus.error,
      message: error,
      popOnPress: true,
      dismissOnTouchOutside: dismissOnTouchOutside,
      showDoneButton: showDoneButton,
      onPressed: doublePop ? () => Navigator.of(context).pop() : null,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     height: MediaQuery.of(context).size.height - 210,
  //     child: SingleChildScrollView(
  //       physics: BouncingScrollPhysics(),
  //       dragStartBehavior: DragStartBehavior.down,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           // _search(),
  //           // _categoryWidget(),
  //           // _productWidget(),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
