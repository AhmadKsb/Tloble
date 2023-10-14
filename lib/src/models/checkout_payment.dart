// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// class CheckoutPayment {
//   static const _tokenURL = "https://api.sandbox.checkout.com/tokens";
//   static const _paymentURL = "https://api.sandbox.checkout.com/payments";
//
//   static const String _publicKey =
//       "pk_test_28ff0388-0451-4d59-a92f-5b43f709248a";
//   static const String _secretKey =
//       "sk_test_5e7f2768-9147-405c-9317-aba93d67d2c3";
//
//   static const Map<String, String> _tokenHeader = {
//     'Content-Type': 'Application/json',
//     'Authorization': _publicKey,
//   };
//
//   static const Map<String, String> _paymentHeader = {
//     'Content-Type': 'Application/json',
//     'Authorization': _secretKey,
//   };
//
//   Future<String> _getToken(PaymentCard card) async {
//     Map<String, String> body = {
//       'type': 'card',
//       'name': card.name,
//       'number': card.number,
//       'cvv': card.cvv,
//       'expiry_month': card.expiryMonth,
//       'expiry_year': card.expiryYear,
//     };
//     http.Response response = await http.post(
//       Uri.parse(_tokenURL),
//       headers: _tokenHeader,
//       body: jsonEncode(body),
//     );
//
//     switch (response.statusCode) {
//       case 201:
//         var data = jsonDecode(response.body);
//         return data['token'];
//         break;
//       default:
//         throw Exception("Card Invalid");
//     }
//   }
//
//   Future<bool> makePayment(
//     PaymentCard card,
//     int amount,
//   ) async {
//     String token = await _getToken(card);
//     Map<String, dynamic> body = {
//       'source': {
//         'type': 'token',
//         'token': token,
//       },
//       'amount': amount,
//       'currency': 'usd',
//     };
//
//     http.Response response = await http.post(
//       Uri.parse(_paymentURL),
//       headers: _paymentHeader,
//       body: jsonEncode(body),
//     );
//
//     switch (response.statusCode) {
//       case 201:
//         var data = jsonDecode(response.body);
//         print(data['response_summary']);
//         return true;
//         break;
//       default:
//         throw Exception("Payment Failed");
//     }
//   }
// }
