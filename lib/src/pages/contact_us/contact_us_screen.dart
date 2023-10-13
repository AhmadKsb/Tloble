import 'package:flutter/material.dart';
import 'package:wkbeast/contact_us/contact_us_widget.dart';
import 'package:wkbeast/controllers/home_screen_controller.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';
import 'package:wkbeast/utils/string_util.dart';

class ContactUsScreen extends StatefulWidget {
  final HomeScreenController controller;

  const ContactUsScreen({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  State<ContactUsScreen> createState() => ContactUsScreenState();
}

class ContactUsScreenState extends State<ContactUsScreen> {
  @override
  void initState() {
    super.initState();
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return UBScaffold(
      appBar: AppBar(
        title: Text(
          Localization.of(context, 'contact_us'),
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 210, 34, 49),
      ),
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          // backgroundColor: Colors.teal,
          // backgroundColor: Colors,
          body: ContactUs(
            buildContext: context,
            cardColor: Colors.tealAccent,
            textColor: Colors.white,
            salesEmail: isNotEmpty(widget.controller.salesEmail)
                ? widget.controller.salesEmail
                : null,
            supportEmail: isNotEmpty(widget.controller.supportEmail)
                ? widget.controller.supportEmail
                : null,
            salesNumber: isNotEmpty(widget.controller.salesNumber)
                ? widget.controller.salesNumber
                : null,
            // supportNumber: isNotEmpty(widget.controller.supportNumber)
            //     ? widget.controller.supportNumber
            //     : null,
            website: isNotEmpty(widget.controller.website)
                ? widget.controller.website
                : null,
            tiktok: isNotEmpty(widget.controller.tiktok)
                ? widget.controller.tiktok
                : null,
            githubUserName: isNotEmpty(widget.controller.github)
                ? widget.controller.github
                : null,
            linkedinURL: isNotEmpty(widget.controller.linkedIn)
                ? widget.controller.linkedIn
                : null,
            twitterHandle: isNotEmpty(widget.controller.twitter)
                ? widget.controller.twitter
                : null,
            instagram: isNotEmpty(widget.controller.instagram)
                ? widget.controller.instagram
                : null,
            telegram: isNotEmpty(widget.controller.telegram)
                ? widget.controller.telegram
                : null,
            facebookHandle: isNotEmpty(widget.controller.facebook)
                ? widget.controller.facebook
                : null,
          ),
        ),
      ),
    );
  }
}
