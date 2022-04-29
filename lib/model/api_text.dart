// To parse this JSON data, do
//
//     final apiText = apiTextFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class ApiText {
    ApiText({
        required this.status,
        required this.request,
        required this.profanity,
        required this.personal,
    });

    final String status;
    final Request request;
    final Personal profanity;
    final Personal personal;

    factory ApiText.fromJson(String str) => ApiText.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ApiText.fromMap(Map<String, dynamic> json) => ApiText(
        status: json["status"],
        request: Request.fromMap(json["request"]),
        profanity: Personal.fromMap(json["profanity"]),
        personal: Personal.fromMap(json["personal"]),
    );

    Map<String, dynamic> toMap() => {
        "status": status,
        "request": request.toMap(),
        "profanity": profanity.toMap(),
        "personal": personal.toMap(),
    };
}

class Personal {
    Personal({
        required this.matches,
    });

    final List<Match> matches;

    factory Personal.fromJson(String str) => Personal.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Personal.fromMap(Map<String, dynamic> json) => Personal(
        matches: List<Match>.from(json["matches"].map((x) => Match.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "matches": List<dynamic>.from(matches.map((x) => x.toMap())),
    };
}

class Match {
    Match({
        required this.type,
        required this.match,
        required this.start,
        required this.end,
    });

    final String type;
    final String match;
    final int start;
    final int end;

    factory Match.fromJson(String str) => Match.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Match.fromMap(Map<String, dynamic> json) => Match(
        type: json["type"],
        match: json["match"],
        start: json["start"],
        end: json["end"],
    );

    Map<String, dynamic> toMap() => {
        "type": type,
        "match": match,
        "start": start,
        "end": end,
    };
}

class Request {
    Request({
        required this.id,
        required this.timestamp,
        required this.operations,
    });

    final String id;
    final double timestamp;
    final int operations;

    factory Request.fromJson(String str) => Request.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Request.fromMap(Map<String, dynamic> json) => Request(
        id: json["id"],
        timestamp: json["timestamp"].toDouble(),
        operations: json["operations"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "timestamp": timestamp,
        "operations": operations,
    };
}
