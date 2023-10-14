import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/src/localization/localization.dart';
import 'package:flutter_ecommerce_app/src/models/feedback.dart' as Feedback;
import 'package:flutter_ecommerce_app/src/themes/light_color.dart';
import 'package:flutter_ecommerce_app/src/themes/theme.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/page_state.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_page_state_widget.dart';
import 'package:flutter_ecommerce_app/src/utils/UBScaffold/ub_scaffold.dart';
import 'package:flutter_ecommerce_app/src/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_screen_controller.dart';
import 'feedback_list_tile.dart';

class FeedbackListScreen extends StatefulWidget {
  final HomeScreenController? controller;

  FeedbackListScreen({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  _FeedbackListScreenState createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  late PageState _state;
  List<QueryDocumentSnapshot> feedbacks = [];
  late ScrollController _scrollController;

  bool canLoadMore = true;
  bool isLoadingMore = false;
  int _offset = 0;
  int _limit = 10;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _load();
    _offset = _limit;
    _scrollController = ScrollController();
    if (canLoadMore) {
      _scrollController.addListener(_listener);
    }
  }

  void _listener() {
    double percentage = (_scrollController.offset /
            _scrollController.position.maxScrollExtent) *
        100;
    if (percentage >= 80) {
      loadMore();
    }
  }

  void _load() async {
    setState(() {
      _state = PageState.loading;
    });

    try {
      prefs = await SharedPreferences.getInstance();
      List data = await Future.wait([
        FirebaseFirestore.instance
            .collection('Feedbacks')
            .orderBy("dateTime", descending: true)
            .limit(_limit)
            .snapshots()
            .first,
      ]);

      feedbacks = (data[0] as QuerySnapshot).docs;
      if (feedbacks.length % _limit != 0) canLoadMore = false;

      setState(() {
        _state = PageState.loaded;
      });
    } catch (e) {
      print(e);
      setState(() {
        _state = PageState.error;
      });
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !canLoadMore) return;
    isLoadingMore = true;
    _offset += _limit;

    setState(() {});

    try {
      List data = await Future.wait([
        FirebaseFirestore.instance
            .collection('Feedbacks')
            .orderBy("dateTime", descending: true)
            .limit(_offset)
            .snapshots()
            .first,
      ]);

      var newFeedbacks = (data[0] as QuerySnapshot).docs;

      if (newFeedbacks.isNotEmpty) {
        if ((feedbacks.length) == (newFeedbacks.length))
          canLoadMore = false;
        feedbacks = newFeedbacks;
        if (newFeedbacks.length % _limit != 0) canLoadMore = false;
      } else {
        canLoadMore = false;
      }

      isLoadingMore = false;

      setState(() {});
    } catch (e) {
      print(e);
      setState(() {
        _offset -= _limit;
        isLoadingMore = false;
      });
    }
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
                  text: Localization.of(context, 'received'),
                  fontSize: 27,
                  fontWeight: FontWeight.w400,
                ),
                TitleText(
                  text: Localization.of(context, 'feedbacks'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          UBScaffold(
            backgroundColor: Colors.transparent,
            state: AppState(
              pageState: _state,
              onRetry: _load,
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
                    feedbacks.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: NoData(
                              Localization.of(
                                  context, 'you_dont_have_any_feedbacks_yet'),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Center(
                                    child: CustomScrollView(
                                      shrinkWrap: true,
                                      controller: _scrollController,
                                      slivers: <Widget>[
                                        SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) =>
                                                FeedbackListTile(
                                              feedback:
                                                  Feedback.Feedback.fromJson(
                                                feedbacks[index].data()
                                                    as Map<dynamic, dynamic>,
                                              ),
                                              prefs: prefs!,
                                              controller: widget.controller!,
                                              isLastRow:
                                                  index == feedbacks.length - 1,
                                              shouldRefresh: (shouldRefrsh) {
                                                if (shouldRefrsh) _load();
                                              },
                                            ),
                                            childCount: feedbacks.length,
                                          ),
                                        ),
                                        SliverToBoxAdapter(
                                          child: isLoadingMore
                                              ? Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
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
}
