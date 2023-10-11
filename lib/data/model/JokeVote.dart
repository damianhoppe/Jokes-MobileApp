import 'Joke.dart';

class JokeVote {
  Joke joke;
  int votes = 0;

  JokeVote(this.joke, this.votes);

  static List<JokeVote> fromJsonList(List<dynamic> json) {
    return json.map((e) => JokeVote.fromJson(e)).toList();
  }

  factory JokeVote.fromJson(Map<String, dynamic> json) {
    return JokeVote(
      Joke.fromJson(json['joke']),
      json['votes'],
    );
  }
}