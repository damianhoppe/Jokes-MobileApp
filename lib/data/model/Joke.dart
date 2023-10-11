class Joke {
  String? id;
  String? content;
  String? source;

  Joke(this.id, this.content, this.source);

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      json['id'],
      json['content'],
      json['source'],
    );
  }
}