import 'dart:typed_data';

/// Returns [true] if [s] is either null or empty.
bool isEmpty(String? s) => s == null || s.isEmpty || s == 'null';

/// Returns [true] if [s] is a not null or empty string.
bool isNotEmpty(String? s) => s != null && s.isNotEmpty && s != 'null';

String formatBytesAsHexString(Uint8List bytes) {
  var result = StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

String? formatPhoneNumber(String? phoneNumber) =>
    phoneNumber?.replaceAll(" ", "");

Uint8List createUint8ListFromHexString(String hex) {
  var result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < hex.length; i += 2) {
    var num = hex.substring(i, i + 2);
    var byte = int.parse(num, radix: 16);
    result[i ~/ 2] = byte;
  }
  return result;
}

String getFormattedMessageOneFieldCurly(String text, String replace) =>
    (text.replaceFirst(RegExp(r"{(.+?)}"), replace));

int getLengthWithoutWhitespace(String text) =>
    text.replaceAll(RegExp(r"\s+\b|\b\s|\s|\b"), "").length;

bool isEmail(String em) {
  if (isEmpty(em)) return false;
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  RegExp regExp = new RegExp(p);

  return regExp.hasMatch(em);
}

String? replaceVariable(String? message, String variable, String value) {
  if (message == null) return null;
  return (message.replaceFirst('{$variable}', value)).replaceAll("\\n", "\n");
}

bool isNumeric(String value) {
  return RegExp(r"^[0-9]*$").hasMatch(value);
}

bool isEnglishAlphabetic(String value) {
  return RegExp(r"^[a-zA-Z]*$").hasMatch(value);
}

bool isEnglishAlphaNumeric(String value) {
  return RegExp(r"^[a-zA-Z0-9]*$").hasMatch(value);
}

String filteredPhoneNumber(String phone) {
  // print('un-filtered phone number: $phone');
  if (phone == null) return phone;
  List<String> invalid = [
    ' ',
    '.',
    ',',
    ';',
    '_',
    '-',
    '{',
    '}',
    '(',
    ')',
    '[',
    ']',
    '+968',
    '00968',
    '/',
    'N',
    '*',
    '+'
  ];
  invalid.forEach((check) {
    if (phone.contains(check)) {
      phone = phone.replaceAll(check, '');
    }
  });
  return phone;
}

String removeAllWhitespace(String value) {
  return value.replaceAll(' ', '');
}

String capitalize(String string) {
  if (string == null) {
    print("String is null");
    return '';
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

extension StringsExt on String {
  String maskedPhone([int? quantity]) {
    quantity ??= 3;
    String maskedPhone = '**********';
    if (this.length > quantity) {
      maskedPhone = List.generate(this.length - quantity, (index) => '*')
              .reduce((value, element) => value + element) +
          this.substring(this.length - 3);
    }
    return maskedPhone;
  }
}

//After submitting, you will be contacted by our team via whatsapp. \nFor orders within Beirut area, expect to be contacted within 2 hours, for orders outside Beirut, it might take up to 4 hours. If you weren\'t contacted within these time frames, please submit a new request. \n\nNote: You will gain points for every order done through this app.
