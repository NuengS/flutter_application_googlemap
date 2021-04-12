import 'package:flutter/material.dart';
import 'package:flash/flash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;

class CommonData {
  static const SKRU_TITLE = 'Songkhla Rajabhat University';
  static const SKRU_DESCRIPTION = '''
    Songkhla Rajabhat University (Thai: มหาวิทยาลัยราชภัฏสงขลา) or SKRU is a Thai public university under the Rajabhat University system. The campus is in Songkhla Province, south Thailand.[1]  Songkhla Rajabhat University contains seven faculties: Arts, Agricultural Technology, Education, Humanities and Social Science, Industrial Technology, Management Science, and Science and Technology.''';
  static const SKRU_IMAGE =
      'https://sites.google.com/site/yengthoonfaisan/_/rsrc/1519054270756/config/customLogo.gif?revision=7';
  static const SKRU_LATLNG = LatLng(7.172265216145902, 100.61383998810894);
  static const ComSci_TITLE = 'Computer Science (SKRU)';
  static const ComSci_DESCRIPTION = '''
    ปีการศึกษา 2530 ขณะที่สถาบันราชภัฏสงขลายังคงเป็นวิทยาลัยครูสงขลา ภาควิชาคณิตศาสตร์ได้ทำการเปิดสอนวิชาโทคอมพิวเตอร์ให้กับนักศึกษาเอก คณิตศาสตร์  ปีการศึกษา 2536-2540 เป็นช่วงต้นของการเปลี่ยนแปลงจากวิทยาลัยครูสู่สถาบันราชภัฏสงขลา มีการจัดตั้งภาควิชาคอมพิวเตอร์ศึกษาทำหน้าที่ ความรับผิดชอบ การเรียนการสอนวิชาคอมพิวเตอร์ ทั้งในส่วนของหลักสูตรวิทยาการคอมพิวเตอร์ และหลักสูตรคอมพิวเตอร์ศึกษา  ปีการศึกษา 2541-2542 สถาบันราชภัฏสงขลาได้ปรับมาตรฐานการเรียนการสอน เพื่อรองรับการประกันคุณภาพและการบริหารแบบโปรแกรมวิชา มีการแต่งตั้งคณะกรรมการบริหาร โปรแกรมวิชาวิทยาการคอมพิวเตอร์ และวิชาคอมพิวเตอร์ศึกษา มีการจัดทำคู่มือโปรแกรมวิชา  ปีการศึกษา 2543 มีการจัดทำเกณฑ์มาตรฐานโปรมวิชา จัดทำรายงานการศึกษาตนเอง จัดทำคู่มือบริหารโปรแกรมวิชา และจัดทำคู่มือนักศึกษาในโปรแกรมวิชา  ปีการศึกษา 2547 ได้เปิดสอนหลักสูตรเทคโนโลยีสารสนเทศขึ้นเป็นปีแรก
    ''';
  static const ComSci_IMAGE =
      'https://sci.skru.ac.th/science/images/building/IMG_6950.jpg';
  static const ComSci_LATLNG = LatLng(7.166961325721222, 100.61281237129259);

  static get polygonLatLngComSci {
    List<LatLng> _polygonLatLngComSci = [];
    _polygonLatLngComSci.add(LatLng(7.167031636560606, 100.61265602322639));
    _polygonLatLngComSci.add(LatLng(7.166943815238209, 100.61303823800192));
    _polygonLatLngComSci.add(LatLng(7.166845348886892, 100.61301946253927));
    _polygonLatLngComSci.add(LatLng(7.16691720271293, 100.61263456555477));
    return _polygonLatLngComSci;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

Future showConfirmDialog(BuildContext context, String titleText,
    String contentText, Function okHandle, Function cancelHandle) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(contentText),
          actions: [
            new FlatButton(
              child: new Text("OK"),
              onPressed: okHandle,
            ),
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: cancelHandle,
            )
          ],
        );
      });
}

Future showFlashDialog(
    BuildContext context, String flashTitle, String flashText) {
  return showFlash(
      context: context,
      duration: Duration(seconds: 3),
      builder: (context, controller) {
        return Flash.bar(
          position: FlashPosition.bottom,
          backgroundGradient:
              LinearGradient(colors: [Colors.black, Colors.blueGrey]),
          enableDrag: true,
          horizontalDismissDirection: HorizontalDismissDirection.startToEnd,
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.all(Radius.circular(5)),
          controller: controller,
          child: FlashBar(
            message: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.greenAccent,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      flashTitle,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    flashText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ]),
          ),
        );
      });
}
