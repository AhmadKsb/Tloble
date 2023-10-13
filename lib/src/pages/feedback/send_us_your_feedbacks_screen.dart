import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wkbeast/controllers/home_screen_controller.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/feedback.dart' as Feedback;
import 'package:wkbeast/utils/BottomSheets/bottom_sheet_helper.dart';
import 'package:wkbeast/utils/BottomSheets/operation_status.dart';
import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';
import 'package:wkbeast/utils/buttons/raised_button.dart';
import 'package:wkbeast/utils/keyboard_actions_form.dart';
import 'package:wkbeast/utils/util.dart';

class FeedbackScreen extends StatefulWidget {
  final HomeScreenController controller;

  FeedbackScreen({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String name;
  String message;
  FocusNode _nameNode = new FocusNode(),
      _emailNode = new FocusNode(),
      _feedbackNode = new FocusNode();
  bool _isLoading = false;
  HomeScreenController _controller;

  @override
  void initState() {
    _controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UBScaffold(
      appBar: AppBar(
        title: Text(Localization.of(context, 'feedback')),
        centerTitle: true,
      ),
      builder: (context) => KeyboardFormActions(
        keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
        nextFocus: false,
        keyboardBarColor: Colors.black54,
        actions: [
          KeyboardFormAction(
            focusNode: _nameNode,
          ),
          KeyboardFormAction(
            focusNode: _emailNode,
          ),
          KeyboardFormAction(
            focusNode: _feedbackNode,
          )
        ],
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (b, i) => Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          focusNode: _nameNode,
                          controller: _nameController,
                          enabled: !_isLoading,
                          onChanged: (val) {
                            if (val != null || val.length > 0) name = val;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r"[abcedfghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890!#.(),:;<>@[\]$%&'*+-/=?^_`{|}~ !$'()*+-./:<=>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"))
                          ],
                          decoration:
                              inputDecoration(Localization.of(context, 'name')),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          focusNode: _emailNode,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          onChanged: (val) {
                            if (val != null || val.length > 0) name = val;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[@a-zA-Z0-9._-]'),
                            )
                          ],
                          decoration: inputDecoration(
                              Localization.of(context, 'email')),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          focusNode: _feedbackNode,
                          controller: _feedbackController,
                          maxLines: 12,
                          textInputAction: TextInputAction.newline,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          onChanged: (val) {
                            if (val != null || val.length > 0) message = val;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r"[abcedfghijklmnopqrstuvwxyz \nABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890!#.(),:;<>@[\]$%&'*+-/=?^_`{|}~ !$'()*+-./:<=>[\]_{|}«»ÇÈÊÒÓÖ×÷،؛؟ءآأؤإئابةتثجحخدذرزسشصضطظعغـفقكلمنهوىيًٌٍَُِّْٕٓٔ٠١٢٣٤٥٦٧٨٩٪٫٬٭ٰٱپچژڤ۰۱۲۳۴۵۶۷۸۹‌‍‐“”␡ﭐﭑﭖﭗﭘﭙﭪﭫﭬﭭﭺﭻﭼﭽﮊﮋﯾﯿﱞﱟﱠﱡﱢﴼﴽ﴾﴿ﷲﹰﹲﹴﹶﹸﹺﹼﹾﺀﺁﺂﺃﺄﺅﺆﺇﺈﺉﺊﺋﺌﺍﺎﺏﺐﺑﺒﺓﺔﺕﺖﺗﺘﺙﺚﺛﺜﺝﺞﺟﺠﺡﺢﺣﺤﺥﺦﺧﺨﺩﺪﺫﺬﺭﺮﺯﺰﺱﺲﺳﺴﺵﺶﺷﺸﺹﺺﺻﺼﺽﺾ]"))
                          ],
                          enabled: !_isLoading,
                          validator: (String value) {
                            if (value?.trim()?.isEmpty ?? true) {
                              return Localization.of(
                                  context, 'this_field_cannot_be_empty');
                            }
                            return null;
                          },
                          maxLength: 255,
                          decoration: inputDecoration(Localization.of(
                              context, 'your_feedback_suggestion')),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 36,
                      top: 12,
                    ),
                    child: RaisedButtonV2(
                      label: Localization.of(context, 'send_feedback'),
                      disabled: _isLoading ?? false,
                      isLoading: _isLoading ?? false,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          showConfirmationBottomSheet(
                            context: context,
                            flare: 'assets/flare/pending.flr',
                            title: Localization.of(context,
                                'are_you_sure_you_want_to_submit_your_feedback'),
                            confirmMessage: Localization.of(context, 'confirm'),
                            confirmAction: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await Navigator.of(context).pop();
                                await FirebaseFirestore.instance
                                    .collection('feedbacks')
                                    .doc(
                                        '${DateTime.now().year}${getNumberWithPrefixZero(DateTime.now().month)}${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}')
                                    .set(
                                      Feedback.Feedback(
                                        name: _nameController?.text ?? "",
                                        email: _emailController?.text ?? "",
                                        phoneNumber: widget.controller
                                                ?.loggedInUserPhoneNumber ??
                                            "",
                                        feedback:
                                            _feedbackController?.text ?? "",
                                        dateTime:
                                            '${DateTime.now().year}${getNumberWithPrefixZero(DateTime.now().month)}${getNumberWithPrefixZero(DateTime.now().day)} at ${getNumberWithPrefixZero(DateTime.now().hour)}:${getNumberWithPrefixZero(DateTime.now().minute)}:${getNumberWithPrefixZero(DateTime.now().second)}',
                                        alreadyContacted: false,
                                      ).toJson(),
                                    );
                                showSuccessBottomsheet();
                                setState(() {
                                  _nameController?.clear();
                                  _emailController?.clear();
                                  _feedbackController?.clear();
                                  _isLoading = false;
                                });
                              } catch (e) {
                                showErrorBottomsheet(e.toString());
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            cancelMessage: Localization.of(context, 'cancel'),
                          );

                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
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

  InputDecoration inputDecoration(String hintText, {Widget prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
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

  void showSuccessBottomsheet() async {
    if (!mounted) return;
    String animResource;
    animResource = 'assets/flare/success.flr';
    setState(() {
      Vibration.vibrate();
    });

    await showBottomsheet(
      context: context,
      isScrollControlled: true,
      height: MediaQuery.of(context).size.height * 0.35,
      dismissOnTouchOutside: false,
      upperWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Padding(
              padding:
                  EdgeInsets.only(top: 12, bottom: 16, left: 12, right: 12),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          (Localizations.localeOf(context).languageCode == 'ar')
                              ? _controller.feedbackSuccessMessageAR
                              : _controller.feedbackSuccessMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
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
        padding: EdgeInsets.only(top: 18, left: 18, right: 18),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: RaisedButtonV2(
              label: Localization.of(context, 'done'),
              onPressed: () async {
                if (!mounted) return;
                await Navigator.of(context).pop();
                _nameController?.clear();
                _emailController?.clear();
                _feedbackController?.clear();
              },
            ),
          ),
        ),
      ),
    );
  }
}
