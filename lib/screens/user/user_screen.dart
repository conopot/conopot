import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/user/components/channel_talk.dart';
import 'package:conopot/screens/user/components/notice.dart';
import 'package:conopot/screens/user/login_screen.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
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
    super.initState();
    Analytics_config.analytics.logEvent("내 정보 뷰 - 페이지뷰");
  }

  @override
  Widget build(BuildContext context) {
    Analytics_config().settingPageView();
    return Consumer<MusicSearchItemLists>(
        builder: (
      context,
      musicList,
      child,
    ) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                  "MY",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultSize * 1.5),
                      color: kPrimaryLightBlackColor,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Row(children: [
                          SvgPicture.asset("assets/icons/profile.svg"),
                          SizedBox(width: defaultSize),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "로그인",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.8),
                              ),
                              Text(
                                "백업 기능 및 다양한 서비스를 이용해보세요!!",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.2),
                              )
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: kPrimaryWhiteColor,
                          ),
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
                              Provider.of<NoteData>(context, listen: false)
                                  .showBackupDialog(context);
                            },
                            splashColor: Colors.transparent,
                            child: Row(children: [
                              Text(
                                "내 애창곡 노트",
                                style: TextStyle(
                                    fontSize: defaultSize * 1.5,
                                    color: kPrimaryWhiteColor),
                              ),
                              Spacer(),
                              Text(
                                "백업 및 가져오기",
                                style: TextStyle(
                                    fontSize: defaultSize * 1.5,
                                    color: kMainColor),
                              ),
                              SizedBox(width: defaultSize),
                            ]),
                          ),
                          SizedBox(height: defaultSize * 1.5),
                        ],
                      )),
                    ),
                    SizedBox(height: defaultSize),
                    Container(
                      color: kPrimaryLightBlackColor,
                      child: IntrinsicHeight(
                        child: Column(children: [
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
                          SizedBox(height: defaultSize),
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
                              value:
                                  Provider.of<NoteData>(context, listen: false)
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
                                  Provider.of<NoteData>(context, listen: false)
                                      .isSubscribed = value;
                                });
                              }),
                          SizedBox(height: defaultSize),
                          InkWell(
                            onTap: () {
                              Provider.of<NoteData>(context, listen: false).showDeleteAccountDialog(context);
                            },
                            splashColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: defaultSize * 1.5),
                              child: Row(children: [
                                Text("회원탈퇴",
                                    style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontSize: defaultSize * 1.5,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ]),
                            ),
                          ),
                          SizedBox(height: defaultSize * 1.5),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                width: defaultSize * 7.2,
                height: defaultSize * 7.2,
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
}
