import 'dart:convert';

import '../model/Vote.dart';
import 'package:http/http.dart' as http;

class Api {

  Future<Vote> fetchVote() async {
    final response = await http.get(Uri.parse("https://jokes.damianhoppe.pl/api/vote"));

    if(response.statusCode == 200) {
      return Vote.fromJson(jsonDecode(utf8.decode(response.body.codeUnits)));
    }else {
      throw Exception("Failed to load data");
    }
  }

  Future<Vote> fetchLastVote() async {
    final response = await http.get(Uri.parse("https://jokes.damianhoppe.pl/api/lastVote"));

    if(response.statusCode == 200) {
      return Vote.fromJson(jsonDecode(utf8.decode(response.body.codeUnits)));
    }else {
      throw Exception("Failed to load data");
    }
  }

  Future<bool> vote(String jokeId) async {
    final response = await http.post(Uri.parse("https://jokes.damianhoppe.pl/api/vote/$jokeId"));

    if(response.statusCode == 200) {
      return true;
    }else {
      throw Exception("Failed to vote");
    }
  }
}