import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:jokes/pages/LastVotePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';

import '../App.dart';
import '../data/model/Joke.dart';
import '../data/model/Vote.dart';
import '../data/source/Api.dart';
import 'SettingsPage.dart';

Duration _defaultAnimDuration = const Duration(milliseconds: 200);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int pageIndex = 0;
  int lastRefreshTime = 0;

  //Stores id of the voted joke - when the action is sent to the server
  String? postVoteState;
  //Stores date of last vote. Very simple security against multiple voting
  String? userLastVoteDateCompleted;
  Vote? currentVote;
  Vote? lastVote;

  final SharedPreferences preferences = App.getInstance().preferences;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final Api api = Api();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_){  _refreshIndicatorKey.currentState?.show(); } );
    userLastVoteDateCompleted = preferences.getString("lastVote");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      int now = DateTime.now().millisecondsSinceEpoch;
      if(now - lastRefreshTime > 60 * 60000) {
        _refreshIndicatorKey.currentState?.show();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if(pageIndex != 0) {
              setState(() {
                pageIndex = 0;
              });
              return false;
            }
            return true;
          },
          child: Scaffold(
            bottomNavigationBar: NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              height: 50,
              onDestinationSelected: (int index) {
                setState(() {
                  pageIndex = index;
                });
              },
              indicatorColor: Theme.of(context).colorScheme.inversePrimary,
              selectedIndex: pageIndex,
              destinations: [
                NavigationDestination(icon: Icon(Icons.home), label: ""),
                NavigationDestination(icon: Icon(Icons.settings), label: ""),
              ],
            ),
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(begin: Offset(0, 0.02), end: Offset(0, 0)).animate(animation),
                  child: FadeTransition(opacity: animation, child: child,),
                );
              },
              child: <Widget>[
                _mainPage(context),
                SettingsPage(),
              ][pageIndex],
            ),
          ),
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
          AppBar(title: Row(
              children: <Widget>[
                Text("Hello ",
                  style: TextStyle(fontSize: 22),
                ),
                Text(preferences.getString("name") ?? "",
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold
                    )
                )
              ]
          )),
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

  _vote(String jokeId) async {
    setState(() {
      postVoteState = jokeId;
    });
    await api.vote(jokeId);
    setState(() {
      postVoteState = null;
      userLastVoteDateCompleted = currentVote?.date;
      if(currentVote != null && currentVote!.date != null) {
        preferences.setString("lastVote", currentVote?.date ?? "");
        preferences.setString("lastVoteId", jokeId);
      }else {
        preferences.remove("lastVote");
        preferences.remove("lastVoteId");
      }
      _refresh();
    });
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

    String lastVoteId = preferences.getString("lastVoteId") ?? "";

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
                Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 16, left: 3),
                    child: Text("Przygotowaliśmy na dzisiaj nowe \ndowcipy. 😁😁😁",
                        style: TextStyle(fontSize: 16)
                    )
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
                                  userLastVoteDateCompleted==currentVote?.date && userLastVoteDateCompleted != null?
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
                                          child: Text("Votes: ${jokes[index].votes}${(lastVoteId == jokes[index].joke.id)? " ⭐" : ""}"),
                                        ),
                                      )
                                  )
                                      :
                                  postVoteState==jokes[index].joke.id?
                                  CircularProgressIndicator()
                                      :
                                  TextButton(
                                      onPressed: (){
                                        if(postVoteState != null)
                                          return;
                                        Joke joke = jokes[index].joke;
                                        jokes[index].votes++;
                                        if(joke.id != null) {
                                          _vote(joke.id ?? "");
                                        }
                                      },
                                      child: Text("Vote")
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