import 'dart:convert';
import 'dart:math';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MusicSearchItemLists extends ChangeNotifier {
  List<MusicSearchItem> foundItems = [];
  List<MusicSearchItem> results = [];
  List<MusicSearchItem> tjSongList = [];
  List<MusicSearchItem> kySongList = [];
  List<MusicSearchItem> tjChartSongList = [];
  List<MusicSearchItem> kyChartSongList = [];
  List<FitchMusic> highestSongList = [];
  List<FitchMusic> highestFoundItems = [];
  List<FitchMusic> highestResults = [];
  List<FitchMusic> combinedSongList = [];
  List<FitchMusic> combinedFoundItems = [];

  List<bool> isChecked = [];
  List<FitchMusic> checkedMusics = [];

  int tabIndex = 1; // TJ or 금영

  int userPitch = 23;

  int userMaxPitch = -1;

  int userNoteSetting = 0; //(0: 번호, 1: 최고음, 2: 최고음 차이)

  final storage = new FlutterSecureStorage();

  //측정 결과 페이지 (유저의 최고음이 바뀐 경우)
  void changeUserPitch({required int pitch}) {
    userPitch = pitch;
    notifyListeners();
  }

  //유저가 노트 세팅을 바꿨을 때
  void changeUserNoteSetting(int settingNum) {
    userNoteSetting = settingNum;
    storage.write(key: 'userNoteSetting', value: settingNum.toString());
    notifyListeners();
  }

  void getMaxPitch() {
    userMaxPitch = -1;

    /// 사용자가 선택한 노래가 존재한다면
    if (checkedMusics.isNotEmpty) {
      for (FitchMusic iter in checkedMusics) {
        userMaxPitch = max(userMaxPitch, iter.pitchNum);
      }
    }
    notifyListeners();
  }

  void changeSortOption({required String? option}) {
    ///option에 따라 현재 리스트에서 보여지는 highestFoundItems를 정렬한다.
    if (option == '내 음역대의 노래' && userMaxPitch != -1) {
      highestFoundItems = highestFoundItems
          .where((string) => (userPitch - 1 <= string.pitchNum &&
              string.pitchNum <= userPitch + 1))
          .toList();
    } else if (option == '높은 음정순') {
      highestFoundItems.sort(((a, b) => b.pitchNum.compareTo(a.pitchNum)));
    } else if (option == '낮은 음정순') {
      highestFoundItems.sort(((a, b) => a.pitchNum.compareTo(b.pitchNum)));
    } else {
      highestFoundItems = List.from(highestSongList);
    }

    notifyListeners();
  }

  Future<String> getTJMusics() async {
    return await rootBundle.loadString('assets/musics/musicbook_TJ.txt');
  }

  Future<String> getTJMusicChart() async {
    return await rootBundle.loadString('assets/musics/chart_TJ.txt');
  }

  Future<String> getKYMusics() async {
    return await rootBundle.loadString('assets/musics/musicbook_KY.txt');
  }

  Future<String> getKYMusicChart() async {
    return await rootBundle.loadString('assets/musics/chart_KY.txt');
  }

  Future<String> getHighMusics() async {
    return await rootBundle.loadString('assets/musics/music_highest_key.txt');
  }

  Future<String> getCombinedMusics() async {
    return await rootBundle.loadString('assets/musics/matching_Musics.txt');
  }

  void initFitch() {
    highestFoundItems = List.from(highestSongList);
    notifyListeners();
  }

  void initChart() {
    foundItems = tjChartSongList;
  }

  void initBook() {
    foundItems = tjSongList;
  }

  void initCombinedBook() {
    combinedFoundItems = combinedSongList;
  }

  void initPitchMusic({required int pitchNum}) {
    highestResults = List.from(highestSongList);
    highestResults = highestResults
        .where((string) => (pitchNum - 1 <= string.pitchNum &&
            string.pitchNum <= pitchNum + 1))
        .toList();
    highestFoundItems = highestResults;
  }

  // 프로그램 실행 시, 노래방 책 List 초기화 (TJ, KY txt -> List)
  void init() async {
    //!event : 앱 실행

    Analytics_config.firebaseAnalytics.logAppOpen();

    //사용자 음정 불러오기
    String? value = await storage.read(key: 'userPitch');
    if (value != null) {
      userPitch = int.parse(value);
      userMaxPitch = userPitch;
    }

    final Identify identify = Identify()
      ..set('최고음 측정 여부', (userMaxPitch != -1))
      ..set('최고음', pitchNumToString[userPitch]);

    Analytics_config.analytics.identify(identify);

    value = await storage.read(key: 'userNoteSetting');
    if (value != null) {
      userNoteSetting = int.parse(value);
    }

    String TJMusics = await getTJMusics();
    String TJMusicChart = await getTJMusicChart();
    String KYMusics = await getKYMusics();
    String KYMusicChart = await getKYMusicChart();
    String HighMusics = await getHighMusics();
    String CombinedMusics = await getCombinedMusics();

    LineSplitter ls = new LineSplitter();

    List<String> contents = ls.convert(TJMusics);

    parseMusics(contents, tjSongList);
    foundItems = tjSongList;

    contents = ls.convert(KYMusics);
    parseMusics(contents, kySongList);

    contents = ls.convert(TJMusicChart);
    parseMusics(contents, tjChartSongList);

    contents = ls.convert(KYMusicChart);
    parseMusics(contents, kyChartSongList);

    //최고음 db 파싱
    contents = ls.convert(HighMusics);

    late String tj_title, tj_singer, tj_songNumber;
    late String ky_title, ky_singer, ky_songNumber;
    late String gender, fitch;
    late int fitchNum;

    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;

      for (int i = 0; i < 9; i++) {
        end = str.indexOf('^', start);
        if (start == end) continue;
        String tmp = str.substring(start, end);
        start = end + 1;

        if (i == 0)
          tj_title = tmp;
        else if (i == 1)
          tj_singer = tmp;
        else if (i == 2)
          tj_songNumber = tmp;
        else if (i == 3)
          ky_title = tmp;
        else if (i == 4)
          ky_singer = tmp;
        else if (i == 5)
          ky_songNumber = tmp;
        else if (i == 6)
          gender = tmp;
        else if (i == 7)
          fitch = tmp;
        else
          fitchNum = int.parse(tmp);
      }

      highestSongList.add(FitchMusic(
          tj_title: tj_title,
          tj_singer: tj_singer,
          tj_songNumber: tj_songNumber,
          ky_title: ky_title,
          ky_singer: ky_singer,
          ky_songNumber: ky_songNumber,
          gender: gender,
          pitch: fitch,
          pitchNum: fitchNum));
      highestFoundItems = List.from(highestSongList);

      isChecked = List<bool>.filled(highestFoundItems.length, false);
      notifyListeners();
    }

    //최고음 db 파싱
    contents = ls.convert(CombinedMusics);

    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;

      for (int i = 0; i < 9; i++) {
        end = str.indexOf('^', start);
        if (start == end) continue;
        String tmp = str.substring(start, end);
        start = end + 1;

        if (i == 0)
          tj_title = tmp;
        else if (i == 1)
          tj_singer = tmp;
        else if (i == 2)
          tj_songNumber = tmp;
        else if (i == 3)
          ky_title = tmp;
        else if (i == 4)
          ky_singer = tmp;
        else if (i == 5)
          ky_songNumber = tmp;
        else if (i == 6)
          gender = tmp;
        else if (i == 7)
          fitch = tmp;
        else
          fitchNum = (tmp != '?') ? int.parse(tmp) : 0;
      }

      combinedSongList.add(FitchMusic(
          tj_title: tj_title,
          tj_singer: tj_singer,
          tj_songNumber: tj_songNumber,
          ky_title: ky_title,
          ky_singer: ky_singer,
          ky_songNumber: ky_songNumber,
          gender: gender,
          pitch: fitch,
          pitchNum: fitchNum));
    }

    combinedFoundItems = combinedSongList;

    notifyListeners();
  }

  void changeTabIndex({required int index}) {
    tabIndex = index;
    foundItems = (index == 1) ? tjSongList : kySongList;
    notifyListeners();
  }

  void changeChartTabIndex({required int index}) {
    tabIndex = index;
    foundItems = (index == 1) ? tjChartSongList : kyChartSongList;
    notifyListeners();
  }

  // 검색 필터링 기능(일반검색)
  void runFilter(String enteredKeyword, int _tabIndex) {
    EasyDebounce.debounce('searching', Duration(milliseconds: 500), () {
      results = [];
      //공백 제거 && 대문자 → 소문자 변경
      enteredKeyword = enteredKeyword.replaceAll(' ', '').toLowerCase();
      if (_tabIndex == 1) {
        //TJ
        if (enteredKeyword.isEmpty) {
          results = tjSongList;
        } else {
          results = tjSongList
              .where((string) =>
                  (string.title.replaceAll(' ', '').toLowerCase())
                      .contains(enteredKeyword) ||
                  (string.singer.replaceAll(' ', '').toLowerCase())
                      .contains(enteredKeyword))
              .toList();
        }
      } else {
        //KY
        if (enteredKeyword.isEmpty) {
          results = kySongList;
        } else {
          results = kySongList
              .where((string) =>
                  (string.title.replaceAll(' ', '').toLowerCase())
                      .contains(enteredKeyword) ||
                  (string.singer.replaceAll(' ', '').toLowerCase())
                      .contains(enteredKeyword))
              .toList();
        }
      }
      foundItems = results;

      //!event : 일반 검색 뷰 - 검색 키워드
      Analytics_config.analytics.logEvent('일반 검색 뷰 - 검색 키워드', eventProperties: {
        '검색 키워드': enteredKeyword,
      });

      Analytics_config.firebaseAnalytics
          .logEvent(name: '일반 검색 뷰 - 검색 키워드', parameters: {
        '검색 키워드': enteredKeyword,
      });

      notifyListeners();
    });
  }

  // 검색 필터링 기능(곡 추가 시 검색)
  void runKYFilter(String enteredKeyword) {
    results = [];
    enteredKeyword = enteredKeyword.replaceAll(' ', '').toLowerCase();
    if (enteredKeyword.isEmpty) {
      results = kySongList;
    } else {
      results = kySongList
          .where((string) =>
              (string.title.replaceAll(' ', '').toLowerCase())
                  .contains(enteredKeyword) ||
              (string.singer.replaceAll(' ', '').toLowerCase())
                  .contains(enteredKeyword))
          .toList();
    }
    foundItems = results;
    notifyListeners();
  }

  // 검색 필터링 기능(전체검색)
  void runCombinedFilter(String enteredKeyword) {
    EasyDebounce.debounce('searching', Duration(milliseconds: 500), () {
      highestResults = [];
      //공백 제거 && 대문자 → 소문자 변경
      enteredKeyword = enteredKeyword.replaceAll(' ', '').toLowerCase();

      if (enteredKeyword.isEmpty) {
        highestResults = combinedSongList;
      } else {
        highestResults = combinedSongList
            .where((string) =>
                (string.tj_title.replaceAll(' ', '').toLowerCase())
                    .contains(enteredKeyword) ||
                (string.tj_singer.replaceAll(' ', '').toLowerCase())
                    .contains(enteredKeyword))
            .toList();
      }

      combinedFoundItems = highestResults;

      //!event : 곡 추가 뷰 - 검색 키워드
      Analytics_config.analytics.logEvent('곡 추가 뷰 - 검색 키워드', eventProperties: {
        '검색 키워드': enteredKeyword,
      });

      notifyListeners();
    });
  }

  // 검색 필터링 기능(인기검색)
  void runHighFitchFilter(String enteredKeyword) {
    EasyDebounce.debounce('searching', Duration(milliseconds: 500), () {
      highestResults = List.from(highestSongList);
      //공백 제거 && 대문자 → 소문자 변경
      enteredKeyword = enteredKeyword.replaceAll(' ', '').toLowerCase();
      // !event : 간접 음역대 측정뷰 - 페이지뷰
      Analytics_config.analytics.logEvent('간접 음역대 측정뷰 - 검색',
          eventProperties: {'검색 키워드': enteredKeyword});
      if (!enteredKeyword.isEmpty) {
        highestResults = highestResults
            .where((string) =>
                (string.tj_title.replaceAll(' ', '').toLowerCase())
                    .contains(enteredKeyword) ||
                (string.tj_singer.replaceAll(' ', '').toLowerCase())
                    .contains(enteredKeyword))
            .toList();
      }
      highestFoundItems = highestResults;

      //!event : 최고음 검색 뷰 - 검색 키워드
      Analytics_config.analytics
          .logEvent('최고음 검색 뷰 - 검색 키워드', eventProperties: {
        '검색 키워드': enteredKeyword,
      });

      notifyListeners();
    });
  }

  void parseMusics(List<String> contents, List<MusicSearchItem> musicList) {
    late String title, singer, songNumber;
    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;

      for (int i = 0; i < 3; i++) {
        end = str.indexOf('^', start);
        if (start == end) continue;
        String tmp = str.substring(start, end);
        start = end + 1;

        if (i == 0)
          title = tmp;
        else if (i == 1)
          singer = tmp;
        else
          songNumber = tmp;
      }
      musicList.add(MusicSearchItem(
          title: title, singer: singer, songNumber: songNumber));
    }
  }

  //!event: 애창곡 노트 뷰 - 최고음 배너 클릭 시
  void pitchBannerClickEvent(int noteCnt) {
    Analytics_config.analytics.logEvent('애창곡 노트 뷰 - 최고음 배너 클릭',
        eventProperties: {
          '사용자 최고음 등록 여부': (userMaxPitch != -1),
          '노트 개수': noteCnt
        });
  }

  //!event: 애창곡 노트 뷰 - 노트 설정 배너 클릭 시
  void noteSettingBannerClickEvent(int noteCnt) {
    Analytics_config.analytics.logEvent('애창곡 노트 뷰 - 노트 설정 배너 클릭',
        eventProperties: {
          '사용자 최고음 등록 여부': (userMaxPitch != -1),
          '노트 개수': noteCnt
        });
  }

  //!event: 내 정보 - 최고음 측정 여부
  void checkPitchMeasureEvent(int noteCnt) {
    Analytics_config.analytics.logEvent('내 정보 - 최고음 측정 여부', eventProperties: {
      '사용자 최고음 등록 여부': (userMaxPitch != -1),
      '노트 개수': noteCnt
    });
  }

  //!event: 최고음 검색 뷰 - 정렬
  void pitchSortEvent(String sortOptionStr) {
    Analytics_config.analytics.logEvent('최고음 검색 뷰 - 정렬', eventProperties: {
      '정렬 기준': sortOptionStr,
    });
  }
}
