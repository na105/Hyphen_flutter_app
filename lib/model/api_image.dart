// To parse this JSON data, do
//
//     final image = imageFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ApiImage imageFromJson(String str) => ApiImage.fromJson(json.decode(str));

String imageToJson(ApiImage data) => json.encode(data.toJson());

class ApiImage {
  ApiImage({
    required this.status,
    required this.request,
    required this.nudity,
    required this.gore,
    required this.text,
    required this.media,
  });

  final String status;
  final Request request;
  final Nudity nudity;
  final Gore gore;
  final ApiText text;
  final Media media;

  factory ApiImage.fromJson(Map<String, dynamic> json) => ApiImage(
    status: json["status"],
    request: Request.fromJson(json["request"]),
    nudity: Nudity.fromJson(json["nudity"]),
    gore: Gore.fromJson(json["gore"]),
    text: ApiText.fromJson(json["text"]),
    media: Media.fromJson(json["media"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "request": request.toJson(),
    "nudity": nudity.toJson(),
    "gore": gore.toJson(),
    "text": text.toJson(),
    "media": media.toJson(),
  };
}

class Gore {
  Gore({
    required this.prob,
  });

  final double prob;

  factory Gore.fromJson(Map<String, dynamic> json) => Gore(
    prob: json["prob"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "prob": prob,
  };
}

class Media {
  Media({
    required this.id,
    required this.uri,
  });

  final String id;
  final String uri;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json["id"],
    uri: json["uri"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uri": uri,
  };
}

class Nudity {
  Nudity({
    required this.raw,
    required this.safe,
    required this.partial,
  });

  final double raw;
  final double safe;
  final double partial;

  factory Nudity.fromJson(Map<String, dynamic> json) => Nudity(
    raw: json["raw"].toDouble(),
    safe: json["safe"].toDouble(),
    partial: json["partial"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "raw": raw,
    "safe": safe,
    "partial": partial,
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

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    id: json["id"],
    timestamp: json["timestamp"].toDouble(),
    operations: json["operations"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "timestamp": timestamp,
    "operations": operations,
  };
}

class ApiText {
  ApiText({
    required this.profanity,
    required this.personal,
    required this.link,
    required this.social,
    required this.ignoredText,
  });

  final List<dynamic> profanity;
  final List<dynamic> personal;
  final List<dynamic> link;
  final List<dynamic> social;
  final bool ignoredText;

  factory ApiText.fromJson(Map<String, dynamic> json) => ApiText(
    profanity: List<dynamic>.from(json["profanity"].map((x) => x)),
    personal: List<dynamic>.from(json["personal"].map((x) => x)),
    link: List<dynamic>.from(json["link"].map((x) => x)),
    social: List<dynamic>.from(json["social"].map((x) => x)),
    ignoredText: json["ignored_text"],
  );

  Map<String, dynamic> toJson() => {
    "profanity": List<dynamic>.from(profanity.map((x) => x)),
    "personal": List<dynamic>.from(personal.map((x) => x)),
    "link": List<dynamic>.from(link.map((x) => x)),
    "social": List<dynamic>.from(social.map((x) => x)),
    "ignored_text": ignoredText,
  };
}
