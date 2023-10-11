import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../data/model/Vote.dart';

class LastVotePage extends StatefulWidget {
  late Vote vote;

  LastVotePage({required this.vote, super.key}) {
    vote.jokes?.sort((a,b) {
      if(a.votes > b.votes) {
        return -1;
      }
      if(a.votes < b.votes) {
        return 1;
      }
      return 0;
    });
  }

  @override
  State<LastVotePage> createState() => _LastVotePageState();
}

class _LastVotePageState extends State<LastVotePage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          body:  _mainTab(),
        ),
      ),
    );
  }

  _mainTab() {
    return Column(
      children: [
        AppBar(
          scrolledUnderElevation: 0,
        ),
        Expanded(child: Padding(
          padding: EdgeInsets.only(left: 14, top: 0, right: 14, bottom: 0),
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
          )
        ))
      ],
    );
    return Padding(
        padding: EdgeInsets.only(left: 14, top: 0, right: 14, bottom: 0),
        child: Column(
          children: [
            AppBar(
              scrolledUnderElevation: 0,
            ),
            Expanded(
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
              )
            ),
          ],
        ),
    );
  }

  _renderVote() {
    final jokes = widget.vote.jokes ?? [];

    int jokesCount = jokes.length;
    int maxNumberOfColumns = 2;

    int numberOfRows = 0;
    int numberOfColumns = 0;

    int maxVotes = 0;

    int allVotes = 0;

    if(jokesCount > 0) {
      numberOfRows = jokesCount>0? sqrt(jokesCount).round() : 0;
      numberOfColumns = min(numberOfRows, maxNumberOfColumns);
      numberOfRows = (jokesCount.toDouble() / numberOfColumns.toDouble()).ceil();
      jokes.forEach((element) {
        allVotes += element.votes;
        if(element.votes > maxVotes) {
          maxVotes = element.votes;
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("#BEST 👑",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
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
                                  Text(widget.vote.bestJoke?.joke.content ?? ""),
                                ]
                            )
                        )
                    )
                )
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 6),
                child: Text("#RANKING 🏆",
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
                            Text("${index+1}.",
                              style: TextStyle(
                                  fontSize: 12.0+(jokesCount-index)*2,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Text("${jokes[index].joke.content}"),
                            Expanded(child: Container(),),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      color: Theme.of(context).brightness==Brightness.light?
                                      Color.lerp(Color.fromRGBO(255, 231, 163, 0.7), Color.fromRGBO(255, 132, 87, 0.8), maxVotes>0? jokes[index].votes.toDouble()/maxVotes.toDouble() : 0)
                                          :
                                      Color.lerp(Color.fromRGBO(189, 140, 0, 0.8), Color.fromRGBO(237, 88, 33, 0.7), maxVotes>0? jokes[index].votes.toDouble()/maxVotes.toDouble() : 0),
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Text("Votes: ${jokes[index].votes}", textAlign: TextAlign.start)
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
        Padding(
          padding: EdgeInsets.only(top: 30, bottom: 6),
          child: Text("#GŁOSY 📢",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 0, top: 4),
          child: Text(
            allVotes == 0? "Niestety wczoraj nie oddano żadnego głosu 😢" :
            allVotes == 1? "Wczoraj oddano $allVotes głos 🥳" :
            allVotes >= 2 && allVotes <= 4? "Wczoraj oddano $allVotes głosy 🥳🥳" :
            "Wczoraj oddano $allVotes głosów 🥳🥳🥳",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        allVotes>0?
        Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 320,
                child: SfCircularChart(
                  tooltipBehavior: TooltipBehavior(enable: true),
                  legend: Legend(isVisible: true, position: LegendPosition.bottom, orientation: LegendItemOrientation.horizontal, shouldAlwaysShowScrollbar: false, overflowMode: LegendItemOverflowMode.scroll),
                  series: [
                    PieSeries(
                      enableTooltip: true,
                      dataSource: jokes.where((element) => element.votes > 0).toList(),
                      xValueMapper: (dynamic data, _i) => (_i+1).toString(),
                      yValueMapper: (dynamic data, _) => data.votes,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              )
            ],
          ),
        )
            :Container()
      ],
    );
  }
}