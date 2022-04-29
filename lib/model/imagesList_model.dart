class ImagesListModel {
  int? id;
  int? width;
  int? height;
  String? url;
  String? photographer;
  String? photographerUrl;
  int? photographerId;
  Src? src;
  bool? liked;

  ImagesListModel(
      {this.id,
      this.width,
      this.height,
      this.url,
      this.photographer,
      this.photographerUrl,
      this.photographerId,
      this.src,
      this.liked,
      });

  factory ImagesListModel.fromMap(Map<String, dynamic> jsonData) {
    return ImagesListModel(
      id: jsonData['id'],
      width: jsonData['width'],
      height: jsonData['height'],
      url: jsonData['url'],
      photographer: jsonData['photographer'],
      photographerUrl: jsonData['photographer_url'],
      photographerId: jsonData['photographer_id'],
      src: jsonData['src'] != null ? Src.fromMap(jsonData['src']) : null,
      liked: jsonData['liked'],
    );
  }

}

class Src{

  String? original;
  String? large2x;
  String? large;
  String? medium;
  String? small;
  String? portrait;
  String? landscape;
  String? tiny;

  Src(
    {
      this.original,
      this.large2x,
      this.large,
      this.medium,
      this.small,
      this.portrait,
      this.landscape,
      this.tiny
    }
  );

  factory Src.fromMap(Map<String, dynamic> jsonData){
    return Src(
      original: jsonData['original'],
      large2x: jsonData['large2x'],
      large: jsonData['large'],
      medium: jsonData['medium'],
      small: jsonData['small'],
      portrait: jsonData['portrait'],
      landscape: jsonData['landscape'],
      tiny: jsonData['tiny'],
    );
  }

}