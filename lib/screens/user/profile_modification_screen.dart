import 'dart:convert';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  @override
  void initState() {
    this._controller = TextEditingController(
      text: Provider.of<NoteData>(context, listen: false).userNickname,
    );
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
                        child: SvgPicture.asset("assets/icons/profile.svg"),
                      )),
                  SizedBox(height: defaultSize * 1.5),
                  GestureDetector(
                      onTap: () {
                        EasyLoading.showInfo("서비스 준비중입니다 😿");
                      },
                      child: Text("프로필 아이콘 변경",
                          style: TextStyle(color: kMainColor)))
                ],
              ),
            ],
          ),
          SizedBox(height: defaultSize * 8),
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
          SizedBox(height: defaultSize * 5),
          GestureDetector(
            onTap: () async {
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
                  final response = await http.put(
                    Uri.parse(url),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': jwtToken!,
                    },
                    body: jsonEncode({
                      "username": (_controller.text.trim()),
                    }),
                  );

                  //print(response.statusCode);

                  //이미 존재하는 닉네임이라면
                  if (response.statusCode == 503) {
                    Fluttertoast.showToast(
                        msg: "이미 존재하는 닉네임입니다 😢",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color(0xFFFF7878),
                        textColor: kPrimaryWhiteColor,
                        fontSize: defaultSize * 1.6);
                  }
                  //응답이 제대로 왔다면
                  else if (response.statusCode == 200) {
                    //jwt 토큰 반환
                    String? jwtToken = response.headers['authorization'];

                    //로그인 성공 시 처리
                    //로컬 스토리지에 jwt 토큰 저장
                    Provider.of<NoteData>(context, listen: false)
                        .writeJWT(jwtToken);

                    Provider.of<NoteData>(context, listen: false)
                        .initAccountInfo();
                    //변경할 수 있다면
                    Navigator.of(context).pop();
                  }
                } catch (err) {
                  //print(err);
                }
              } else {
                //print("잘못된 글자수");
                //닉네임 글자 제한 처리
                Fluttertoast.showToast(
                    msg: "2글자 이상 10글자 이하로 설정해주세요 😢",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Color(0xFFFF7878),
                    textColor: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.6);
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
}
