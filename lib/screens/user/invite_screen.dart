import 'dart:convert';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/youtube_player_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class InviteScreen extends StatefulWidget {
  InviteScreen({Key? key}) : super(key: key);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final storage = new FlutterSecureStorage();
  TextEditingController _controller = TextEditingController();
  String userInviteCode = "";
  int userInvitePersonCount = 0;
  bool userInviteStatus = false;

  getUserInviteStatus() async {
    int userId = Provider.of<NoteData>(context, listen: false).userId;
    String? serverURL = dotenv.env['USER_SERVER_URL'];

    String url = '$serverURL/user/invite/status?userId=$userId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      print(data["inviteCodeStatus"]);
      if (data == null || data["inviteCodeStatus"] == null) return;
      if (data["inviteCodeStatus"] == true) {
        setState(() {
          userInviteStatus = true;
        });
      }
    } catch (err) {
      print("getUserInvitePersonCount 실패 : ${err}");
      EasyLoading.showToast("인터넷 연결을 확인해주세요 😭");
    }
  }

  getUserInvitePersonCount() async {
    int userId = Provider.of<NoteData>(context, listen: false).userId;
    String? serverURL = dotenv.env['USER_SERVER_URL'];

    String url = '$serverURL/user/invite/count?userId=$userId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      if (data == null || data["invitePersonCount"] == null) return;
      setState(() {
        userInvitePersonCount = data["invitePersonCount"];
      });
    } catch (err) {
      print("getUserInvitePersonCount 실패 : ${err}");
      EasyLoading.showToast("인터넷 연결을 확인해주세요 😭");
    }
  }

  @override
  void initState() {
    Analytics_config().invitePageView();
    this._controller = TextEditingController(
      text: '',
    );
    //사용자 초대 코드
    userInviteCode = Provider.of<NoteData>(context, listen: false)
            .userId
            .toString() +
        "Ksc9a" +
        (Provider.of<NoteData>(context, listen: false).userId % 10).toString();

    //사용자가 초대한 사람 수 (api 호출)
    getUserInviteStatus();
    getUserInvitePersonCount();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return WillPopScope(
      onWillPop: () async {
        Provider.of<YoutubePlayerProvider>(context, listen: false)
                .openPlayer();
            Provider.of<YoutubePlayerProvider>(context, listen: false)
                .refresh();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("친구초대", style: TextStyle(color: kPrimaryWhiteColor)),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: defaultSize),
            padding: EdgeInsets.all(defaultSize * 2),
            decoration: BoxDecoration(
                color: kPrimaryLightBlackColor,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Column(
              children: [
                Text("친구초대하고",
                    style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontSize: defaultSize * 1.9,
                        fontWeight: FontWeight.w600)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "평생 광고제거 ",
                          style: TextStyle(
                              color: kMainColor,
                              fontSize: defaultSize * 1.9,
                              fontWeight: FontWeight.w600)),
                      TextSpan(
                          text: "받아보세요!",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.9,
                              fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                SizedBox(height: defaultSize * 2),
                Image.asset(
                  "assets/images/test.png",
                  width: defaultSize * 10,
                  height: defaultSize * 10,
                ),
                SizedBox(height: defaultSize * 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "초대받은 친구가 ",
                          style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.2,
                              fontWeight: FontWeight.w600)),
                      TextSpan(
                          text: "로그인하고 노트 3개 이상 추가 ",
                          style: TextStyle(
                              color: kMainColor,
                              fontSize: defaultSize * 1.2,
                              fontWeight: FontWeight.w600)),
                      TextSpan(
                          text: "후",
                          style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.2,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(
                  "내가 준 초대코드를 입력하면 평생 광고제거 받을 수 있어요",
                  style: TextStyle(
                      color: kPrimaryLightWhiteColor,
                      fontSize: defaultSize * 1.2,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: defaultSize * 4),
                Container(
                  padding: EdgeInsets.all(defaultSize),
                  decoration: BoxDecoration(
                    color: kPrimaryGreyColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "내 초대 코드  |  ",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 1.7,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "  " + userInviteCode + "    ",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 1.7,
                            fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.copy,
                          color: kPrimaryWhiteColor,
                          size: defaultSize * 2,
                        ),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: userInviteCode));
                          EasyLoading.showToast("초대 코드가 복사되었습니다");
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: defaultSize * 4),
                Text(
                  "공유하기",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 1.7,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: defaultSize * 2),
                GestureDetector(
                  onTap: () {
                    Analytics_config().inviteShare();
                    //카카오톡 공유하기
                    shareKakaoTalk();
                  },
                  child: Image.asset(
                    "assets/images/kakao-talk.png",
                    width: defaultSize * 5,
                    height: defaultSize * 5,
                  ),
                ),
                SizedBox(height: defaultSize * 5),
                Text(
                  "초대 코드 입력하기",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 1.7,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: defaultSize * 1),
                TextField(
                  controller: _controller,
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
                      hintText: '초대 코드를 입력해 주세요',
                      hintStyle: TextStyle(color: kPrimaryLightGreyColor),
                      counterStyle: TextStyle(color: kPrimaryLightWhiteColor)),
                ),
                SizedBox(height: defaultSize * 2),
                GestureDetector(
                  onTap: () {
                    // 이미 인증을 한 사용자라면
                    if (userInviteStatus == true) {
                      EasyLoading.showToast("이미 인증을 하였습니다.");
                    }
                    // 노트를 3개 이상 가지고 있지 않은 사용자라면
                    else if (Provider.of<NoteData>(context, listen: false)
                            .notes
                            .length <
                        3) {
                      EasyLoading.showToast("노트를 3개 이상 등록해주세요");
                    } else {
                      Analytics_config().inviteAuth();
                      //인증 로직
                      inviteValidation(_controller.text);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 1.5, defaultSize,
                        defaultSize * 1.5, defaultSize),
                    decoration: BoxDecoration(
                        color: (userInviteStatus == true)
                            ? kPrimaryGreyColor
                            : kMainColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      "인증하기",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(height: defaultSize * 5),
                Text(
                  "내 친구 초대 현황",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 1.5,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: defaultSize * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      "assets/images/singing_cat.png",
                      width: defaultSize * 5,
                      height: defaultSize * 5,
                      opacity: (userInvitePersonCount >= 1)
                          ? AlwaysStoppedAnimation(1)
                          : AlwaysStoppedAnimation(.3),
                    ),
                    Image.asset(
                      "assets/images/singing_cat.png",
                      width: defaultSize * 5,
                      height: defaultSize * 5,
                      opacity: (userInvitePersonCount >= 2)
                          ? AlwaysStoppedAnimation(1)
                          : AlwaysStoppedAnimation(.3),
                    ),
                    Image.asset(
                      "assets/images/singing_cat.png",
                      width: defaultSize * 5,
                      height: defaultSize * 5,
                      opacity: (userInvitePersonCount >= 3)
                          ? AlwaysStoppedAnimation(1)
                          : AlwaysStoppedAnimation(.3),
                    ),
                  ],
                ),
                SizedBox(height: defaultSize * 5),
                GestureDetector(
                  onTap: () {
                    // 이미 광고 제거 효과인 경우
                    if (Provider.of<NoteData>(context, listen: false)
                            .userAdRemove ==
                        true) {
                      EasyLoading.showToast("이미 광고 제거 효과를 받았습니다 😆");
                    }
                    //인증 로직
                    else if (userInvitePersonCount >= 3) {
                      Analytics_config().inviteGetReward();
                      //해당 유저 광고 제거 효과 설정
                      userAdRemove();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 1.5, defaultSize,
                        defaultSize * 1.5, defaultSize),
                    decoration: BoxDecoration(
                        color: (userInvitePersonCount >= 3)
                            ? kMainColor
                            : kPrimaryGreyColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Text(
                      "광고제거 적용 받기",
                      style: TextStyle(
                          color: (userInvitePersonCount >= 3)
                              ? kPrimaryWhiteColor
                              : kPrimaryBlackColor,
                          fontSize: defaultSize * 1.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(height: defaultSize * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void shareKakaoTalk() async {
    // 사용자 정의 템플릿 ID
    int templateId = 85726;
    // 카카오톡 실행 가능 여부 확인
    bool isKakaoTalkSharingAvailable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();

    if (isKakaoTalkSharingAvailable) {
      try {
        Uri uri = await ShareClient.instance.shareCustom(
            templateId: templateId, templateArgs: {'userCode': userInviteCode});
        await ShareClient.instance.launchKakaoTalk(uri);
        print('카카오톡 공유 완료');
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    } else {
      try {
        Uri shareUrl = await WebSharerClient.instance.makeCustomUrl(
            templateId: templateId, templateArgs: {'userCode': userInviteCode});
        await launchBrowserTab(shareUrl);
      } catch (error) {
        print('카카오톡 공유 실패 $error');
      }
    }
  }

  //초대 코드 검증 로직
  inviteValidation(String inviteCode) {
    //검증하기 : "{userId}Ksc9a{userId}" 형태인지 확인
    String hashString = "Ksc9a";
    int hashIndex = inviteCode.indexOf(hashString);
    if (hashIndex == -1) {
      EasyLoading.showToast("존재하지 않는 초대 코드입니다");
      return;
    }
    int leftNum = int.parse(inviteCode.substring(0, hashIndex));
    int rightNum = int.parse(inviteCode[inviteCode.length - 1]);
    if ((leftNum % 10 != rightNum) || (leftNum == 0)) {
      EasyLoading.showToast("존재하지 않는 초대 코드입니다");
      return;
    }

    //실제로 초대한 유저 Id
    int inviteUserId = 0;
    for (int i = 0; i < inviteCode.length; i++) {
      if (inviteCode[i] == 'K') break;
      inviteUserId *= 10;
      inviteUserId += int.parse(inviteCode[i]);
    }

    //검증하기 : 입력한 코드 == 내 코드인지 확인
    if (inviteUserId == Provider.of<NoteData>(context, listen: false).userId) {
      EasyLoading.showToast("내 코드는 입력할 수 없어요 😭");
      return;
    }

    //검증하기 : 초대"한" 유저가 초대"받은" 유저보다 가입 순서가 늦다면
    if (inviteUserId < Provider.of<NoteData>(context, listen: false).userId) {
      EasyLoading.showToast("나 보다 늦게 가입한 유저의 코드는 입력할 수 없어요 😭");
      return;
    }

    //검증이 완료된 상태 해당 userId 서버에 전송
    inviteComplete(inviteUserId);
  }

  inviteComplete(int inviteUserId) async {
    int userId = Provider.of<NoteData>(context, listen: false).userId;
    String? serverURL = dotenv.env['USER_SERVER_URL'];

    //초대"한" 사람의 카운트 +1 증가
    String url = '$serverURL/user/invite/count/add?userId=$inviteUserId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
    } catch (err) {
      print("inviteComplete 실패 : ${err}");
    }

    //내 초대 상태 false -> true
    url = '$serverURL/user/invite/status/change?userId=$inviteUserId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      EasyLoading.showToast("인증이 완료되었어요 🤗");
      setState(() {
        userInviteStatus = true;
      });
    } catch (err) {
      print("내 초대 상태 변경 실패 : ${err}");
      EasyLoading.showToast("인터넷 연결을 확인해주세요 😭");
    }
  }

  //해당 유저의 광고 제거
  userAdRemove() async {
    int userId = Provider.of<NoteData>(context, listen: false).userId;
    //로컬 스토리지에 광고 제거 적용
    await storage.write(key: 'adRemove', value: "true");
    Provider.of<NoteData>(context, listen: false).userAdRemove = true;

    //서버에 광고 제거 상태 변경
    String? serverURL = dotenv.env['USER_SERVER_URL'];

    //사용자 광고 상태 변경
    String url = '$serverURL/user/ad/status/change?userId=$userId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      EasyLoading.showToast("광고 제거 효과가 적용되었습니다 😆");
    } catch (err) {
      print("광고 제거 상태 변경 실패 : ${err}");
      EasyLoading.showToast("인터넷 연결을 확인해주세요 😭");
    }
  }
}
