import 'dart:convert';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RequestPitchInfoButton extends StatelessWidget {
  late Note note;
  double defaultSize = SizeConfig.defaultSize;
  RequestPitchInfoButton({Key? key, required this.note}) : super(key: key);

  final storage = new FlutterSecureStorage();

  // 최고음 요청 api
  void _requestPitchInfo(Note note) async {
    String url =
        'https://zeq3b9zt96.execute-api.ap-northeast-2.amazonaws.com/conopot/Conopot_Mailing';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "fields": {
          "MusicName": "${note.tj_title}",
          "MusicSinger": "${note.tj_singer}",
          "MusicNumberTJ": "${note.tj_songNumber}",
          "MusicNumberKY": "${note.ky_songNumber}",
          "Calls": 1,
          "Status": "To do"
        }
      }),
    );
  }

  // 최고음 정보요청 다이어로그 창 팝업 함수
  void _showRequestInfoDialog(BuildContext context) {
    Widget requestButton = ElevatedButton(
      onPressed: () async {
        String? value = await storage.read(key: "request${note.tj_songNumber}");

        //이미 요청된 노래인 경우
        if (value != null) {
          Fluttertoast.showToast(
              msg: "이미 최고음을 요청하신 노래입니다 :)",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
        } else {
          //!event : 최고음 요청
          Analytics_config().pitchRequestEvent(note.tj_title);
          // 정보요청
          _requestPitchInfo(note);
          storage.write(
              key: "request${note.tj_songNumber}", value: "requested");

          Fluttertoast.showToast(
              msg: "최고음 정보가 요청되었습니다 :)",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
        }

        // 정보요청
        Navigator.of(context).pop();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
      child: const Text(
        "요청",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );

    Widget cancelButton = ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
        child: const Text("취소", style: TextStyle(fontWeight: FontWeight.w600, color: kMainColor)));

    AlertDialog alert = AlertDialog(
      content: Text(
        "최고음이 표시 되지 않을 경우 최고음 정보를 요청해주세요 ☺️",
        style: TextStyle(
            fontSize: defaultSize * 1.6,
            fontWeight: FontWeight.w500,
            color: kPrimaryWhiteColor),
      ),
      actions: [cancelButton, requestButton],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  @override
  Widget build(BuildContext context) {
    String pitch = pitchNumToString[note.pitchNum];

    return pitch == '?'
        ? GestureDetector(
            onTap: () {
              _showRequestInfoDialog(context);
            },
            child: Container(
              width: defaultSize * 6.2,
              height: defaultSize * 2.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: kMainColor,
              ),
              child: Center(
                child: Text(
                  "정보요청",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: defaultSize * 1.2),
                ),
              ),
            ),
          )
        : Container();
  }
}
