import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/main_screen.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:conopot/screens/user/components/channel_talk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart' as tt;
import 'package:url_launcher/url_launcher.dart';
import 'note.dart';

class NoteData extends ChangeNotifier {
  List<Note> notes = [];
  List<Note> lists = [];
  List<bool> isChecked = []; // 노트 편집 체크여부 확인
  Set<Note> deleteSet = {}; // 노트 여러개 삭제를 위한 set
  List<String> userMusics = [];
  bool emptyCheck = false;
  GlobalKey globalKey = GlobalKey(); // 배너 클릭시 추천탭으로 이동시키기 위한 globalKey
  late TextEditingController controller;
  late int noteCount;
  late bool _isSubmitted; // 리뷰 또는 채널톡 의견 제출 여부
  late final _currentTime; // 현재 시간
  DateTime? _preRequestTime; // 이전 요청 시간
  late bool isSubscribed; // 구독 여부
  List<bool> feedDetailCheckList = []; // 피드 노래추가 체크여부 확인
  Set<Note> addSet = {}; // 피드 노래 여러개 추가를 위한 set

  bool isAppOpenBanner = true; //앱 오픈 배너 로드 여부

  final InAppReview _inAppReview = InAppReview.instance;
  final storage = new FlutterSecureStorage();

  bool noteAddInterstitialSetting = false;

  bool isLogined = false; //사용자 로그인 여부
  String userNickname = "사용자 ID";
  String backUpDate = "없음";
  String userImage = "";
  int userId = 0;

  // AdMob
  int noteAddCount = 0; // 광고를 위해, 한 세션 당 노트 추가 횟수를 기록
  int detailDisposeCount = 0; //광고를 위해, 노트 상세정보에서 나간 횟수를 기록

  AnchoredAdaptiveBannerAdSize? size;

  initAdSize(BuildContext context) async {
    size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());
  }

  Map<String, String> Note_Add_Interstitial_UNIT_ID = kReleaseMode
      ? {
          'android': 'ca-app-pub-7139143792782560/4800293433',
          'ios': 'ca-app-pub-7139143792782560/4696066245',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/1033173712',
          'ios': 'ca-app-pub-3940256099942544/4411468910',
        };

  Map<String, String> AI_Recommand_Interstitial_UNIT_ID = kReleaseMode
      ? {
          'android': 'ca-app-pub-7139143792782560/8456175834',
          'ios': 'ca-app-pub-7139143792782560/1894351507',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/1033173712',
          'ios': 'ca-app-pub-3940256099942544/4411468910',
        };

  int maxFailedLoadAttempts = 3;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  appOpenAdUnloaded(BuildContext context) {
    isAppOpenBanner = false;

    /// MainScreen 전환 (replace)
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
    notifyListeners();
  }

  createInterstitialAd(String command) {
    InterstitialAd.load(
        adUnitId: (command == "noteAdd")
            ? Note_Add_Interstitial_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!
            : AI_Recommand_Interstitial_UNIT_ID[
                Platform.isIOS ? 'ios' : 'android']!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            Analytics_config().adNoteAddInterstitialSuccess();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd(command);
            }
            Analytics_config().adNoteAddInterstitialFail();
          },
        ));
  }

  void _showInterstitialAd(String command) async {
    if (_interstitialAd == null || rewardFlag) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        // print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd(command);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        // print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd(command);
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  initSubscirbeState() async {
    String? value = await storage.read(key: 'isSubscribed');
    bool flag;
    if (value != null) {
      if (value == 'yes') {
        flag = true;
      } else {
        flag = false;
      }
    } else {
      flag = true;
    }
    isSubscribed = flag;
  }

  changeRewardState() {
    rewardFlag = true;
  }

  //Splash 화면에서 로그인 상태 확인
  initLoginState() async {
    String? jwt = await storage.read(key: 'jwt');
    if (jwt != null) isLogined = true;
    notifyListeners();
  }

  initNotes() async {
    initSubscirbeState();
    initLoginState();
    initAccountInfo();

    await isUserRewarded();
    // Read all values
    String? allValues = await storage.read(key: 'notes');
    if (allValues != null) {
      var noteJson = jsonDecode(allValues) as List;
      List<Note> savedNote =
          noteJson.map((noteIter) => Note.fromJson(noteIter)).toList();
      List<String> savedUserMusics = noteJson
          .map((noteIter) => Note.fromJson(noteIter).tj_songNumber)
          .toList();

      notes = savedNote;
      userMusics = savedUserMusics;
    }
    noteCount = notes.length;
    int memoCnt = 0; //전체 노트 중 메모를 한 노트의 수
    for (Note note in notes) {
      if (note.memo != null && note.memo != "") {
        memoCnt++;
      }
    }

    Identify identify = Identify()
      ..set('노트 개수', notes.length)
      ..set('메모 노트 개수', memoCnt)
      ..set('유저 노트 리스트', userMusics);

    Analytics_config().userProps(identify);

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'noteCnt', value: notes.length.toString());

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'memoNoteCnt', value: memoCnt.toString());

    //!event : 애창곡_노트_뷰__페이지뷰
    Analytics_config().event('애창곡_노트_뷰__페이지뷰', {});

    _currentTime = DateTime.now();
    String? preRequestTime = await storage.read(key: 'preRequestTime');
    preRequestTime == null
        ? _preRequestTime = null
        : _preRequestTime = DateFormat('yyyy-MM-dd').parse(preRequestTime);

    String? isSubmitted = await storage.read(key: 'isSubmitted');
    isSubmitted == null ? _isSubmitted = false : _isSubmitted = true;

    notifyListeners();
  }

  aiInterstitialAd() {
    if (_interstitialAd != null && !rewardFlag) {
      _showInterstitialAd("AI");
    }
  }

  Future<void> addNoteBySongNumber(BuildContext context, String songNumber,
      List<FitchMusic> musicList) async {
    noteCount += 1;
    for (FitchMusic fitchMusic in musicList) {
      if (fitchMusic.tj_songNumber == songNumber) {
        Note note = Note(
          fitchMusic.tj_title,
          fitchMusic.tj_singer,
          fitchMusic.tj_songNumber,
          fitchMusic.ky_title,
          fitchMusic.ky_singer,
          fitchMusic.ky_songNumber,
          fitchMusic.gender,
          fitchMusic.pitchNum,
          "",
          0,
        );

        bool flag = false;
        for (Note iter_note in notes) {
          if (iter_note.tj_songNumber == fitchMusic.tj_songNumber) {
            flag = true;
            break;
          }
        }
        if (!flag) {
          notes.add(note);
          userMusics.add(note.tj_songNumber);

          await storage.write(key: 'notes', value: jsonEncode(notes));

          final Identify identify = Identify()
            ..set('노트 개수', notes.length)
            ..set('유저 노트 리스트', userMusics);

          Analytics_config().userProps(identify);

          await FirebaseAnalytics.instance
              .setUserProperty(name: 'noteCnt', value: notes.length.toString());

          //!event: 인기 차트 - 노트 추가 이벤트
          // Analytics_config().event('인기_차트__노트_추가_이벤트', {
          //   '곡_이름': note.tj_title,
          //   '가수_이름': note.tj_singer,
          //   'TJ_번호': note.tj_songNumber,
          //   '금영_번호': note.ky_songNumber,
          //   '매칭_여부': (note.tj_songNumber == note.ky_songNumber),
          //   '메모_여부': note.memo
          // });
          Analytics_config().musicAddEvent(note.tj_title);
        } else {
          emptyCheck = true;
        }
        break;
      }
    }
    bool isOverlapping = false; // admob과 리뷰요청 중복 확인

    //Google Admob event
    noteAddCount++;
    notifyListeners();
    noteAddInterstitialSetting = Firebase_Remote_Config()
        .remoteConfig
        .getBool('noteAddInterstitialSetting');
    if (noteAddCount % 5 == 0 &&
        noteAddInterstitialSetting &&
        _interstitialAd != null &&
        !rewardFlag) {
      _showInterstitialAd("noteAdd");
      isOverlapping = true;
    }
    if (isOverlapping == false &&
        (_preRequestTime == null ||
            _currentTime.difference(_preRequestTime).inDays > 20) &&
        !_isSubmitted &&
        noteCount >= 5 &&
        Provider.of<MusicSearchItemLists>(context, listen: false)
                .sessionCount >=
            5) {
      showReviewDialog(context);
    }
    notifyListeners();
  }

  // 곡 번호로 리스트에 추가하는 함수
  Future<void> addSongBySongNumber(BuildContext context, String songNumber,
      List<FitchMusic> musicList) async {
    for (FitchMusic fitchMusic in musicList) {
      if (fitchMusic.tj_songNumber == songNumber) {
        Note note = Note(
          fitchMusic.tj_title,
          fitchMusic.tj_singer,
          fitchMusic.tj_songNumber,
          fitchMusic.ky_title,
          fitchMusic.ky_singer,
          fitchMusic.ky_songNumber,
          fitchMusic.gender,
          fitchMusic.pitchNum,
          "",
          0,
        );

        bool flag = false;
        for (Note iter_list in lists) {
          if (iter_list.tj_songNumber == fitchMusic.tj_songNumber) {
            flag = true;
            break;
          }
        }
        if (!flag) {
          lists.add(note);
        } else {
          emptyCheck = true;
        }
        break;
      }
    }
    notifyListeners();
  }

  Future<void> editNote(Note note, String memo) async {
    note.memo = memo;
    int memoCnt = 0;
    for (Note no in notes) {
      if (note.tj_songNumber == no.tj_songNumber) {
        no.memo = memo;
      }
      if (no.memo != "") {
        memoCnt++;
      }
    }
    await storage.write(key: 'notes', value: jsonEncode(notes));

    Identify identify = Identify()..set('메모 노트 개수', memoCnt);

    Analytics_config().userProps(identify);

    notifyListeners();
  }

  // 리스트 노래 추가 다이어로그 팝업 함수
  void showAddListSongDialog(
      BuildContext context, String songNumber, String title) {
    double defaultSize = SizeConfig.defaultSize;

    Widget okButton = ElevatedButton(
      onPressed: () {
        addSongBySongNumber(
            context,
            songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
        Fluttertoast.cancel();
        if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
          tt.Toast.show("이미 리스트에 추가된 노래입니다.",
              backgroundColor: kPrimaryGreyColor);
          Provider.of<NoteData>(context, listen: false).initEmptyCheck();
        } else {
          Analytics_config().addViewSongAddEvent(title);
          Analytics_config().musicAddEvent(title);
          tt.Toast.show("리스트에 노래가 추가 되었습니다.",
              backgroundColor: kPrimaryGreyColor);
        }
      },
      child: Text("추가",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        "취소",
        style: TextStyle(fontWeight: FontWeight.w600, color: kMainColor),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        "'${title}' 노래를 플레이리스트에 추가하시겠습니까?",
        style:
            TextStyle(fontWeight: FontWeight.w400, color: kPrimaryWhiteColor),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
      backgroundColor: kDialogColor,
      shape: const RoundedRectangleBorder(
          side: BorderSide(width: 0.0),
          borderRadius: BorderRadius.all(Radius.circular(8))),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  // 노트 삭제 함수
  Future<void> deleteNote(Note note) async {
    noteCount -= 1;
    notes.remove(note);
    userMusics.remove(note.tj_songNumber);

    await storage.write(key: 'notes', value: jsonEncode(notes));

    Identify identify = Identify()
      ..set('노트 개수', notes.length)
      ..set('유저 노트 리스트', userMusics)
      ..add('메모 노트 개수', (note.memo == "true") ? -1 : 0);

    Analytics_config().userProps(identify);
    notifyListeners();
  }

  void initEmptyCheck() {
    emptyCheck = false;
    notifyListeners();
  }

  // 플레이리스트 삭제 함수
  Future<void> deleteList(Note note) async {
    lists.remove(note);
    notifyListeners();
  }

  void editKySongNumber(Note note, String kySongNumber) {
    int idx = notes.indexOf(note);
    notes[idx].ky_songNumber = kySongNumber;
    notifyListeners();
  }

  Future<void> reorderEvent() async {
    await storage.write(key: 'notes', value: jsonEncode(notes));
  }

  // 노트추가 다이어로그 팝업 함수
  void showAddNoteDialog(
      BuildContext context, String songNumber, String title) {
    double defaultSize = SizeConfig.defaultSize;

    Widget okButton = ElevatedButton(
      onPressed: () {
        addNoteBySongNumber(
            context,
            songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
        if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
          tt.Toast.show("애창곡 노트에 이미 등록된 곡입니다.",
              backgroundColor: kPrimaryGreyColor);
          Provider.of<NoteData>(context, listen: false).initEmptyCheck();
        } else {
          Analytics_config().addViewSongAddEvent(title);
          Analytics_config().musicAddEvent(title);
          tt.Toast.show("애창곡 노트에 노래가 추가되었습니다.",
              backgroundColor: kPrimaryGreyColor);
        }
      },
      child: Text("추가",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        "취소",
        style: TextStyle(fontWeight: FontWeight.w600, color: kMainColor),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        "'${title}' 노래를 애창곡 노트에 추가하시겠습니까?",
        style:
            TextStyle(fontWeight: FontWeight.w400, color: kPrimaryWhiteColor),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
      backgroundColor: kDialogColor,
      shape: const RoundedRectangleBorder(
          side: BorderSide(width: 0.0),
          borderRadius: BorderRadius.all(Radius.circular(8))),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  // 간단한 정보를 보여주고 애창곡노트 추가버튼이 있는 다이어로그 팝업 함수
  void showAddNoteDialogWithInfo(BuildContext context,
      {required isTj,
      required String songNumber,
      required String title,
      required String singer}) {
    //!event: 일반_검색_뷰__노래_유튜브
    Analytics_config().clickYoutubeButtonOnSearchView();
    double defaultSize = SizeConfig.defaultSize;

    Widget okButton = ElevatedButton(
      onPressed: () {
        addNoteBySongNumber(
            context,
            songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
        Fluttertoast.cancel();
        if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
          Fluttertoast.showToast(
              msg: "이미 등록된 곡입니다 😢",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xFFFF7878),
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
          Provider.of<NoteData>(context, listen: false).initEmptyCheck();
        } else {
          //!event: 일반_검색_뷰__노트추가
          Analytics_config().searchViewNoteAddEvent(title);
          Analytics_config().musicAddEvent(title);
          Fluttertoast.showToast(
              msg: "노래가 추가 되었습니다 🎉",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
        }
      },
      child: IntrinsicWidth(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("애창곡 노트에 추가하기",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(30),
          ))),
    );

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text("${songNumber}",
                  style: TextStyle(
                      color: kMainColor, fontSize: defaultSize * 1.7)),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(
                      'https://www.youtube.com/results?search_query= ${title} ${singer}');
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
                child: Column(children: [
                  SvgPicture.asset("assets/icons/youtube.svg"),
                  Text("유튜브 검색",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 0.9)),
                ]),
              ),
            ],
          ),
          SizedBox(height: defaultSize * 2),
          Text("${title}",
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: defaultSize * 1.4)),
          SizedBox(height: defaultSize),
          Text("${singer}",
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontWeight: FontWeight.w300,
                  fontSize: defaultSize * 1.2)),
        ]),
      ),
      actions: [
        if (isTj == true) Center(child: okButton),
      ],
      backgroundColor: kDialogColor,
      shape: const RoundedRectangleBorder(
          side: BorderSide(width: 0.0),
          borderRadius: BorderRadius.all(Radius.circular(8))),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  //노트 삭제여부 확인 팝업 함수
  void showDeleteDialog(BuildContext context, Note note) {
    Widget deleteButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Analytics_config().noteDeleteEvent(note.tj_title);
        deleteNote(note);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Text("삭제",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
    );

    Widget cancelButton = ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 0.0),
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("취소",
            style: TextStyle(fontWeight: FontWeight.w600, color: kMainColor)));

    AlertDialog alert = AlertDialog(
      content: Text(
        "노트를 삭제 하시겠습니까?",
        style:
            TextStyle(fontWeight: FontWeight.w400, color: kPrimaryWhiteColor),
      ),
      actions: [
        cancelButton,
        deleteButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  // 리뷰 요청 다이어로그
  showReviewDialog(context) async {
    // !event: 리뷰요청_뷰__페이지뷰
    Analytics_config().reviewRequestPageVeiwEvent();
    double defaultSize = SizeConfig.defaultSize;
    _preRequestTime = _currentTime;
    storage.write(
        key: 'preRequestTime',
        value: DateFormat('yyyy-MM-dd').format(_preRequestTime!));

    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kDialogColor,
            shape: const RoundedRectangleBorder(
                side: BorderSide(width: 0.0),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/splash.png",
                  width: defaultSize * 10,
                  height: defaultSize * 10,
                ),
                SizedBox(height: defaultSize * 3),
                Text("애창곡노트가 마음에 드세요?",
                    style: TextStyle(
                        fontSize: defaultSize * 1.8,
                        color: kPrimaryLightWhiteColor,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: defaultSize * 3),
                SizedBox(
                  width: defaultSize * 20,
                  child: ElevatedButton(
                      onPressed: () {
                        // !event: 리뷰요청_뷰__네_좋아요
                        Analytics_config().reviewRequestYesButtonEvent();
                        Navigator.of(context).pop();
                        showOpenStoreDialog(context);
                      },
                      child: Text("네! 좋아요!",
                          style: TextStyle(
                              fontSize: defaultSize * 1.2,
                              color: kPrimaryLightWhiteColor,
                              fontWeight: FontWeight.w600)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(kMainColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            side: const BorderSide(width: 0.0),
                            borderRadius: BorderRadius.circular(30),
                          )))),
                ),
                SizedBox(width: defaultSize * 1.5),
                SizedBox(
                  width: defaultSize * 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // !event: 리뷰요청_뷰__그냥_그래요
                      Analytics_config().reviewRequestNoButtonEvent();
                      Navigator.of(context).pop();
                      showChannelTalkDialog(context);
                    },
                    child: Text("그냥 그래요",
                        style: TextStyle(
                            fontSize: defaultSize * 1.2,
                            color: kPrimaryBlackColor,
                            fontWeight: FontWeight.w600)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(kPrimaryLightGreyColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ))),
                  ),
                ),
                SizedBox(height: defaultSize * 2),
                Text("만족하실수 있는 서비스가 될 수 있도록",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.1)),
                Text("끊임없이 노력 하겠습니다",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.1)),
              ],
            ),
          );
        });
  }

  // 스토어 오픈 다이어로그
  showOpenStoreDialog(context) async {
    // !event: 스토어연결_뷰__페이지뷰
    Analytics_config().storeRequestPageViewEvent();
    double defaultSize = SizeConfig.defaultSize;

    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kDialogColor,
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.0),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("감사합니다! 😆",
                    style: TextStyle(
                        fontSize: defaultSize * 1.5,
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: defaultSize * 2),
                Platform.isAndroid
                    ? Text("그렇다면 구글플레이 스토어에",
                        style: TextStyle(
                            fontSize: defaultSize * 1.5,
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w500))
                    : Text("그렇다면 앱스토어에",
                        style: TextStyle(
                            fontSize: defaultSize * 1.5,
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w500)),
                Text("칭찬을 남겨주세요!",
                    style: TextStyle(
                        fontSize: defaultSize * 1.5,
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: defaultSize * 3),
                SizedBox(
                  width: defaultSize * 20,
                  child: ElevatedButton(
                      onPressed: () {
                        // !event: 스토어연결_뷰__리뷰_남기기
                        Analytics_config().storeRequestYesButtonEvent();
                        storage.write(key: 'isSubmitted', value: 'yes');
                        Navigator.of(context).pop();
                        _inAppReview.openStoreListing(appStoreId: '1627953850');
                      },
                      child: Text("리뷰 남기기",
                          style: TextStyle(
                              fontSize: defaultSize * 1.2,
                              color: kPrimaryLightWhiteColor,
                              fontWeight: FontWeight.w600)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(kMainColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            side: const BorderSide(width: 0.0),
                            borderRadius: BorderRadius.circular(30),
                          )))),
                ),
                SizedBox(width: defaultSize * 1.5),
                SizedBox(
                  width: defaultSize * 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // !event: 스토어연결_뷰__다음에요
                      Analytics_config().storeRequestNoButtonEvent();
                      Navigator.of(context).pop();
                    },
                    child: Text("다음에요",
                        style: TextStyle(
                            fontSize: defaultSize * 1.2,
                            color: kPrimaryBlackColor,
                            fontWeight: FontWeight.w600)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(kPrimaryLightGreyColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          side: const BorderSide(width: 0.0),
                          borderRadius: BorderRadius.circular(30),
                        ))),
                  ),
                ),
                SizedBox(height: defaultSize * 2),
                Text("리뷰는 저희에게 큰 힘이 됩니다!",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.1)),
              ],
            ),
          );
        });
  }

  // 채널톡 오픈 다이어로그
  showChannelTalkDialog(context) async {
    // !event: 채널톡연결_뷰__페이지뷰
    Analytics_config().channelTalkRequestPageVeiwnEvent();
    double defaultSize = SizeConfig.defaultSize;

    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kDialogColor,
            shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.0),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("죄송합니다.",
                    style: TextStyle(
                        fontSize: defaultSize * 1.5,
                        color: kPrimaryLightWhiteColor,
                        fontWeight: FontWeight.w500)),
                Text("불편한 점이나 건의사항을",
                    style: TextStyle(
                        fontSize: defaultSize * 1.5,
                        color: kPrimaryLightWhiteColor,
                        fontWeight: FontWeight.w500)),
                Text("저희에게 알려주세요!",
                    style: TextStyle(
                        fontSize: defaultSize * 1.5,
                        color: kPrimaryLightWhiteColor,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: defaultSize * 3),
                SizedBox(
                  width: defaultSize * 20,
                  child: ElevatedButton(
                      onPressed: () {
                        // !event: 채널톡연결_뷰__1:1_문의하기
                        Analytics_config().channelTalkRequestYesButtonEvent();
                        storage.write(key: 'isSubmitted', value: 'yes');
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChannelTalkScreen()),
                        );
                      },
                      child: Text("1:1 문의하기",
                          style: TextStyle(
                              fontSize: defaultSize * 1.2,
                              color: kPrimaryLightWhiteColor,
                              fontWeight: FontWeight.w600)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(kMainColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            side: const BorderSide(width: 0.0),
                            borderRadius: BorderRadius.circular(30),
                          )))),
                ),
                SizedBox(width: defaultSize * 1.5),
                SizedBox(
                  width: defaultSize * 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // !event: 채널톡연결_뷰__다음에요
                      Analytics_config().channelTalkRequestNoButtonEvent();
                      Navigator.of(context).pop();
                    },
                    child: Text("다음에요",
                        style: TextStyle(
                            fontSize: defaultSize * 1.2,
                            color: kPrimaryBlackColor,
                            fontWeight: FontWeight.w600)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(kPrimaryLightGreyColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          side: const BorderSide(width: 0.0),
                          borderRadius: BorderRadius.circular(30),
                        ))),
                  ),
                ),
                SizedBox(height: defaultSize * 2),
                Text("만족하실수 있는 서비스가 될 수 있도록",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.1)),
                Text("끊임없이 노력하겠습니다",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.1)),
              ],
            ),
          );
        });
  }

  //노트 백업및 가져오기 다이어로그 팝업 함수
  void showBackupDialog(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenWidth = SizeConfig.screenWidth;
    Widget backupButton = Container(
      width: screenWidth * 0.3,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kMainColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 0.0),
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          Navigator.of(context).pop();
          showBackupAlertDialog(context);
        },
        child: Text("백업하기", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );

    Widget getButton = Container(
      width: screenWidth * 0.3,
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                side: const BorderSide(width: 0.0),
                borderRadius: BorderRadius.circular(8),
              ))),
          onPressed: () async {
            await loadNotes(context);
            Navigator.of(context).pop();
          },
          child: Text("가져오기",
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: kMainColor))),
    );

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text("백업 및 가져오기",
                  style: TextStyle(
                      color: kPrimaryWhiteColor, fontSize: defaultSize * 1.6))),
          SizedBox(height: defaultSize * 2),
          Text(
            "현재 애창곡 노트에 저장한 애창곡들을 서버에 백업하고 핸드폰이 바뀌거나 앱을 삭제 하더라도 편리하게 다시 가져올 수 있어요.",
            style: TextStyle(
                color: kPrimaryWhiteColor, fontSize: defaultSize * 1.4),
          )
        ]),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        getButton,
        backupButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  //노트 백업 전 경고 다이어로그
  void showBackupAlertDialog(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenWidth = SizeConfig.screenWidth;
    Widget backupButton = Container(
      width: screenWidth * 0.3,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kMainColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 0.0),
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          saveNotes();
          Navigator.of(context).pop();
        },
        child: Text("백업 계속하기", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );

    Widget cancelButton = Container(
      width: screenWidth * 0.3,
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                side: const BorderSide(width: 0.0),
                borderRadius: BorderRadius.circular(8),
              ))),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("취소",
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: kMainColor))),
    );

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Text("데이터 백업시 주의사항",
                  style: TextStyle(
                      color: kMainColor, fontSize: defaultSize * 1.6))),
          SizedBox(height: defaultSize * 2),
          Text("내 애창곡 노트에 저장한 노래 개수 : ${notes.length}",
              style: TextStyle(
                  color: kPrimaryWhiteColor, fontSize: defaultSize * 1.4)),
          SizedBox(height: defaultSize),
          Text(
            "현재 애창곡 노트에 저장된 곡을 기준으로 백업이 되어 기존에 서버에 저장된 곡들은 사라지므로 백업한 노래가 있다면 가져오기 이후 백업을 진행해 주세요!!",
            style: TextStyle(
                color: kPrimaryWhiteColor, fontSize: defaultSize * 1.4),
          )
        ]),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        cancelButton,
        backupButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  // 저장한 노트들 백업하기
  Future<void> saveNotes() async {
    await EasyLoading.show();
    //!event: 내정보_뷰__백업하기
    Analytics_config().backUpNoteEvent();
    String? serverURL = dotenv.env['USER_SERVER_URL'];
    String url = '$serverURL/user/backup/save';
    String? jwtToken = await storage.read(key: 'jwt');
    if (jwtToken != null) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': jwtToken,
          },
          body: jsonEncode({
            "notes": jsonEncode(userMusics),
          }),
        );
        //백업 날짜 기록
        backUpDate = DateFormat("yyyy-MM-dd hh:mm:ss a").format(DateTime.now());
        await storage.write(key: 'backupdate', value: backUpDate);
        EasyLoading.showToast("백업이 완료되었습니다.");
        notifyListeners();
      } on SocketException {
        // 인터넷 연결 예외처리
        EasyLoading.showToast("백업이 실패했습니다 인터넷 연결을 확인해주세요.");
      }
    }
  }

  // 저장한 노트를 가져오는 함수
  Future<void> loadNotes(BuildContext context) async {
    //!event: 내정보_뷰__가져오기
    Analytics_config().loadNoteEvent();
    String? serverURL = dotenv.env['USER_SERVER_URL'];
    String url = '$serverURL/user/backup/load';
    String? jwtToken = await storage.read(key: 'jwt');
    try {
      if (jwtToken != null) {
        final response = await http.get(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': jwtToken,
          },
        );
        List<String> songNumberList = [];
        String tmp = "";
        for (int i = 0; i < response.body.length; i++) {
          if (response.body[i].compareTo("0") >= 0 &&
              (response.body[i].compareTo('9') == 0 ||
                  response.body[i].compareTo('9') == -1)) {
            tmp += response.body[i];
          } else {
            if (tmp.isNotEmpty) {
              songNumberList.add(tmp);
              tmp = "";
            }
          }
        }
        if (songNumberList.isEmpty) {
          throw FormatException();
        }
        Set<Note> entireNote =
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .entireNote;
        for (int i = 0; i < songNumberList.length; i++) {
          Note note = entireNote.firstWhere(
              (element) => element.tj_songNumber == songNumberList[i]);
          bool flag = false;
          for (int j = 0; j < notes.length; j++) {
            if (notes[j].tj_songNumber == note.tj_songNumber) {
              flag = true;
            }
          }
          if (!flag) {
            notes.add(note);
            userMusics.add(note.tj_songNumber);
          }
        }
        await storage.write(key: 'notes', value: jsonEncode(notes));
        EasyLoading.showToast("${songNumberList.length}개의 곡을 가져왔습니다");
      }
    } on FormatException {
      // 백업된 곡이 하나도 없을 때 예외처리
      EasyLoading.showToast("백업된 곡이 없습니다.");
    }
    notifyListeners();
  }

  //노트 삭제여부 확인 팝업 함수 (command: "delete"(계정삭제), "logout"(로그아웃))
  void showAccountDialog(BuildContext context, String command) {
    double defaultSize = SizeConfig.defaultSize;
    Widget okButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        if (command == "delete")
          deleteAccount();
        else
          logoutAccount();

        Navigator.of(context).pop();
      },
      child: Text((command == "delete") ? "회원탈퇴" : "로그아웃",
          style: TextStyle(fontWeight: FontWeight.w600)),
    );

    Widget cancelButton = ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 0.0),
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("취소",
            style: TextStyle(fontWeight: FontWeight.w600, color: kMainColor)));

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            (command == "delete") ? "정말로 회원탈퇴를 진행하시겠어요?" : "로그아웃 하시겠습니까?",
            style: TextStyle(color: kPrimaryWhiteColor),
          )
        ]),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  // 회원탈퇴
  Future<void> deleteAccount() async {
    //!event: 내정보_뷰__탈퇴하기
    Analytics_config().userunregisterEvent();
    //로그아웃 처리
    await logoutAccount();

    String? serverURL = dotenv.env['USER_SERVER_URL'];
    String url = '$serverURL/user/delete/account';
    String? jwtToken = await storage.read(key: 'jwt');
    if (jwtToken != null) {
      try {
        final response = await http.put(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': jwtToken,
          },
        );
      } catch (err) {
        throw HttpException('$err');
      }
    }
  }

  // 로그아웃
  Future<void> logoutAccount() async {
    //!event: 내정보_뷰__로그아웃
    Analytics_config().userlogoutEvent();
    //jwt 토큰 삭제
    await storage.delete(key: 'jwt');
    isLogined = false;
    userImage = "";
    notifyListeners();
  }

  // JWT 토큰 저장하기
  writeJWT(String? jwtToken) async {
    await storage.write(key: 'jwt', value: jwtToken);
    isLogined = true;
    notifyListeners();
  }

  initAccountInfo() async {
    String? jwtToken = await storage.read(key: 'jwt');
    if (jwtToken != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(jwtToken);
      if (payload["username"] != null) {
        userNickname = payload["username"];
      } else {
        userNickname = payload["nickname"];
      }
      if (payload["userimage"] != null) {
        userImage = payload["userimage"];
      }
      if (payload["userId"] != null) {
        userId = payload["userId"];
      }
    }

    String? storage_backupdate = await storage.read(key: 'backupdate');

    if (storage_backupdate != null) {
      backUpDate = storage_backupdate;
    }

    notifyListeners();
  }

  // 피드 노트에 추가 전체 선택
  checkAllFeedSongs(List<Note> postList) {
    feedDetailCheckList = List<bool>.filled(feedDetailCheckList.length, true);
    for (int i = 0; i < postList.length; i++) {
      addSet.add(postList[i]);
    }
    notifyListeners();
  }

  // 피드 노트에 추가 전체 해제
  uncheckAllFeedSongs() {
    feedDetailCheckList = List<bool>.filled(feedDetailCheckList.length, false);
    addSet.clear();
    notifyListeners();
  }

  // 노트 편집시 전체 선택
  checkAllSongs() {
    isChecked = List<bool>.filled(isChecked.length, true);
    for (int i = 0; i < isChecked.length; i++) {
      deleteSet.add(notes[i]);
    }
    notifyListeners();
  }

  // 노트 편집시 전체 해제
  unCheckAllSongs() {
    isChecked = List<bool>.filled(isChecked.length, false);
    deleteSet.clear();
    notifyListeners();
  }

  // 노래 한곡 체크
  checkSong(Note note) {
    deleteSet.add(note);
    notifyListeners();
  }

  // 노래 한곡 체크해제
  unCheckSong(Note note) {
    deleteSet.remove(note);
    notifyListeners();
  }

  // 편집시 사용되는 리스트 초기화
  initEditNote() {
    deleteSet = {}; // deleteSet 초기화
    isChecked = List<bool>.filled(notes.length, false);
    notifyListeners();
  }

  // 피드 노래추가에 사용되는 리스트 초기화
  initAddFeedSong(List<String> postList) {
    addSet = {};
    feedDetailCheckList = List<bool>.filled(postList.length, false);
    notifyListeners();
  }

  // 노트 여러개 삭제 함수
  Future<void> deleteMultipleNote() async {
    noteCount -= deleteSet.length;
    List<Note> temp_notes = [];
    List<String> temp_userMusics = [];
    for (int i = 0; i < notes.length; i++) {
      if (deleteSet.contains(notes[i])) continue;
      temp_notes.add(notes[i]);
      temp_userMusics.add(notes[i].tj_songNumber);
    }
    deleteSet = {};
    notes = temp_notes;
    userMusics = temp_userMusics;
    await storage.write(key: 'notes', value: jsonEncode(notes));

    Identify identify = Identify()
      ..set('노트 개수', notes.length)
      ..set('유저 노트 리스트', userMusics);

    Analytics_config().userProps(identify);
    notifyListeners();
  }

  // 피드에 올라온 노래 내 애창곡 리스트에 여러개 추가 함수
  Future<void> addMultipleFeedSongs() async {
    double defaultSize = SizeConfig.defaultSize;
    int overlap = 0;
    for (Note note in addSet) {
      bool flag = false;
      for (Note e in notes) {
        if (e.tj_songNumber == note.tj_songNumber) {
          overlap++;
          flag = true;
          break;
        }
      }
      if (!flag) {
        notes.add(note);
        userMusics.add(note.tj_songNumber);
        noteCount += 1;
      }
    }
    if (overlap > 0) {
      EasyLoading.instance..fontSize = defaultSize * 1.25;
      EasyLoading.showToast("중복을 제외한 ${addSet.length - overlap}개의 곡이 추가되었습니다.");
    } else {
      EasyLoading.showToast("${addSet.length}개의 곡이 추가되었습니다.");
    }
    await storage.write(key: 'notes', value: jsonEncode(notes));
    notifyListeners();
  }

  //노트여러개 삭제여부 확인 팝업 함수
  void showDeleteMultipleNoteDialog(context) {
    Widget deleteButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            side: const BorderSide(width: 0.0),
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () async {
        await deleteMultipleNote();
        if (isChecked.isNotEmpty) {
          isChecked = List<bool>.filled(isChecked.length, false);
        }
        Navigator.pop(context);
      },
      child: Text("삭제",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
    );

    Widget cancelButton = ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 0.0),
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("취소",
            style: TextStyle(fontWeight: FontWeight.w600, color: kMainColor)));

    AlertDialog alert = AlertDialog(
      content: Text(
        "정말 총 ${deleteSet.length}개의 노래를 삭제하시겠습니까?",
        style:
            TextStyle(fontWeight: FontWeight.w400, color: kPrimaryWhiteColor),
      ),
      actions: [
        cancelButton,
        deleteButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  bool rewardFlag = false;

  //해당 사용자가 현재 리워드 보상(광고 제거)이 유지되어있는지 검사하는 함수
  isUserRewarded() async {
    String? rewardHoldTimeString = await storage.read(key: 'rewardTime');
    if (rewardHoldTimeString == null) return false;
    int rewardHoldTime = int.parse(rewardHoldTimeString);
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    //현재 시각이 리워드 시각 이후라면
    if (nowTime > rewardHoldTime) {
      rewardFlag = false; //리워드 미적용
    } else {
      rewardFlag = true; //리워드 적용
    }
  }

  Future<String> userRewardedTime() async {
    String? rewardHoldTimeString = await storage.read(key: 'rewardTime');
    if (rewardHoldTimeString == null) return "0초";
    int rewardHoldTime = int.parse(rewardHoldTimeString);
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    int distTime = rewardHoldTime - nowTime;
    if (distTime < 0) return "0 초";
    int minute = (distTime) ~/ 60000;
    int second = (distTime - (minute * 60000)) ~/ 1000;

    if (minute >= 1) {
      return "${minute} 분 ${second} 초";
    } else {
      return "${second} 초";
    }
  }
}
