import 'dart:convert';
import 'dart:io';

import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'note.dart';

class NoteData extends ChangeNotifier {
  List<Note> notes = [];
  bool emptyCheck = false;
  GlobalKey globalKey = GlobalKey(); // 배너 클릭시 추천탭으로 이동시키기 위한 globalKe
  TextEditingController controller = TextEditingController();

  final storage = new FlutterSecureStorage();

  bool noteAddInterstitialSetting = false;

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  // AdMob
  int noteAddCount = 0; // 광고를 위해, 한 세션 당 노트 추가 횟수를 기록
  Map<String, String> Note_Add_Interstitial_UNIT_ID = kReleaseMode
      ? {
          'android': 'ca-app-pub-1461012385298546/1703495459',
          'ios': 'ca-app-pub-1461012385298546/3994331462',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/1033173712',
          'ios': 'ca-app-pub-3940256099942544/4411468910',
        };

  int maxFailedLoadAttempts = 3;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  createInterstitialAd() {
    InterstitialAd.load(
        adUnitId:
            Note_Add_Interstitial_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  initNotes() async {
    // Read all values
    String? allValues = await storage.read(key: 'notes');
    if (allValues != null) {
      var noteJson = jsonDecode(allValues) as List;
      List<Note> savedNote =
          noteJson.map((noteIter) => Note.fromJson(noteIter)).toList();

      notes = savedNote;
    }

    int memoCnt = 0; //전체 노트 중 메모를 한 노트의 수
    for (Note note in notes) {
      if (note.memo != null && note.memo != "") {
        memoCnt++;
      }
    }

    Identify identify = Identify()
      ..set('노트 개수', notes.length)
      ..set('메모 노트 개수', memoCnt);

    Analytics_config().userProps(identify);

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'noteCnt', value: notes.length.toString());

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'memoNoteCnt', value: memoCnt.toString());

    //!event : 애창곡_노트_뷰__페이지뷰
    Analytics_config().event('애창곡_노트_뷰__페이지뷰', {});

    notifyListeners();
  }

  Future<void> addNoteBySongNumber(
      String songNumber, List<FitchMusic> musicList) async {
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
          await storage.write(key: 'notes', value: jsonEncode(notes));

          final Identify identify = Identify()..set('노트 개수', notes.length);

          Analytics_config().userProps(identify);

          await FirebaseAnalytics.instance
              .setUserProperty(name: 'noteCnt', value: notes.length.toString());

          //!event: 인기 차트 - 노트 추가 이벤트
          Analytics_config().event('인기_차트__노트_추가_이벤트', {
            '곡_이름': note.tj_title,
            '가수_이름': note.tj_singer,
            'TJ_번호': note.tj_songNumber,
            '금영_번호': note.ky_songNumber,
            '매칭_여부': (note.tj_songNumber == note.ky_songNumber),
            '메모_여부': note.memo
          });
          Analytics_config().musicAddEvent(note.tj_title);
        } else {
          emptyCheck = true;
        }

        notifyListeners();

        break;
      }
    }
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

  //local storage 에도 삭제 작업 필요
  Future<void> deleteNote(Note note) async {
    notes.remove(note);
    await storage.write(key: 'notes', value: jsonEncode(notes));

    Identify identify = Identify()
      ..set('노트 개수', notes.length)
      ..add('메모 노트 개수', (note.memo == "true") ? -1 : 0);

    Analytics_config().userProps(identify);
    notifyListeners();
  }

  void initEmptyCheck() {
    emptyCheck = false;
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
        Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
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
          Analytics_config().addViewSongAddEvent(title);
          Analytics_config().musicAddEvent(title);
          Fluttertoast.showToast(
              msg: "노래가 추가 되었습니다 🎉",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);

          //Google Admob event
          noteAddCount++;
          notifyListeners();
          noteAddInterstitialSetting = Firebase_Remote_Config()
              .remoteConfig
              .getBool('noteAddInterstitialSetting');
          if (noteAddCount % 5 == 0 &&
              noteAddInterstitialSetting &&
              _interstitialAd != null) {
            _showInterstitialAd();
          }
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
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        "취소",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
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
      shape: RoundedRectangleBorder(
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

          //Google Admob event
          noteAddCount++;
          notifyListeners();
          noteAddInterstitialSetting = Firebase_Remote_Config()
              .remoteConfig
              .getBool('noteAddInterstitialSetting');
          if (noteAddCount % 5 == 0 &&
              noteAddInterstitialSetting &&
              _interstitialAd != null) {
            _showInterstitialAd();
          }
        }
      },
      child: Text("애창곡 노트에 추가",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text("${songNumber}", style: TextStyle(color: kMainColor)),
              Spacer(),
              IconButton(
                onPressed: () async {
                  final url = Uri.parse(
                      'https://www.youtube.com/results?search_query= ${title} ${singer}');
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
                icon: SvgPicture.asset("assets/icons/youtube.svg"),
              )
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
      shape: RoundedRectangleBorder(
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
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Analytics_config().noteDeleteEvent(note.tj_title);
        deleteNote(note);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Text("삭제", style: TextStyle(fontWeight: FontWeight.w600)),
    );

    Widget cancelButton = ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("취소", style: TextStyle(fontWeight: FontWeight.w600)));

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
}
