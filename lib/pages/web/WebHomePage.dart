import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:jokes/pages/LastVotePage.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';

import '../../data/model/Vote.dart';
import '../../data/source/Api.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  int lastRefreshTime = 0;

  Vote? currentVote;
  Vote? lastVote;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final Api api = Api();

  final Duration _defaultAnimDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_){  _refreshIndicatorKey.currentState?.show(); } );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          body: _mainPage(context),
        ),
      ),
    );
  }

  Widget _mainPage(BuildContext context) {
    return Padding(
      key: ValueKey<int>(0),
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () async {
                  await _refresh();
                },
                child: CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _renderVote()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Vote> _refresh() async {
    Vote vote = await api.fetchVote();
    if(vote.date == currentVote?.date) {
      setState(() {
        currentVote = vote;
        lastRefreshTime = DateTime.now().millisecondsSinceEpoch;
      });
      return vote;
    }
    Vote? lastVote;
    try {
      lastVote = await api.fetchLastVote();
    }catch(_) {}
    setState(() {
      currentVote = vote;
      this.lastVote = lastVote;
      lastRefreshTime = DateTime.now().millisecondsSinceEpoch;
    });
    return vote;
  }

  Widget _renderVote() {
    final jokes = currentVote?.jokes ?? [];

    int jokesCount = jokes.length;
    int maxNumberOfColumns = 2;

    int numberOfRows = 0;
    int numberOfColumns = 0;

    int maxVotes = 0;

    if(jokesCount > 0) {
      numberOfRows = jokesCount>0? sqrt(jokesCount).round() : 0;
      numberOfColumns = min(numberOfRows, maxNumberOfColumns);
      numberOfRows = (jokesCount.toDouble() / numberOfColumns.toDouble()).ceil();
      maxVotes = currentVote?.bestJoke?.votes ?? 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSizeAndFade(
          sizeDuration: _defaultAnimDuration,
          fadeDuration: _defaultAnimDuration,
          sizeCurve: Curves.easeOut,
          fadeInCurve: Curves.easeOut,
          fadeOutCurve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: lastVote==null? Container(): Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("#TOP z wczoraj:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      TextButton(
                        onPressed: () {
                          if(lastVote != null) {
                            Navigator.push(context, MaterialPageRoute( builder: (context) => LastVotePage(vote: lastVote!)));
                          }
                        },
                        child: Text("Wyniki głosowania"),
                      )
                    ],
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                          color: Color.fromRGBO(79, 255, 141, 0.4),
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  children: [
                                    Text(lastVote?.bestJoke?.joke.content ?? "", textAlign: TextAlign.start,),
                                  ]
                              )
                          )
                      )
                  )
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: AnimatedSize(
            duration: _defaultAnimDuration,
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child:
            jokes.length == 0?
            Container()
                :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 6),
                  child: Text("#DZISIAJ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
                LayoutGrid(
                  columnSizes: List.generate(numberOfColumns, (index) => 1.fr),
                  rowSizes: List.generate(numberOfRows, (index) => auto),
                  rowGap: 20,
                  columnGap: 20,
                  children: List.generate(jokesCount, (index) => Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${jokes[index].joke.content}"),
                              Expanded(child: Container(),),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Container(
                                        // color: Color.lerp(Theme.of(context).colorScheme.onInverseSurface, Theme.of(context).colorScheme.inversePrimary, jokes[index].votes.toDouble()/maxVotes.toDouble()),
                                        // color: Color.lerp(Color.fromRGBO(255, 231, 163, 0.7), Color.fromRGBO(159, 255, 115, 0.6), jokes[index].votes.toDouble()/maxVotes.toDouble()),
                                        color: Theme.of(context).brightness==Brightness.light?
                                        Color.lerp(Color.fromRGBO(255, 231, 163, 0.7), Color.fromRGBO(255, 132, 87, 0.8), maxVotes>0? jokes[index].votes.toDouble()/maxVotes.toDouble() : 0)
                                            :
                                        Color.lerp(Color.fromRGBO(189, 140, 0, 0.8), Color.fromRGBO(237, 88, 33, 0.7), maxVotes>0? jokes[index].votes.toDouble()/maxVotes.toDouble() : 0),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Text("Votes: ${jokes[index].votes}"),
                                        ),
                                      )
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}