import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/user/components/channel_talk.dart';
import 'package:conopot/screens/user/components/notice.dart';
import 'package:conopot/screens/user/etc_screen.dart';
import 'package:conopot/screens/user/login_screen.dart';
import 'package:conopot/screens/user/profile_modification_screen.dart';
import 'package:conopot/screens/user/user_liked_playlist_screen.dart';
import 'package:conopot/screens/user/user_share_playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  double defaultSize = SizeConfig.defaultSize;
  final storage = new FlutterSecureStorage();
  @override
  void initState() {
    Analytics_config().settingPageView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var loginState = Provider.of<NoteData>(context, listen: true).isLogined;
    var backUpDate = Provider.of<NoteData>(context, listen: true).backUpDate;

    return Consumer<MusicSearchItemLists>(
        builder: (
      context,
      musicList,
      child,
    ) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                  "내 정보",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                centerTitle: false,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultSize * 1.5),
                      color: kPrimaryLightBlackColor,
                      child: InkWell(
                        onTap: () {
                          (loginState == false)
                              ? loginEnter()
                              : modifyProfile();
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              userProfile(),
                              SizedBox(width: defaultSize * 2),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (loginState == false)
                                        ? "로그인"
                                        : Provider.of<NoteData>(context,
                                                listen: true)
                                            .userNickname,
                                    style: TextStyle(
                                        color: kPrimaryWhiteColor,
                                        fontSize: defaultSize * 1.8),
                                  ),
                                  (loginState == false)
                                      ? Text(
                                          "백업 기능 및 다양한 서비스를 이용해보세요!!",
                                          style: TextStyle(
                                              color: kPrimaryWhiteColor,
                                              fontSize: defaultSize * 1.2),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                              Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: kPrimaryWhiteColor,
                              )
                            ]),
                      ),
                    ),
                    SizedBox(height: defaultSize),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
                      color: kPrimaryLightBlackColor,
                      child: IntrinsicHeight(
                          child: Column(
                        children: [
                          SizedBox(height: defaultSize * 1.5),
                          InkWell(
                            onTap: () {
                              //!event:
                              (loginState == true)
                                  ? backUpDialog()
                                  : Fluttertoast.showToast(
                                      msg: "로그인 후 이용가능합니다",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Color(0xFFFF7878),
                                      textColor: kPrimaryWhiteColor,
                                      fontSize: defaultSize * 1.6);
                              ;
                            },
                            splashColor: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(
                                    "내 애창곡 노트 백업 및 가져오기",
                                    style: TextStyle(
                                        fontSize: defaultSize * 1.5,
                                        color: kMainColor),
                                  ),
                                  SizedBox(width: defaultSize),
                                ]),
                                Text(
                                  "마지막 백업 : $backUpDate",
                                  style: TextStyle(
                                    color: kPrimaryLightWhiteColor,
                                    fontSize: defaultSize * 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: defaultSize * 1.5),
                        ],
                      )),
                    ),
                    SizedBox(height: defaultSize * 1.5),
                    if (loginState == true)
                    Container(
                      color: kPrimaryLightBlackColor,
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: defaultSize * 1.5),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: defaultSize * 1.5),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserSharePlaylistScreen()));
                                  },
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    child: Row(children: [
                                      Text("내가 공유한 플레이리스트",
                                          style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Spacer(),
                                      Icon(Icons.chevron_right,
                                          color: kPrimaryWhiteColor)
                                    ]),
                                  ),
                                ),
                                SizedBox(height: defaultSize * 2),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserLikedPlaylistScreen()));
                                  },
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    child: Row(children: [
                                      Text("내가 좋아요한 플레이리스트",
                                          style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Spacer(),
                                      Icon(Icons.chevron_right,
                                          color: kPrimaryWhiteColor)
                                    ]),
                                  ),
                                ),
                                SizedBox(height: defaultSize * 1.5),
                              ]),
                        ),
                      ),
                    ),
                    if (loginState == true)
                    SizedBox(height: defaultSize * 1.5),
                    Container(
                      color: kPrimaryLightBlackColor,
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SwitchListTile(
                                activeColor: kMainColor,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: defaultSize * 1.5),
                                title: Text(
                                  "알림 설정",
                                  style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: Provider.of<NoteData>(context,
                                        listen: false)
                                    .isSubscribed,
                                onChanged: (bool value) async {
                                  await OneSignal.shared.disablePush(!value);
                                  if (value == true) {
                                    await storage.write(
                                        key: 'isSubscribed', value: 'yes');
                                  } else {
                                    await storage.write(
                                        key: 'isSubscribed', value: 'no');
                                  }
                                  setState(() {
                                    Provider.of<NoteData>(context,
                                            listen: false)
                                        .isSubscribed = value;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: kPrimaryLightBlackColor,
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: defaultSize * 1.5),
                            InkWell(
                              onTap: () {
                                Analytics_config().settingNotice();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NoticeScreen()));
                              },
                              splashColor: Colors.transparent,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: defaultSize * 1.5),
                                child: Row(children: [
                                  Text("공지사항",
                                      style: TextStyle(
                                        color: kPrimaryWhiteColor,
                                        fontSize: defaultSize * 1.5,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Spacer(),
                                  Icon(
                                    Icons.chevron_right,
                                    color: kPrimaryWhiteColor,
                                  ),
                                ]),
                              ),
                            ),
                            SizedBox(height: defaultSize * 1.5),
                          ],
                        ),
                      ),
                    ),
                    (loginState == true)
                        ? Container(
                            color: kPrimaryLightBlackColor,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EtcScreen()));
                              },
                              splashColor: Colors.transparent,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: defaultSize * 1.5),
                                child: Column(
                                  children: [
                                    SizedBox(height: defaultSize * 1.5),
                                    Row(children: [
                                      Text("기타",
                                          style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Spacer(),
                                      Icon(
                                        Icons.chevron_right_outlined,
                                        color: kPrimaryWhiteColor,
                                      )
                                    ]),
                                    SizedBox(height: defaultSize * 1.5),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                width: defaultSize * 4.8,
                height: defaultSize * 4.8,
                child: FittedBox(
                  child: FloatingActionButton(
                    elevation: 5.0,
                    onPressed: () {
                      Analytics_config().settingChannelTalk();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChannelTalkScreen()),
                      );
                    },
                    child: Image.asset(
                      "assets/images/channeltalk.png",
                    ),
                  ),
                ),
              ),
            ));
  }

  backUpDialog() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      //("인터넷 연결 성공");
      Provider.of<NoteData>(context, listen: false).showBackupDialog(context);
    } on SocketException {
      Fluttertoast.showToast(
          msg: "인터넷 연결 후 이용가능합니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xFFFF7878),
          textColor: kPrimaryWhiteColor,
          fontSize: defaultSize * 1.6);
    }
  }

  loginEnter() async {
    //!event: 내정보_뷰__로그인
    Analytics_config().userloginEvent();
    try {
      final result = await InternetAddress.lookup('example.com');
      //("인터넷 연결 성공");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on SocketException {
      Fluttertoast.showToast(
          msg: "인터넷 연결 후 이용가능합니다",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xFFFF7878),
          textColor: kPrimaryWhiteColor,
          fontSize: defaultSize * 1.6);
    }
  }

  modifyProfile() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProfileModificationScreen()));
  }

  userProfile() {
    if (Provider.of<NoteData>(context, listen: true).userImage == "") {
      // 기본 이미지
      return SvgPicture.asset("assets/icons/profile.svg");
    }
    //인터넷 연결 확인
    try {
      return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            width: defaultSize * 5,
            height: defaultSize * 5,
            child: Image.network(
              Provider.of<NoteData>(context, listen: true).userImage,
              fit: BoxFit.cover,
            ),
          ));
    } on SocketException {
      // 인터넷 연결이 안 되어 있을 때 -> 기본 이미지
      return SvgPicture.asset("assets/icons/profile.svg");
    }
  }
}
