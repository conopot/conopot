import 'dart:convert';
import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FeedReportScreen extends StatefulWidget {
  Post post;
  FeedReportScreen({super.key, required this.post});

  @override
  State<FeedReportScreen> createState() => _FeedReportScreenState();
}

class _FeedReportScreenState extends State<FeedReportScreen> {
  String _text = "";

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
        appBar: AppBar(title: Text("신고하기")),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultSize * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: defaultSize),
              Text("'${widget.post.postTitle}'",
                  style: TextStyle(color: kPrimaryWhiteColor)),
              Text("플레이 리스트를 신고하는 이유를 알려주세요",
                  style: TextStyle(color: kPrimaryWhiteColor)),
              Text("신속하게 해당 게시물에 대해서 조치를 취하겠습니다."),
              TextField(
                style: TextStyle(color: kPrimaryWhiteColor),
                onChanged: (text) => {
                  setState(() {
                    _text = text;
                  })
                },
                maxLines: 8,
                maxLength: 300,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                cursorColor: kMainColor,
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: kPrimaryLightWhiteColor),
                  fillColor: kPrimaryLightBlackColor,
                  filled: true,
                  hintText: '예시: 비속어를 사용했어요',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: defaultSize * 1.5,
                    color: kPrimaryLightGreyColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  String? serverURL = dotenv.env['USER_SERVER_URL'];
                  String URL = '${serverURL}/playlist/report';
                  try {
                    final response = await http.post(
                      Uri.parse(URL),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode({
                        "userId": Provider.of<NoteData>(context, listen: false).userId,
                        "postId" : widget.post.postId,
                        "reportScript" : _text
                      }),
                    );
                    Navigator.of(context).pop();
                  } on SocketException {
                    // 에러처리 (인터넷 연결 등등)
                    EasyLoading.showError("인터넷 연결을 확인해주세요");
                  }
                },
                child: Container(
                    padding: EdgeInsets.all(defaultSize),
                    decoration: BoxDecoration(
                        color: (_text.isNotEmpty)
                            ? kMainColor
                            : kPrimaryLightGreyColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("애창곡노트팀에게 보내기",
                            style: TextStyle(color: kPrimaryWhiteColor)),
                      ],
                    )),
              ),
              SizedBox(height: defaultSize * 3)
            ],
          ),
        ));
  }
}
