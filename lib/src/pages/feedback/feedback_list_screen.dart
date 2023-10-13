import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wkbeast/localization/localization.dart';
import 'package:wkbeast/models/feedback.dart' as Feedback;
import 'package:wkbeast/screens/feedback/feedback_list_tile.dart';
import 'package:wkbeast/utils/UBScaffold/page_state.dart';
import 'package:wkbeast/utils/UBScaffold/ub_page_state_widget.dart';
import 'package:wkbeast/utils/UBScaffold/ub_scaffold.dart';

import '../../../controllers/home_screen_controller.dart';

class FeedbackListScreen extends StatefulWidget {
  final HomeScreenController controller;

  FeedbackListScreen({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  _FeedbackListScreenState createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  PageState _state;
  List<QueryDocumentSnapshot> feedbacks = [];
  ScrollController _scrollController;

  bool canLoadMore = true;
  bool isLoadingMore = false;
  int _offset = 0;
  int _limit = 10;
  SharedPreferences prefs;

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
            .collection('feedbacks')
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
            .collection('feedbacks')
            .orderBy("dateTime", descending: true)
            .limit(_offset)
            .snapshots()
            .first,
      ]);

      var newFeedbacks = (data[0] as QuerySnapshot).docs;

      if (newFeedbacks.isNotEmpty ?? false) {
        if ((feedbacks?.length ?? 0) == (newFeedbacks?.length ?? 0))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UBScaffold(
        state: AppState(
          pageState: _state,
          onRetry: _load,
        ),
        appBar: AppBar(
          title: Text(
            Localization.of(context, 'feedbacks'),
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 210, 34, 49),
        ),
        builder: (context) => feedbacks.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: NoData(
                  Localization.of(context, 'you_dont_have_any_feedbacks_yet'),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => FeedbackListTile(
                                  feedback: Feedback.Feedback.fromJson(
                                    feedbacks[index].data(),
                                  ),
                                  prefs: prefs,
                                  controller: widget.controller,
                                  isLastRow: index == feedbacks.length - 1,
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
                                        child: CircularProgressIndicator(),
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
      ),
    );
  }
}
