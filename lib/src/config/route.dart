import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/pages/mainPage.dart';

import '../firebase_notification.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => FirebaseNotification(child: MainPage()),
      // '/detail': (_) => ProductDetailPage()
    };
  }
}
