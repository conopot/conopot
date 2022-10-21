import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/user/components/channel_talk.dart';
import 'package:conopot/screens/user/components/notice.dart';
import 'package:conopot/screens/user/login_screen.dart';
import 'package:conopot/screens/user/profile_modification_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  //리워드가 존재하는지 체크
  bool rewardFlag = false;
  String rewardRemainTime = "";

  rewardCheck() async {
    rewardFlag =
        await Provider.of<NoteData>(context, listen: false).isUserRewarded();
  }

  rewardRemainTimeCheck() async {
    rewardRemainTime =
        await Provider.of<NoteData>(context, listen: false).userRewardedTime();
  }

  @override
  void initState() {
    Analytics_config().settingPageView();
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Map<String, String> Reward_UNIT_ID = kReleaseMode
      ? {
          'android': 'ca-app-pub-7139143792782560/7541506805',
          'ios': 'ca-app-pub-7139143792782560/5591745282',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/5224354917',
          'ios': 'ca-app-pub-3940256099942544/5224354917',
        };

  // TODO: Add _rewardedAd
  RewardedAd? _rewardedAd;

  // TODO: Implement _loadRewardedAd()
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: Reward_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
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
                    Container(
                      color: kPrimaryLightBlackColor,
                      child: IntrinsicHeight(
                        child: Column(children: [
                          SizedBox(height: defaultSize * 2),
                          InkWell(
                            onTap: () async {
                              await rewardCheck();
                              await rewardRemainTimeCheck();
                              (rewardFlag == true)
                                  ? showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: kDialogColor,
                                          shape: const RoundedRectangleBorder(
                                              side: BorderSide(width: 0.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          title: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "광고 제거 효과",
                                                  style: TextStyle(
                                                    color: kMainColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: defaultSize * 1.7,
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: '가 적용 중입니다',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: kPrimaryWhiteColor,
                                                      fontSize:
                                                          defaultSize * 1.7,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          content: Text(
                                            '현재 남은 시간 : ${rewardRemainTime}',
                                            style: TextStyle(
                                                fontSize: defaultSize * 1.5,
                                                fontWeight: FontWeight.w300,
                                                color: kPrimaryWhiteColor),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          kPrimaryGreyColor),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        width: 0.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ))),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "취소",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: kMainColor),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: kDialogColor,
                                          shape: const RoundedRectangleBorder(
                                              side: BorderSide(width: 0.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8))),
                                          title: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: '광고 제거 버전',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: kMainColor,
                                                      fontSize:
                                                          defaultSize * 1.7,
                                                    )),
                                                TextSpan(
                                                    text: ' 체험해보기',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: kPrimaryWhiteColor,
                                                      fontSize:
                                                          defaultSize * 1.7,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          content: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "30초 광고 보고\n",
                                                  style: TextStyle(
                                                    color: kPrimaryWhiteColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: defaultSize * 1.5,
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: '30분 동안 모든 광고',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: kMainColor,
                                                      fontSize:
                                                          defaultSize * 1.5,
                                                    )),
                                                TextSpan(
                                                  text:
                                                      '가 제거된\n클린한 애창곡 노트를 사용해보세요 🐱\n',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: kPrimaryWhiteColor,
                                                    fontSize: defaultSize * 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          kPrimaryGreyColor),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        width: 0.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ))),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                "취소",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: kMainColor),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          kMainColor),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        width: 0.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ))),
                                              onPressed: () async {
                                                if (_rewardedAd != null) {
                                                  Navigator.pop(context);
                                                  _rewardedAd?.show(
                                                    onUserEarnedReward:
                                                        (_, reward) async {
                                                      //리워드 광고 재생 및 로컬 스토리지 세팅
                                                      //30분 간 광고가 나오지 않게 한다.
                                                      int rewardTime = DateTime
                                                              .now()
                                                          .millisecondsSinceEpoch;
                                                      print(
                                                          "광고 보고 리워드 획득 상태 : ${rewardTime}");

                                                      //30분 추가
                                                      rewardTime =
                                                          rewardTime + 1800000;
                                                      print(
                                                          "광고 보고 리워드 획득 상태 30분 증가 : ${rewardTime}");
                                                      await storage.write(
                                                          key: 'rewardTime',
                                                          value: rewardTime
                                                              .toString());
                                                    },
                                                  );
                                                } else {
                                                  Navigator.pop(context);
                                                  int rewardTime = DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch;
                                                  print(
                                                      "광고 보고 리워드 획득 상태 : ${rewardTime}");

                                                  //30분 추가
                                                  rewardTime =
                                                      rewardTime + 300000;
                                                  print(
                                                      "광고 보고 리워드 획득 상태 5분 증가 : ${rewardTime}");
                                                  await storage.write(
                                                      key: 'rewardTime',
                                                      value: rewardTime
                                                          .toString());
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "볼 수 있는 광고가 없네요 😅\n5분간 무료로 광고 제거 효과를 적용해드릴게요",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Color(0xFFFF7878),
                                                      textColor:
                                                          kPrimaryWhiteColor,
                                                      fontSize:
                                                          defaultSize * 1.6);
                                                }
                                              },
                                              child: Text(
                                                "광고 보기",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: kPrimaryWhiteColor),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                            },
                            splashColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: defaultSize * 1.5),
                              child: Row(children: [
                                Text("광고 제거",
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
                          (loginState == true)
                              ? SizedBox(height: defaultSize * 1.5)
                              : SizedBox.shrink(),
                          //로그아웃 버튼
                          (loginState == true)
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      Provider.of<NoteData>(context,
                                              listen: false)
                                          .showAccountDialog(context, "logout");
                                    });
                                  },
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: defaultSize * 1.5),
                                    child: Row(children: [
                                      Text("로그아웃",
                                          style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ]),
                                  ),
                                )
                              : SizedBox.shrink(),
                          (loginState == true)
                              ? SizedBox(height: defaultSize * 3)
                              : SizedBox.shrink(),
                          //회원탈퇴 버튼
                          (loginState == true)
                              ? InkWell(
                                  onTap: () {
                                    Provider.of<NoteData>(context,
                                            listen: false)
                                        .showAccountDialog(context, "delete");
                                  },
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: defaultSize * 1.5),
                                    child: Row(children: [
                                      Text("탈퇴하기",
                                          style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.5,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      SizedBox(height: defaultSize * 1.5),
                                    ]),
                                  ),
                                )
                              : SizedBox.shrink(),
                          (loginState == true)
                              ? SizedBox(height: defaultSize * 2)
                              : SizedBox(height: defaultSize)
                        ]),
                      ),
                    ),
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
