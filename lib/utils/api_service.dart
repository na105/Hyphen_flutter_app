import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:hyphen/model/api_image.dart';

class ApiService {
  Dio dio = Dio();

  static Future<ApiImage> getData(String filePath) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://api.sightengine.com/1.0/check.json'));

    // request.files.add(await http.MultipartFile.fromPath('media', filePath));
    request.fields['models'] = 'nudity,text-content,gore';
    request.fields['api_user'] = '358307286';
    request.fields['api_secret'] = 'Pto7NJ8YBKwNng3X8ki3';
    request.fields['url'] = filePath;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return ApiImage.fromJson(json);
    } else {
      throw Exception(response.body);
    }
  }

}
