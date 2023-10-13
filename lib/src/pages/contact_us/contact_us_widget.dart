library contactus;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/utils/string_util.dart';

///Class for adding contact details/profile details as a complete new page in your flutter app.
class ContactUs extends StatelessWidget {
  ///Logo of the Company/individual
  final BuildContext buildContext;
  final ImageProvider logo;

  ///Ability to add an image
  final Image image;

  ///Phone Number of the company/individual
  final String salesNumber;
  final String supportNumber;

  ///Text for Phonenumber
  final String phoneNumberText;

  ///Website of company/individual
  final String website;
  final String tiktok;

  ///Text for Website
  final String websiteText;

  ///Email ID of company/individual
  final String salesEmail;
  final String supportEmail;

  ///Text for Email
  final String emailText;

  ///Twitter Handle of Company/Individual
  final String twitterHandle;

  ///Facebook Handle of Company/Individual
  final String facebookHandle;

  ///Linkedin URL of company/individual
  final String linkedinURL;

  ///Github User Name of the company/individual
  final String githubUserName;

  ///Name of the Company/individual
  final String companyName;

  ///Font size of Company name
  final double companyFontSize;

  ///TagLine of the Company or Position of the individual
  final String tagLine;

  ///Instagram User Name of the company/individual
  final String instagram;
  final String telegram;

  ///TextColor of the text which will be displayed on the card.
  final Color textColor;

  ///Color of the Card.
  final Color cardColor;

  ///Color of the company/individual name displayed.
  final Color companyColor;

  ///Color of the tagLine of the Company/Individual to be displayed.
  final Color taglineColor;

  /// font of text
  final String textFont;

  /// font of the company/individul to be displayed
  final String companyFont;

  /// font of the tagline to be displayed
  final String taglineFont;

  /// divider color which is placed between the tagline & contact informations
  final Color dividerColor;

  /// divider thickness which is placed between the tagline & contact informations

  final double dividerThickness;

  ///font weight for tagline and company name
  final FontWeight companyFontWeight;
  final FontWeight taglineFontWeight;

  /// avatar radius will place the circularavatar according to developer/UI need
  final double avatarRadius;

  ///Constructor which sets all the values.
  ContactUs({
    this.buildContext,
    this.companyName,
    this.textColor,
    this.cardColor,
    this.companyColor,
    this.taglineColor,
    this.salesEmail,
    this.supportEmail,
    this.emailText,
    this.logo,
    this.image,
    this.salesNumber,
    this.supportNumber,
    this.phoneNumberText,
    this.website,
    this.tiktok,
    this.websiteText,
    this.twitterHandle,
    this.facebookHandle,
    this.linkedinURL,
    this.githubUserName,
    this.tagLine,
    this.instagram,
    this.telegram,
    this.companyFontSize,
    this.textFont,
    this.companyFont,
    this.taglineFont,
    this.dividerColor,
    this.companyFontWeight,
    this.taglineFontWeight,
    this.avatarRadius,
    this.dividerThickness,
  });

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 8.0,
          contentPadding: EdgeInsets.all(18.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    try {
                      launch('tel:' + salesNumber);
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Container(
                    height: 50.0,
                    alignment: Alignment.center,
                    child: Text(Localization.of(buildContext, 'call')),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    try {
                      launch('sms:' + salesNumber);
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Text(Localization.of(buildContext, 'message')),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    try {
                      launch('https://wa.me/' + salesNumber);
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Text(Localization.of(buildContext, 'whatsapp')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: logo != null,
              child: CircleAvatar(
                radius: avatarRadius ?? 50.0,
                backgroundImage: logo,
              ),
            ),
            Visibility(
                visible: image != null, child: image ?? SizedBox.shrink()),
            if (isNotEmpty(companyName))
              Text(
                companyName,
                style: TextStyle(
                  fontFamily: companyFont ?? 'Pacifico',
                  fontSize: companyFontSize ?? 40.0,
                  color: companyColor,
                  fontWeight: companyFontWeight ?? FontWeight.bold,
                ),
              ),
            if (isNotEmpty(companyName))
              Visibility(
                visible: tagLine != null,
                child: Text(
                  tagLine ?? "",
                  style: TextStyle(
                    fontFamily: taglineFont ?? 'Pacifico',
                    color: taglineColor,
                    fontSize: 20.0,
                    letterSpacing: 2.0,
                    fontWeight: taglineFontWeight ?? FontWeight.bold,
                  ),
                ),
              ),
            if (isNotEmpty(companyName))
              SizedBox(
                height: 10.0,
              ),
            if (isNotEmpty(companyName))
              Divider(
                color: dividerColor ?? Colors.teal[200],
                thickness: dividerThickness ?? 4.0,
                indent: 50.0,
                endIndent: 50.0,
              ),
            SizedBox(
              height: 10.0,
            ),
            Visibility(
              visible: website != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                // color:
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/internet.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      websiteText ?? Localization.of(buildContext, 'website'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch(website);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: salesNumber != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/whatsapp_contact.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'whatsapp'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('https://wa.me/' + salesNumber);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: tiktok != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/tik-tok_black.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'tiktok'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch(tiktok);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: instagram != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/instagram_black.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'instagram'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('https://instagram.com/' + instagram);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: telegram != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/telegram.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'telegram'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch(telegram);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: salesNumber != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/phone.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      phoneNumberText ??
                          Localization.of(buildContext, 'call_us'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('tel:' + salesNumber);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 210, 34, 49),
                      Colors.red,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  leading: Image.asset(
                    "assets/images/email.png",
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  title: Text(
                    emailText ?? Localization.of(buildContext, 'email'),
                    style: TextStyle(
                      color: textColor,
                      fontFamily: textFont,
                    ),
                  ),
                  onTap: () {
                    try {
                      launch('mailto:' + salesEmail);
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                ),
              ),
            ),
            Visibility(
              visible: supportEmail != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/support.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      phoneNumberText ??
                          Localization.of(buildContext, 'support'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('mailto:' + supportEmail);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            // Card(
            //   clipBehavior: Clip.antiAlias,
            //   margin: EdgeInsets.symmetric(
            //     vertical: 10.0,
            //     horizontal: 25.0,
            //   ),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(50.0),
            //   ),
            //   color: cardColor,
            //   child: ListTile(
            //     contentPadding: EdgeInsets.symmetric(horizontal: 24),
            //     leading: Image.asset(
            //       "assets/images/email.png",
            //       width: 20,
            //       height: 20,
            //       color: Colors.white,
            //     ),
            //     title: Text(
            //       emailText ?? 'Support Email',
            //       style: TextStyle(
            //         color: textColor,
            //         fontFamily: textFont,
            //       ),
            //     ),
            //     onTap: () => launch('mailto:' + supportEmail),
            //   ),
            // ),
            Visibility(
              visible: twitterHandle != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/twitter.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'twitter'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('https://twitter.com/' + twitterHandle);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: facebookHandle != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/facebook.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'facebook'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('https://www.facebook.com/' + facebookHandle);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: githubUserName != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/github.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'github'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch('https://github.com/' + githubUserName);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: linkedinURL != null,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 210, 34, 49),
                        Colors.red,
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    leading: Image.asset(
                      "assets/images/linkedin.png",
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    title: Text(
                      Localization.of(buildContext, 'linkedin'),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: textFont,
                      ),
                    ),
                    onTap: () {
                      try {
                        launch(linkedinURL);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///Class for adding contact details of the developer in your bottomNavigationBar in your flutter app.
class ContactUsBottomAppBar extends StatelessWidget {
  ///Color of the text which will be displayed in the bottomNavigationBar
  final Color textColor;

  ///Color of the background of the bottomNavigationBar
  final Color backgroundColor;

  ///Email ID Of the company/developer on which, when clicked by the user, the respective mail app will be opened.
  final String email;

  ///Name of the company or the developer
  final String companyName;

  ///Size of the font in bottomNavigationBar
  final double fontSize;

  /// font of text
  final String textFont;

  ContactUsBottomAppBar({
    this.textColor,
    this.backgroundColor,
    this.email,
    this.companyName,
    this.fontSize = 15.0,
    this.textFont,
  });
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        onSurface: Colors.grey,
        shadowColor: Colors.transparent,
      ),
      child: Text(
        'Designed and Developed by $companyName 💙\nWant to contact?',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: textColor, fontSize: fontSize, fontFamily: textFont),
      ),
      onPressed: () {
        try {
          launch('mailto:$email');
        } catch (e) {
          print(e.toString());
        }
      },
    );
  }
}
