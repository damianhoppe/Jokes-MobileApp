import 'JokeVote.dart';

class Vote {
  String? date;
  List<JokeVote>? jokes;
  JokeVote? bestJoke;

  Vote(this.date, this.jokes, this.bestJoke);

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      json['date'],
      JokeVote.fromJsonList(json['jokes']),
      JokeVote.fromJson(json['bestJoke']),
    );
  }
}