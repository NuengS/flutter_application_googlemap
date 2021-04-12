import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper({this.startLng, this.startLat, this.endLng, this.endLat});

  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getData() async {
    String apiKey = DotEnv.env['ors_key'];
    String url = DotEnv.env['ors_url'];
    String journeyMode = DotEnv.env['ors_journeyMode'];

    http.Response response = await http.get(
        '$url$journeyMode?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat');

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
