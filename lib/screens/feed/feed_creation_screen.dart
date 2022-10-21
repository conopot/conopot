import 'dart:convert';
import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/debounce.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/components/added_playlist.dart';
import 'package:conopot/screens/feed/components/editing_playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CreateFeedScreen extends StatefulWidget {
  const CreateFeedScreen({super.key});

  @override
  State<CreateFeedScreen> createState() => _CreateFeedScreenState();
}

class _CreateFeedScreenState extends State<CreateFeedScreen> {
  int _emotionIndex = 0; // 😀, 🥲, 😡, 😳, 🫠
  var _emotionList = ["😀", "🥲", "😡", "😳", "🫠"];
  bool _isIconEditting = false;
  bool _isListEditting = false;
  String _listName = "";
  String _explanation = "";

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      appBar: AppBar(
        title: Text("플레이리스트 공유", style: TextStyle(color: kPrimaryWhiteColor)),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () async {
                if (_listName.isEmpty) {
                  EasyLoading.showToast("리스트명을 입력해주세요");
                } else if (Provider.of<NoteData>(context, listen: false)
                        .lists
                        .length <
                    3) {
                  EasyLoading.showToast("노래를 세곡 이상 추가해주세요");
                } else {
                  List<String> songList =
                      Provider.of<NoteData>(context, listen: false)
                          .lists
                          .map((e) => e.tj_songNumber)
                          .toList();
                  try {
                    String? serverURL = dotenv.env['USER_SERVER_URL'];
                    String URL = "${serverURL}/playlist/create";
                    final response = await http.post(
                      Uri.parse(URL),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode({
                        "postTitle": _listName,
                        "postIconId": _emotionIndex,
                        "postSubscription": _explanation,
                        "postAuthorId":
                            Provider.of<NoteData>(context, listen: false)
                                .userId,
                        "postMusicList": jsonEncode(songList)
                      }),
                    );
                    int userId =
                        Provider.of<NoteData>(context, listen: false).userId;
                    String externalUserId = userId.toString();
                    // 플레이리스트 공유 완료 후 userId를 externalUserId로 지정
                    if (userId != 0) {
                      OneSignal.shared
                          .setExternalUserId(externalUserId)
                          .then((results) {})
                          .catchError((error) {
                        print(error.toString());
                      });
                    }
                    Navigator.of(context).pop();
                    EasyLoading.showToast("공유가 완료되었습니다.");
                  } on SocketException {
                    // 인터넷 연결 예외처리
                    EasyLoading.showToast("인터넷 연결을 확인해주세요");
                  }
                }
              },
              child: Container(
                  padding: EdgeInsets.fromLTRB(defaultSize, defaultSize * 0.5,
                      defaultSize, defaultSize * 0.5),
                  decoration: BoxDecoration(
                      color: kMainColor.withOpacity(0.8),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Text("완료",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: defaultSize * 1.2))))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultSize),
          child: ListView(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: defaultSize * 14,
                  child: Column(
                    children: [
                      Text("감정 이모지",
                          style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.6,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: defaultSize),
                      Text(
                        "${_emotionList[_emotionIndex]}",
                        style: TextStyle(fontSize: defaultSize * 4),
                      ),
                      SizedBox(height: defaultSize * 1.25),
                      (_isIconEditting == false)
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isIconEditting = true;
                                });
                              },
                              child: Text("변경하기",
                                  style: TextStyle(
                                      color: kMainColor,
                                      fontSize: defaultSize * 1.3)))
                          : Container(
                              child: IntrinsicWidth(
                                  child: Column(
                                children: [
                                  Row(
                                      children: _emotionList
                                          .map((e) => Container(
                                                margin: EdgeInsets.only(
                                                    left: defaultSize),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _emotionIndex =
                                                          _emotionList
                                                              .indexOf(e);
                                                      _isIconEditting = false;
                                                    });
                                                  },
                                                  child: Text(e,
                                                      style: TextStyle(
                                                          fontSize:
                                                              defaultSize * 2)),
                                                ),
                                              ))
                                          .toList()),
                                  SizedBox(height: defaultSize * 0.5),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isIconEditting = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: kPrimaryWhiteColor,
                                        size: defaultSize * 1.8,
                                      ))
                                ],
                              )),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultSize * 2),
            Text("리스트명 (필수)",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: defaultSize * 1.5)),
            SizedBox(height: defaultSize * 0.5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: defaultSize),
              decoration: BoxDecoration(
                color: kPrimaryLightBlackColor,
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: TextField(
                style: TextStyle(color: kPrimaryWhiteColor),
                onChanged: (text) => {
                  setState(() {
                    _listName = text;
                  })
                },
                maxLength: 50,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                cursorColor: kMainColor,
                decoration: InputDecoration(
                  counter: SizedBox.shrink(),
                  hintText: '리스트명을 입력해주세요',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: defaultSize * 1.5,
                    color: kPrimaryLightGreyColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: defaultSize * 2),
            Text("추가설명 (선택)",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: defaultSize * 1.5)),
            SizedBox(height: defaultSize * 0.5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: defaultSize),
              decoration: BoxDecoration(
                color: kPrimaryLightBlackColor,
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: TextField(
                style: TextStyle(color: kPrimaryWhiteColor),
                onChanged: (text) => {
                  setState(() {
                    _explanation = text;
                  })
                },
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 200,
                cursorColor: kMainColor,
                decoration: InputDecoration(
                  counter: SizedBox.shrink(),
                  hintText: '추가설명을 입력해주세요',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: defaultSize * 1.5,
                    color: kPrimaryLightGreyColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: defaultSize * 5),
            Row(
              children: [
                Text("플레이리스트",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.5,
                        fontWeight: FontWeight.w500)),
                Spacer(),
                if (Provider.of<NoteData>(context, listen: true)
                        .lists
                        .isNotEmpty ||
                    _isListEditting == true)
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _isListEditting = !_isListEditting;
                        });
                      },
                      child: Text((_isListEditting) ? "완료" : "편집하기",
                          style: TextStyle(
                              color: kMainColor, fontWeight: FontWeight.w500)))
              ],
            ),
            SizedBox(height: defaultSize),
            (_isListEditting) ? EditingPlayList() : AddedPlaylist(),
          ]),
        ),
      ),
    );
  }
}
