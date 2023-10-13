import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wkbeast/controllers/home_screen_controller.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/feedback.dart' as Feedback;
import 'package:wkbeast/screens/feedback/feedback_details_screen.dart';
import 'package:wkbeast/utils/string_util.dart';

class FeedbackListTile extends StatefulWidget {
  final Feedback.Feedback feedback;
  final HomeScreenController controller;
  final bool isLastRow;
  final ValueChanged<bool> shouldRefresh;
  final SharedPreferences prefs;

  const FeedbackListTile({
    Key key,
    this.feedback,
    this.controller,
    this.isLastRow = false,
    this.shouldRefresh,
    this.prefs,
  }) : super(key: key);

  @override
  _FeedbackListTileState createState() => _FeedbackListTileState();
}

class _FeedbackListTileState extends State<FeedbackListTile> {
  int day, month, year, hour, minute, second;

  @override
  initState() {
    super.initState();
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 15,
        end: 15,
        bottom: widget.isLastRow ? 32 : 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: (widget.feedback?.alreadyContacted ?? false)
              ? Colors.grey.withOpacity(0.4)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.0),
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(5.0),
          ),
        ),
        child: Stack(
          children: <Widget>[
            InkWell(
              onTap: _onListTileTapped,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  replaceVariable(
                                    replaceVariable(
                                      Localization.of(
                                        context,
                                        'feedback_on',
                                      ),
                                      'valueone',
                                      isNotEmpty(getDateTime(
                                              widget.feedback.dateTime))
                                          ? DateFormat(
                                              widget.prefs.getString(
                                                          "wkbeast_language") ==
                                                      'ar'
                                                  ? 'EEEE d MMMM yyyy'
                                                  : 'EEEE MMMM d, yyyy',
                                              widget.prefs.getString(
                                                  "wkbeast_language"),
                                            ).format(
                                              getFormattedDate(
                                                  widget.feedback.dateTime),
                                            )
                                          : "",
                                    ),
                                    'valuetwo',
                                    getHourMinute(),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 34, 34, 34),
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 1),
                          SizedBox(height: 8),
                          Container(
                            height: 35,
                            child: Text(
                              "${widget.feedback.feedback}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 34, 34, 34)),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime getFormattedDate(String date) {
    String splitted = date.split(" ")[0];
    int year = int.tryParse(splitted.substring(0, 4));
    int month = int.tryParse(splitted.substring(4, 6));
    int day = int.tryParse(splitted.substring(6, 8));
    return DateTime(
      year,
      month,
      day,
    );
  }

  String getHourMinute() {
    if (widget.feedback.dateTime == null) return null;
    String fullDate =
        getDateTime(widget.feedback.dateTime).toString().split(" ")[1];
    String hour = fullDate.split(":")[0];
    String hourWithoutZero =
        hour.substring(0, 1) == "0" ? hour.substring(1) : hour;
    String minute = fullDate.split(":")[1];
    var amOrPm = (Localizations.localeOf(context).languageCode == 'ar')
        ? ""
        : int.tryParse(hour) <= 12
            ? "AM"
            : "PM";
    return hourWithoutZero + ":" + minute + " " + amOrPm;
  }

  String getDateTime(String time) {
    if (time == null) return "";
    int day = int.tryParse(time.substring(6, 8).substring(0, 1) == "0"
        ? time.substring(7, 8)
        : time.substring(6, 8));
    int month = int.tryParse(time.substring(4, 6).substring(0, 1) == "0"
        ? time.substring(5, 6)
        : time.substring(4, 6));
    int year = int.tryParse(time.substring(0, 4));
    int hour = int.tryParse(time.split("at ")[1].split(":")[0]);
    int minute = int.tryParse(time.split("at ")[1].split(":")[1]);
    int second = int.tryParse(time.split("at ")[1].split(":")[2]);

    return DateFormat("yyyy-MM-dd HH:mm:ss").format(
      DateTime(
        year,
        month,
        day,
        hour,
        minute,
        second,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  void _onListTileTapped() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackDetailsScreen(
            feedback: widget.feedback,
            controller: widget.controller,
            shouldRefresh: (shouldRfrsh) {
              widget.shouldRefresh(shouldRfrsh);
            }),
      ),
    );
  }
}
