import 'dart:convert';

import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'note.dart';

class NoteData extends ChangeNotifier {
  List<Note> notes = [];
  bool emptyCheck = false;

  final storage = new FlutterSecureStorage();

  void initNotes() async {
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

    final Identify identify = Identify()..set('노트 개수', notes.length);

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'noteCnt', value: notes.length.toString());

    Analytics_config.analytics.identify(identify);

    //!event : 노트 뷰 조회
    Analytics_config.analytics.logEvent('애창곡 노트 뷰 - 노트 뷰  조회',
        eventProperties: {'노트 개수': notes.length, '메모 노트 개수': memoCnt});

    FirebaseAnalytics.instance.logEvent(
        name: 'noteView__view_notes',
        parameters: {'noteCnt': notes.length, 'memoNoteCnt': memoCnt});

    notifyListeners();
  }

  //!event : 애창곡 노트 뷰 - 곡 추가
  Future<void> addNoteEvent() async {
    Analytics_config.analytics.logEvent('애창곡 노트 뷰 - 곡 추가');

    FirebaseAnalytics.instance.logEvent(name: 'noteView__add_note');

    final Identify identify = Identify()..set('노트 개수', notes.length);

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'noteCnt', value: notes.length.toString());

    Analytics_config.analytics.identify(identify);
  }

  //!event : 애창곡 노트 뷰 - 곡 상세 정보 조회
  void viewNoteEvent(Note note) {
    Analytics_config.analytics
        .logEvent('애창곡 노트 뷰 - 곡 상세 정보 조회', eventProperties: {
      '곡 이름': note.tj_title,
      '가수 이름': note.tj_singer,
      'TJ 번호': note.tj_songNumber,
      '금영 번호': note.ky_songNumber,
      '최고음': pitchNumToString[note.pitchNum],
      '매칭 여부': (note.tj_songNumber == note.ky_songNumber),
      '메모 여부': note.memo
    });

    FirebaseAnalytics.instance
        .logEvent(name: 'noteView__search_detail_note', parameters: {
      'title': note.tj_title,
      'singer': note.tj_singer,
      'TJ_number': note.tj_songNumber,
      'KY_number': note.ky_songNumber,
      'max_pitch': pitchNumToString[note.pitchNum],
      'IsMatched': (note.tj_songNumber == note.ky_songNumber),
      'Ismemo': note.memo
    });
  }

  //!event: 곡 추가 뷰 - 리스트 클릭 시
  void addSongClickEvent(FitchMusic fitchMusic) {
    Analytics_config.analytics.logEvent('곡 추가 뷰 - 리스트 클릭 시', eventProperties: {
      '곡 이름': fitchMusic.tj_title,
      '가수 이름': fitchMusic.tj_singer,
      'TJ 번호': fitchMusic.tj_songNumber,
      '금영 번호': fitchMusic.ky_songNumber,
      '최고음': fitchMusic.pitchNum,
      '매칭 여부': (fitchMusic.tj_songNumber == fitchMusic.ky_songNumber),
    });

    FirebaseAnalytics.instance
        .logEvent(name: 'note_add_view__click_list', parameters: {
      'title': fitchMusic.tj_title,
      'singer': fitchMusic.tj_singer,
      'TJ_number': fitchMusic.tj_songNumber,
      'KY_number': fitchMusic.ky_songNumber,
      'max_pitch': fitchMusic.pitchNum,
      'IsMatched': (fitchMusic.tj_songNumber == fitchMusic.ky_songNumber),
    });
  }

  //!event: 곡 상세정보 뷰 - 노트 삭제
  void noteDeleteEvent(Note note) {
    Analytics_config.analytics.logEvent('곡 상세정보 뷰 - 노트 삭제', eventProperties: {
      '곡 이름': note.tj_title,
      '가수 이름': note.tj_singer,
      'TJ 번호': note.tj_songNumber,
      '금영 번호': note.ky_songNumber,
      '최고음': pitchNumToString[note.pitchNum],
      '매칭 여부': (note.tj_songNumber == note.ky_songNumber),
    });

    FirebaseAnalytics.instance
        .logEvent(name: 'note_detail_view__delete_note', parameters: {
      'title': note.tj_title,
      'singer': note.tj_singer,
      'TJ_number': note.tj_songNumber,
      'KY_number': note.ky_songNumber,
      'max_pitch': pitchNumToString[note.pitchNum],
      'IsMatched': (note.tj_songNumber == note.ky_songNumber),
    });
  }

  //!event: 곡 상세정보 뷰 - 최고음 들어보기
  void pitchListenEvent() {
    Analytics_config.analytics.logEvent('곡 상세정보 뷰 - 최고음 들어보기');

    FirebaseAnalytics.instance.logEvent(name: 'note_detail_view__listen_pitch');
  }

  //!event: 곡 상세정보 뷰 - 유튜브 클릭
  void youtubeClickEvent(Note note) {
    Analytics_config.analytics.logEvent('곡 상세정보 뷰 - 유튜브 클릭',
        eventProperties: {'곡 이름': note.tj_title, '메모': note.memo});

    FirebaseAnalytics.instance.logEvent(
        name: 'note_detail_view__click_youtube',
        parameters: {'title': note.tj_title, 'memo': note.memo});
  }

  //!event: 곡 상세정보 뷰 - 금영 검색
  void kySearchEvent(String tjNumber) {
    Analytics_config.analytics
        .logEvent('곡 상세정보 뷰 - 금영 검색', eventProperties: {'TJ 번호': tjNumber});
    FirebaseAnalytics.instance.logEvent(
        name: 'song_detail_view__KY_search',
        parameters: {'TJ_number': tjNumber});
  }

  //!event: 곡 상세정보 뷰 - 메모 수정
  void songMemoEditEvent(String title) {
    Analytics_config.analytics
        .logEvent('곡 상세정보 뷰 - 메모 수정', eventProperties: {'곡 이름': title});
    FirebaseAnalytics.instance.logEvent(
        name: 'song_detail_view__edit_memo', parameters: {'title': title});
  }

  //!event: 일반 노래 검색 뷰 - 페이지뷰
  void musicBookScreenPageViewEvent() {
    Analytics_config.analytics.logEvent('일반 노래 검색 뷰 - 페이지뷰');
    FirebaseAnalytics.instance
        .logEvent(name: 'normal_chart_search_view__pageView');
  }

  //!event: 인기 차트 검색 뷰 - 페이지뷰
  void popChartScreenPageViewEvent() {
    Analytics_config.analytics.logEvent('인기 차트 검색 뷰 - 페이지뷰');
    FirebaseAnalytics.instance
        .logEvent(name: 'pop_chart_search_view__pageView');
  }

  //!event: 최고음 차트 검색 뷰 - 페이지뷰
  void pitchChartScreenPageViewEvent() {
    Analytics_config.analytics.logEvent('최고음 차트 검색 뷰 - 페이지뷰');
    FirebaseAnalytics.instance
        .logEvent(name: 'pitch_chart_search_view__pageView');
  }

  //!event: 곡 상세정보 - 최고음 요청
  void pitchRequestEvent(Note note) {
    Analytics_config.analytics
        .logEvent('곡 상세 정보 - 최고음 요청 이벤트', eventProperties: {
      '곡 이름': note.tj_title,
      '가수 이름': note.tj_singer,
      'TJ 번호': note.tj_songNumber,
      '금영 번호': note.ky_songNumber,
      '매칭 여부': (note.tj_songNumber == note.ky_songNumber),
      '메모 여부': note.memo
    });
    FirebaseAnalytics.instance
        .logEvent(name: 'song_detail_view__pitch_request', parameters: {
      'title': note.tj_title,
      'singer': note.tj_singer,
      'TJ_number': note.tj_songNumber,
      'KY_number': note.ky_songNumber,
      'IsMatched': (note.tj_songNumber == note.ky_songNumber),
      'Ismemo': note.memo
    });
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
            0);

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

          await FirebaseAnalytics.instance
              .setUserProperty(name: 'noteCnt', value: notes.length.toString());

          Analytics_config.analytics.identify(identify);

          //!event: 곡 추가 뷰 - 노트 추가 이벤트
          Analytics_config.analytics
              .logEvent('검색 - 노트 추가 이벤트', eventProperties: {
            '곡 이름': note.tj_title,
            '가수 이름': note.tj_singer,
            'TJ 번호': note.tj_songNumber,
            '금영 번호': note.ky_songNumber,
            '매칭 여부': (note.tj_songNumber == note.ky_songNumber),
            '메모 여부': note.memo
          });
          FirebaseAnalytics.instance
              .logEvent(name: 'search__add_note_event', parameters: {
            'noteCnt': notes.length,
            'title': note.tj_title,
            'singer': note.tj_singer,
            'TJ_number': note.tj_songNumber,
            'KY_number': note.ky_songNumber,
            'IsMatched': (note.tj_songNumber == note.ky_songNumber),
            'Ismemo': note.memo
          });
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
    for (Note no in notes) {
      if (note.tj_songNumber == no.tj_songNumber) {
        no.memo = memo;
      }
    }
    await storage.write(key: 'notes', value: jsonEncode(notes));
    //await storage.write(key: note.tj_songNumber, value: memo);
    notifyListeners();
  }

  //local storage 에도 삭제 작업 필요
  Future<void> deleteNote(Note note) async {
    notes.remove(note);
    await storage.write(key: 'notes', value: jsonEncode(notes));
    //await storage.delete(key: note.tj_songNumber);
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
  void showAddNoteDialog(BuildContext context, String songNumber, String title) {
    double defaultSize = SizeConfig.defaultSize;

    Widget okButton = ElevatedButton(
      onPressed: () {
        Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
            songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
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
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  // 간단한 정보를 보여주고 애창곡노트 추가버튼이 있는 다이어로그 팝업 함수
  void showAddNoteDialogWithInfo(BuildContext context, {required String songNumber, required String title, required String singer}) {
    double defaultSize = SizeConfig.defaultSize;

    Widget okButton = ElevatedButton(
      onPressed: () {
        addNoteBySongNumber(
            songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
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
              Text("${songNumber}",
                  style: TextStyle(color: kMainColor)),
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
        Center(child: okButton),
      ],
      backgroundColor: kDialogColor,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
