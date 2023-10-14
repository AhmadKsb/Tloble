import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/feedback.dart' as Feedback;
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/utils/buttons/raised_button.dart';
import 'package:flutter_ecommerce_app/src/utils/string_util.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class FeedbackDetailsScreen extends StatefulWidget {
  final Feedback.Feedback feedback;
  final ValueChanged<bool>? shouldRefresh;

  FeedbackDetailsScreen({
    Key? key,
    required this.feedback,
    this.shouldRefresh,
  }) : super(key: key);

  @override
  _FeedbackDetailsScreenState createState() => _FeedbackDetailsScreenState();
}

class _FeedbackDetailsScreenState extends State<FeedbackDetailsScreen> {
  late NavigatorState _nav;
  PageState _state = PageState.loaded;

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
          UBScaffold(
            backgroundColor: Colors.transparent,
            state: AppState(
              pageState: _state,
              onRetry: _getUpdatedFeedback,
            ),
            builder: (context) => Container(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                      child: Column(
                        children: [
                          if (isNotEmpty(widget.feedback.name))
                            labelTitlePair(
                              Localization.of(context, 'name'),
                              '${widget.feedback.name}',
                            ),
                          if (isNotEmpty(widget.feedback.email))
                            labelTitlePair(
                              Localization.of(context, 'email'),
                              '${widget.feedback.email}',
                            ),
                          if (isNotEmpty(widget.feedback.phoneNumber))
                            InkWell(
                              onLongPress: () {
                                Clipboard.setData(new ClipboardData(
                                        text: widget.feedback.phoneNumber))
                                    .then((result) {
                                  final snackBar = SnackBar(
                                    content: Text(Localization.of(context,
                                        'copied_phone_number_to_clipboard')),
                                    action: SnackBarAction(
                                      label: Localization.of(context, 'done'),
                                      onPressed: () {},
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snackBar);
                                });
                              },
                              onTap: () async {
                                try {
                                  Feedback.Feedback? feedback =
                                      await _getUpdatedFeedback();

                                  if (!(feedback?.alreadyContacted ?? true)) {
                                    openWhatsapp();
                                    await Future.wait(
                                      [
                                        FirebaseFirestore.instance
                                            .collection('Feedbacks')
                                            .doc(feedback?.dateTime)
                                            .update({
                                          'alreadyContacted': true,
                                        }),
                                      ],
                                    );
                                    if (widget.shouldRefresh != null)
                                      widget.shouldRefresh!(true);
                                  } else {
                                    if (widget.shouldRefresh != null)
                                      widget.shouldRefresh!(true);
                                    if (!mounted) return;
                                    String animResource;
                                    animResource = 'assets/flare/error.flr';
                                    setState(() {
                                      Vibration.vibrate();
                                    });
                                    await showBottomsheet(
                                      context: _nav.context,
                                      isScrollControlled: true,
                                      height: MediaQuery.of(_nav.context)
                                              .size
                                              .height *
                                          0.35,
                                      dismissOnTouchOutside: false,
                                      upperWidget: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              child: animResource != null
                                                  ? FlareActor(
                                                      animResource,
                                                      animation: 'animate',
                                                      fit: BoxFit.fitWidth,
                                                    )
                                                  : Container(),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Center(
                                            child: Container(
                                              width: MediaQuery.of(_nav.context)
                                                      .size
                                                      .width /
                                                  1.5,
                                              child: Center(
                                                child: Text(
                                                  Localization.of(_nav.context,
                                                      'already_accepted'),
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(_nav.context)
                                                      .textTheme
                                                      .bodyText1
                                                      ?.copyWith(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: 12,
                                                bottom: 32,
                                                right: 12,
                                                left: 12,
                                              ),
                                              child: RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: Localization.of(
                                                          _nav.context,
                                                          'this_user_has_already_been_contacted'),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                    TextSpan(
                                                      text: Localization.of(
                                                          _nav.context, 'here'),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.blue,
                                                      ),
                                                      recognizer:
                                                          new TapGestureRecognizer()
                                                            ..onTap = () {
                                                              try {
                                                                openWhatsapp();
                                                              } catch (e) {
                                                                print(
                                                                    "Error ${e.toString()}");
                                                              }
                                                            },
                                                    ),
                                                    TextSpan(
                                                      text: Localization.of(
                                                          _nav.context,
                                                          'if_you_still_want_to_contact_him_anyway'),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      bottomWidget: Padding(
                                        padding: EdgeInsets.only(
                                          top: 18,
                                          left: 18,
                                          right: 18,
                                        ),
                                        child: Container(
                                          width: MediaQuery.of(_nav.context)
                                              .size
                                              .width,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 16),
                                            child: RaisedButtonV2(
                                              label: Localization.of(
                                                  _nav.context, 'done'),
                                              onPressed: () async {
                                                if (!mounted) return;
                                                _nav.pop();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print(e);
                                  showErrorBottomsheet(
                                    _nav.context,
                                    replaceVariable(
                                          Localization.of(
                                            _nav.context,
                                            'an_error_has_occurred_value',
                                          ),
                                          'value',
                                          e.toString(),
                                        ) ??
                                        "",
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      Localization.of(context, 'phone_number'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        Text(
                                          (Localizations.localeOf(context)
                                                      .languageCode ==
                                                  'ar')
                                              ? ((widget.feedback.phoneNumber
                                                          ?.replaceAll(
                                                              '+', '') ??
                                                      '') +
                                                  '+')
                                              : ('+' +
                                                  (widget.feedback.phoneNumber
                                                          ?.replaceAll(
                                                              '+', '') ??
                                                      "")),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              ?.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Image.asset(
                                          "assets/images/whatsapp.png",
                                          height: 20.0,
                                          width: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 64,
                                  ),
                                ],
                              ),
                            ),
                          if (isNotEmpty(widget.feedback.feedback))
                            labelTitlePair(
                              Localization.of(context, 'the_feedback'),
                              '${widget.feedback.feedback}',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  text: Localization.of(context, 'feedback'),
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

  @override
  void didChangeDependencies() {
    _nav = Navigator.of(context);
    super.didChangeDependencies();
  }

  Widget labelTitlePair(
    String title,
    String label,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
          ),
        ),
        SizedBox(
          height: 64,
        ),
      ],
    );
  }

  Future<Feedback.Feedback?> _getUpdatedFeedback() async {
    setState(() {
      _state = PageState.loading;
    });
    try {
      List data = await Future.wait([
        FirebaseFirestore.instance
            .collection('Feedbacks')
            .doc(widget.feedback.dateTime)
            .snapshots()
            .first,
      ]);
      Feedback.Feedback feedback = Feedback.Feedback.fromJson(data[0].data());
      setState(() {
        _state = PageState.loaded;
      });
      return feedback;
    } catch (e) {
      setState(() {
        _state = PageState.error;
      });
      return null;
    }
  }

  void openWhatsapp() async {
    try {
      bool isEnglish = widget.feedback.feedback!.contains(RegExp(r'[a-zA-Z]'));

      if (isEnglish) {
        launch(
            'https://wa.me/${widget.feedback.phoneNumber}?text=Hello%2C%20we%20received%20your%20feedback.');
      } else {
        launch(
          Uri.encodeFull(
            'https://wa.me/${widget.feedback.phoneNumber}?text=مرحبًا، لقد تلقينا ملاحظاتك.',
          ),
        );
      }
    } catch (e) {
      print("Open Whatsapp Error: ${e.toString()}");
    }
  }
}
