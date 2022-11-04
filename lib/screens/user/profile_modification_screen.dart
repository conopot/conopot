import 'dart:convert';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

class ProfileModificationScreen extends StatefulWidget {
  const ProfileModificationScreen({super.key});

  @override
  State<ProfileModificationScreen> createState() =>
      _ProfileModificationScreenState();
}

class _ProfileModificationScreenState extends State<ProfileModificationScreen> {
  late TextEditingController _controller;
  final storage = new FlutterSecureStorage();
  double defaultSize = SizeConfig.defaultSize;
  bool _isProfileEditting = false;
  int _profileStatus = 0;
  String _originName = "";
  late int _originProfileStatus;
  late int _userId;

  @override
  void initState() {
    this._controller = TextEditingController(
      text: Provider.of<NoteData>(context, listen: false).userNickname,
    );
    _originName = Provider.of<NoteData>(context, listen: false).userNickname;
    _profileStatus =
        Provider.of<NoteData>(context, listen: false).profileStatus;
    _originProfileStatus = _profileStatus;
    _userId = Provider.of<NoteData>(context, listen: false).userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      appBar: AppBar(title: Text("프로필 수정"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: defaultSize * 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                      width: defaultSize * 10,
                      height: defaultSize * 10,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: FittedBox(
                        child: userProfile(),
                      )),
                  SizedBox(height: defaultSize * 1.5),
                  if (!_isProfileEditting && Provider.of<NoteData>(context, listen: false).userImage.isNotEmpty)
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _isProfileEditting = !_isProfileEditting;
                          });
                        },
                        child: Text("프로필 아이콘 변경",
                            style: TextStyle(color: kMainColor))),
                  if (_isProfileEditting && Provider.of<NoteData>(context, listen: false).userImage.isNotEmpty)
                    Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _profileStatus = 0;
                                });
                              },
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90.0),
                                  child: SizedBox(
                                    width: defaultSize * 5,
                                    height: defaultSize * 5,
                                    child: Image.network(
                                      Provider.of<NoteData>(context,
                                              listen: true)
                                          .userImage,
                                      errorBuilder:
                                          ((context, error, stackTrace) {
                                        return SizedBox(
                                            height: defaultSize * 4.5,
                                            width: defaultSize * 4.5,
                                            child: Image.asset(
                                                "assets/images/profile.png"));
                                      }),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                            SizedBox(width: defaultSize),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _profileStatus = 1;
                                });
                              },
                              child: SizedBox(
                                  width: defaultSize * 5,
                                  height: defaultSize * 5,
                                  child:
                                      Image.asset("assets/images/profile.png")),
                            ),
                          ],
                        ),
                        SizedBox(height: defaultSize),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _isProfileEditting = !_isProfileEditting;
                              });
                            },
                            child:
                                Text("확인", style: TextStyle(color: kMainColor)))
                      ],
                    )
                ],
              ),
            ],
          ),
          SizedBox(height: defaultSize * 3),
          Container(
            margin: EdgeInsets.symmetric(horizontal: defaultSize * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("닉네임",
                    style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: defaultSize * 1.6)),
                TextField(
                  controller: _controller,
                  maxLength: 10,
                  cursorColor: kPrimaryWhiteColor,
                  style: TextStyle(
                      color: kPrimaryWhiteColor, fontSize: defaultSize * 1.4),
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryWhiteColor),
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryWhiteColor)),
                      border: UnderlineInputBorder(),
                      hintText: '닉네임을 입력해 주세요',
                      hintStyle: TextStyle(color: kPrimaryLightGreyColor),
                      counterStyle: TextStyle(color: kPrimaryLightWhiteColor)),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.3),
          GestureDetector(
            onTap: () async {
              if (_originName == _controller.text &&
                  _originProfileStatus == _profileStatus) {
                Navigator.of(context).pop();
              } else if (_originName == _controller.text &&
                  _originProfileStatus != _profileStatus) {
                // 프로필 수정
                try {
                  String? serverURL = dotenv.env['USER_SERVER_URL'];
                  final response2 = await http.put(
                    Uri.parse('$serverURL/user/profile/status'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(
                        {"userId": _userId, "status": _profileStatus}),
                  );
                  if (response2.statusCode == 200) {
                    Provider.of<NoteData>(context, listen: false)
                        .changeProfileStatus(_profileStatus);
                    EasyLoading.showToast("프로필 수정이 완료되었습니다.");
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  EasyLoading.showToast("인터넷 연결을 확인해주세요.");
                }
              } else if (_originName != _controller.text &&
                  _originProfileStatus == _profileStatus) {
                //닉네임 변경 로직
                if (2 <= (_controller.text.trim()).length &&
                    (_controller.text.trim()).length <= 10) {
                  //print("올바른 글자수");
                  //api 호출
                  String? serverURL = dotenv.env['USER_SERVER_URL'];
                  String url = '$serverURL/user/account/nickname';
                  String? jwtToken = await storage.read(key: 'jwt');
                  try {
                    final response1 = await http.put(
                      Uri.parse(url),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization': jwtToken!,
                      },
                      body: jsonEncode({
                        "username": (_controller.text.trim()),
                      }),
                    );

                    //print(response1.statusCode);

                    //이미 존재하는 닉네임이라면
                    if (response1.statusCode == 503) {
                      EasyLoading.showToast("이미 존재하는 닉네임입니다.");
                    }
                    //응답이 제대로 왔다면
                    else if (response1.statusCode == 200) {
                      //jwt 토큰 반환
                      String? jwtToken = response1.headers['authorization'];
                      //로그인 성공 시 처리
                      //로컬 스토리지에 jwt 토큰 저장
                      Provider.of<NoteData>(context, listen: false)
                          .writeJWT(jwtToken);

                      Provider.of<NoteData>(context, listen: false)
                          .initAccountInfo();
                    }
                    EasyLoading.showToast("프로필 수정이 완료되었습니다.");
                    Navigator.of(context).pop();
                  } catch (e) {
                    EasyLoading.showToast("인터넷 연결을 확인해주세요.");
                  }
                }
              } else {
                //사전에 인터넷 연결 꼭 체크할것!!!
                //닉네임 변경 로직
                if (2 <= (_controller.text.trim()).length &&
                    (_controller.text.trim()).length <= 10) {
                  //print("올바른 글자수");
                  //api 호출
                  String? serverURL = dotenv.env['USER_SERVER_URL'];
                  String url = '$serverURL/user/account/nickname';
                  String? jwtToken = await storage.read(key: 'jwt');
                  try {
                    final response1 = await http.put(
                      Uri.parse(url),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization': jwtToken!,
                      },
                      body: jsonEncode({
                        "username": (_controller.text.trim()),
                      }),
                    );

                    //print(response1.statusCode);

                    //이미 존재하는 닉네임이라면
                    if (response1.statusCode == 503) {
                      EasyLoading.showToast("이미 존재하는 닉네임입니다.");
                    }
                    //응답이 제대로 왔다면
                    else if (response1.statusCode == 200) {
                      //jwt 토큰 반환
                      String? jwtToken = response1.headers['authorization'];
                      //로그인 성공 시 처리
                      //로컬 스토리지에 jwt 토큰 저장
                      Provider.of<NoteData>(context, listen: false)
                          .writeJWT(jwtToken);

                      Provider.of<NoteData>(context, listen: false)
                          .initAccountInfo();
                    }
                    String? serverURL = dotenv.env['USER_SERVER_URL'];
                    final response2 = await http.put(
                      Uri.parse('$serverURL:3000/user/profile/status'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(
                          {"userId": _userId, "status": _profileStatus}),
                    );

                    if (response1.statusCode == 200 &&
                        response2.statusCode == 200) {
                      Provider.of<NoteData>(context, listen: false)
                          .changeProfileStatus(_profileStatus);
                      //변경할 수 있다면
                      EasyLoading.showToast("프로필 수정이 완료되었습니다.");
                      Navigator.of(context).pop();
                    }
                  } catch (err) {
                    EasyLoading.showToast("인터넷 연결을 확인해주세요.");
                  }
                } else {
                  //print("잘못된 글자수");
                  //닉네임 글자 제한 처리
                  EasyLoading.showToast("두글자 이상 입력해주세요.");
                }
              }
            },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
              padding: EdgeInsets.fromLTRB(defaultSize * 1.5, defaultSize,
                  defaultSize * 1.5, defaultSize),
              decoration: BoxDecoration(
                  color: (_controller.text.length == 0)
                      ? kPrimaryLightBlackColor
                      : kMainColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Text(
                "변경사항 저장",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ]),
      ),
    );
  }

  userProfile() {
    if (Provider.of<NoteData>(context, listen: false).userImage == "") {
      // 기본 이미지
      return SizedBox(
          height: defaultSize * 10,
          width: defaultSize * 10,
          child: Image.asset("assets/images/profile.png"));
    }

    if (_profileStatus == 0) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            width: defaultSize * 10,
            height: defaultSize * 10,
            child: Image.network(
              Provider.of<NoteData>(context, listen: true).userImage,
              errorBuilder: ((context, error, stackTrace) {
                return SizedBox(
                    height: defaultSize * 10,
                    width: defaultSize * 10,
                    child: Image.asset("assets/images/profile.png"));
                ;
              }),
              fit: BoxFit.cover,
            ),
          ));
    }
    if (_profileStatus == 1) {
      // 기본 이미지
      return SizedBox(
          width: defaultSize * 10,
          height: defaultSize * 10,
          child: Image.asset("assets/images/profile.png"));
    }
  }
}
