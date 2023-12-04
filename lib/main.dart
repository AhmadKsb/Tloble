import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/config/route.dart';
import 'package:flutter_ecommerce_app/src/firebase_notification.dart';
import 'package:flutter_ecommerce_app/src/pages/mainPage.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/loader.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart'
    as localization;
import 'package:flutter_ecommerce_app/src/widgets/customRoute.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: false,
  );

  runApp(
    Phoenix(
      child: RestartWidget(
        child: MyApp(),
      ),
    ),
  );
}

class RestartWidget extends StatefulWidget {
  RestartWidget({
    this.child,
  });

  final Widget? child;

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}

class MyApp extends StatefulWidget {
  MyApp();

  static void setLocale(BuildContext context, Locale newLocale) async {
    MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale? _locale;
  PageState? _state;

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = PageState.loading;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? language = prefs.getString("tloble_language");
      _locale = (isNotEmpty(language) ? Locale(language!) : Locale('ar'));
      setState(() {
        _state = PageState.loaded;
      });
    } catch (e) {
      setState(() {
        _state = PageState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _state == PageState.loaded
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tloble',
            locale: _locale ?? Locale('ar'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              localization.LocalizationDelegate(), // Add this line
            ],
            supportedLocales:
                localization.LocalizationDelegate.supportedLocales,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: GoogleFonts.mulishTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            routes: Routes.getRoute(),
            onGenerateRoute: (RouteSettings settings) {
              // if (settings.name?.contains('detail') ?? false) {
              //   return CustomRoute<bool>(
              //       builder: (BuildContext context) => ProductDetailPage());
              // } else {
              return CustomRoute<bool>(
                  builder: (BuildContext context) =>
                      FirebaseNotification(child: MainPage()));
              // }
            },
            initialRoute: "MainPage",
          )
        : Container(
            color: Colors.white,
            child: Loader(),
          );
  }
}
