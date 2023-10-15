import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/controllers/home_screen_controller.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';

import 'contact_us_widget.dart';

class ContactUsScreen extends StatefulWidget {
  final HomeScreenController controller;

  const ContactUsScreen({
    Key? key,
    required this.controller,
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 68),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _appBar(),
                    _title(),
                    ContactUs(
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
                  ],
                ),
              ),
            ),

        ],
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
                  text: Localization.of(context, 'contact'),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: Localization.of(context, 'us'),
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ],
        ));
  }

  Widget _appBar() {
    return Container(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RotatedBox(
            quarterTurns:
            (Localizations.localeOf(context).languageCode == 'ar') ? 2 : 4,
            child: _icon(Icons.arrow_back_ios_new, color: Colors.black54),
          ),
          // Padding(
          //   padding: EdgeInsetsDirectional.only(end: 24),
          //   child: GestureDetector(
          //     onTap: () {
          //       // _selectDate();
          //     },
          //     child: SvgPicture.asset(
          //       'assets/svgs/calendar.svg',
          //       width: 20,
          //       color: Colors.black54,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, {Color color = LightColor.iconColor}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      // onTap: null,
      child: Container(
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            // color: Theme.of(context).backgroundColor,
            boxShadow: AppTheme.shadow),
        child: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }

}
