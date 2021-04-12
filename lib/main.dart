import 'package:flutter/material.dart';
import './screens/sharemyplace_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

void main() async {
  await DotEnv.load();
  runApp(ShareMyPlaceApp());
}

class ShareMyPlaceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share my place',
      home: ShareMyPlaceScreen(),
      //theme: ThemeData.dark(),
    );
  }
}
