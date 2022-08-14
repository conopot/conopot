import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:amplitude_flutter/identify.dart';
import 'package:archive/archive.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MusicSearchItemLists extends ChangeNotifier {
  List<MusicSearchItem> foundItems = [];
  List<MusicSearchItem> results = [];
  List<MusicSearchItem> tjSongList = [];
  List<MusicSearchItem> kySongList = [];
  List<MusicSearchItem> tjChartSongList = [];
  List<MusicSearchItem> kyChartSongList = [];
  List<FitchMusic> highestSongList = [];
  List<FitchMusic> highestFoundItems = [];
  List<FitchMusic> customizeRecommendationList = [];
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
  static var httpClient = new HttpClient();

  late String dir;

  Future<Directory> get _localDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  //유저 음악 버전 체크 (true: 최신버전, false: 버전 업데이트 필요)
  Future<int> checkVersionUpdate() async {
    //사용자의 music file 버전을 가져온다.
    String? userVersionStr = await storage.read(key: 'userVersion');

    //사용자의 music version을 쿼리 파라미터로 전달
    String url =
        'https://ix108hjjtk.execute-api.ap-northeast-2.amazonaws.com/default/Conopot_Music_Version?type=get';

    final response = await http.get(
      Uri.parse(url),
    );

    int s3Version = int.parse(response.body);
    bool result = await InternetConnectionChecker().hasConnection;

    //버전 정보가 없는 첫 설치 이용자라면 -> 파일 내려받기
    if (userVersionStr == null) {
      print("신규 사용자");
      await fileUpdate();
      storage.write(key: 'userVersion', value: s3Version.toString());
    } else {
      int userVersion = int.parse(userVersionStr);
      //만약 s3에 있는 버전이 더 신 버전이라면 다운로드가 필요하다.
      if (s3Version > userVersion) {
        print("업데이트가 필요한 사용자");
        await fileUpdate();
        storage.write(key: 'userVersion', value: s3Version.toString());
      } else {
        print("이미 업데이트된 버전을 갖고 있는 사용자");
      }
    }

    return 1;
  }

  // Download the ZIP file using the HTTP library //
  Future<File> _downloadFile(String url, String fileName) async {
    //print("download file in");
    var req = await http.Client().get(Uri.parse(url));
    var file = File('$dir/$fileName');
    //print(file.path);
    return file.writeAsBytes(req.bodyBytes);
  }

  unarchiveAndSave(var zippedFile) async {
    //print("unarchiveAndSave in");

    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);

    //print(archive);
    for (var file in archive) {
      var fileName = '$dir/${file.name}';
      //print(fileName);
      if (file.isFile) {
        var outFile = File(fileName);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  fileUpdate() async {
    //print("fileUpdate in");
    final doc = await _localDirectory;

    //aws cloud front url (Musics.zip in S3)
    String url = "https://d26jfubr2fa7sp.cloudfront.net/Musics.zip";

    //zip file download
    var zippedFile = await _downloadFile(url, "Musics.zip");

    //print("??");

    //unzip and save in path provider(device storage)
    await unarchiveAndSave(zippedFile);
  }

  //측정 결과 페이지 (유저의 최고음이 바뀐 경우)
  void changeUserPitch({required int pitch}) {
    userPitch = pitch;
    userMaxPitch = pitch;
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

  // Future<String> getTJMusics() async {
  //   return await rootBundle.loadString('assets/musics/musicbook_TJ.txt');
  // }

  // Future<String> getTJMusicChart() async {
  //   return await rootBundle.loadString('assets/musics/chart_TJ.txt');
  // }

  // Future<String> getKYMusics() async {
  //   return await rootBundle.loadString('assets/musics/musicbook_KY.txt');
  // }

  // Future<String> getKYMusicChart() async {
  //   return await rootBundle.loadString('assets/musics/chart_KY.txt');
  // }

  // Future<String> getHighMusics() async {
  //   return await rootBundle.loadString('assets/musics/highest_Pitch.txt');
  // }

  // Future<String> getCombinedMusics() async {
  //   return await rootBundle.loadString('assets/musics/matching_Musics.txt');
  // }

  //리소스 업데이트 코드 (개발 완료되면 풀 것)
  Future<String> getTJMusics() async {
    final file = File('$dir/musicbook_TJ.txt');
    return file.readAsString();
  }

  Future<String> getTJMusicChart() async {
    final file = File('$dir/chart_TJ.txt');
    return file.readAsString();
  }

  Future<String> getKYMusics() async {
    final file = File('$dir/musicbook_KY.txt');
    return file.readAsString();
  }

  Future<String> getKYMusicChart() async {
    final file = File('$dir/chart_KY.txt');
    return file.readAsString();
  }

  Future<String> getHighMusics() async {
    final file = File('$dir/highest_Pitch.txt');
    return file.readAsString();
  }

  Future<String> getCombinedMusics() async {
    final file = File('$dir/matching_Musics.txt');
    return file.readAsString();
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
    customizeRecommendationList = highestResults;
  }

  initVersion(bool isConnected) async {
    //리소스 업데이트 코드 (개발 완료되면 주석 풀 것)
    dir = (await getApplicationDocumentsDirectory()).path;
    if (isConnected) await checkVersionUpdate();

    init();
  }

  // 프로그램 실행 시, 노래방 책 List 초기화 (TJ, KY txt -> List)
  void init() async {
    //사용자 음정 불러오기
    String? value = await storage.read(key: 'userPitch');
    if (value != null) {
      userPitch = int.parse(value);
      userMaxPitch = userPitch;
    }

    final Identify identify = Identify()
      ..set('최고음 측정 여부', (userMaxPitch != -1))
      ..set('최고음', pitchNumToString[userPitch]);

    await FirebaseAnalytics.instance.setUserProperty(
        name: 'isPitchMeasured', value: (userMaxPitch != -1).toString());

    await FirebaseAnalytics.instance.setUserProperty(
        name: 'max_pitch', value: pitchNumToString[userPitch].toString());

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

    late String tj_songNumber, gender;
    late int pitchNum;

    bool errFlag = false;

    //최고음 정보가 있는 tj_songNumber map
    HashMap<String, String> songNumberToGender = HashMap<String, String>();
    HashMap<String, int> songNumberToPitchNum = HashMap<String, int>();

    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;
      errFlag = false;

      for (int i = 0; i < 3; i++) {
        end = str.indexOf('^', start);
        if (start == end) continue;
        if (end == -1) {
          errFlag = true;
          break;
        }
        String tmp = str.substring(start, end);
        start = end + 1;

        if (i == 0)
          tj_songNumber = tmp;
        else if (i == 1)
          gender = tmp;
        else
          pitchNum = int.parse(tmp);
      }

      if (errFlag) continue;

      songNumberToGender[tj_songNumber] = gender;
      songNumberToPitchNum[tj_songNumber] = pitchNum;
    }

    //통합 db 파싱
    contents = ls.convert(CombinedMusics);

    late String tj_title, tj_singer;
    late String ky_title, ky_singer, ky_songNumber;

    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;
      errFlag = false;

      for (int i = 0; i < 6; i++) {
        end = str.indexOf('^', start);
        if (start == end) continue;
        if (end == -1) {
          errFlag = true;
          break;
        }
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
        else if (i == 5) ky_songNumber = tmp;
      }

      if (errFlag) continue;

      if (songNumberToGender.containsKey(tj_songNumber)) {
        String gender = songNumberToGender[tj_songNumber]!;
        int pitchNum = songNumberToPitchNum[tj_songNumber]!;

        highestSongList.add(FitchMusic(
            tj_title: tj_title,
            tj_singer: tj_singer,
            tj_songNumber: tj_songNumber,
            ky_title: ky_title,
            ky_singer: ky_singer,
            ky_songNumber: ky_songNumber,
            gender: gender,
            pitchNum: pitchNum,
            search_keyword_title_singer: tj_title + tj_singer,
            search_keyword_singer_title: tj_singer + tj_title));

        combinedSongList.add(FitchMusic(
            tj_title: tj_title,
            tj_singer: tj_singer,
            tj_songNumber: tj_songNumber,
            ky_title: ky_title,
            ky_singer: ky_singer,
            ky_songNumber: ky_songNumber,
            gender: gender,
            pitchNum: pitchNum,
            search_keyword_title_singer: tj_title + tj_singer,
            search_keyword_singer_title: tj_singer + tj_title));
      } else {
        combinedSongList.add(FitchMusic(
            tj_title: tj_title,
            tj_singer: tj_singer,
            tj_songNumber: tj_songNumber,
            ky_title: ky_title,
            ky_singer: ky_singer,
            ky_songNumber: ky_songNumber,
            gender: '?',
            pitchNum: 0,
            search_keyword_title_singer: tj_title + tj_singer,
            search_keyword_singer_title: tj_singer + tj_title));
      }
    }

    combinedFoundItems = combinedSongList;

    highestFoundItems = List.from(highestSongList);
    customizeRecommendationList = highestFoundItems
        .where((string) => (userMaxPitch - 1 <= string.pitchNum &&
            string.pitchNum <= userMaxPitch + 1))
        .toList();
    isChecked = List<bool>.filled(highestFoundItems.length, false);

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
                      .contains(enteredKeyword) ||
                  (string.search_keyword_singer_title
                          .replaceAll(' ', '')
                          .toLowerCase())
                      .contains(enteredKeyword) ||
                  (string.search_keyword_title_singer
                          .replaceAll(' ', '')
                          .toLowerCase())
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
                      .contains(enteredKeyword) ||
                  (string.search_keyword_singer_title
                          .replaceAll(' ', '')
                          .toLowerCase())
                      .contains(enteredKeyword) ||
                  (string.search_keyword_title_singer
                          .replaceAll(' ', '')
                          .toLowerCase())
                      .contains(enteredKeyword))
              .toList();
        }
      }
      foundItems = results;

      //!event : 일반_검색_뷰__검색_키워드
      Analytics_config().event('일반_검색_뷰__검색_키워드', {'검색_키워드': enteredKeyword});
      Analytics_config().musicSearchKeywordEvent(enteredKeyword);

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
                  .contains(enteredKeyword) ||
              (string.search_keyword_singer_title
                      .replaceAll(' ', '')
                      .toLowerCase())
                  .contains(enteredKeyword) ||
              (string.search_keyword_title_singer
                      .replaceAll(' ', '')
                      .toLowerCase())
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
                    .contains(enteredKeyword) ||
                (string.search_keyword_singer_title
                        .replaceAll(' ', '')
                        .toLowerCase())
                    .contains(enteredKeyword) ||
                (string.search_keyword_title_singer
                        .replaceAll(' ', '')
                        .toLowerCase())
                    .contains(enteredKeyword))
            .toList();
      }

      combinedFoundItems = highestResults;

      //!event : 곡 추가 뷰 - 검색 키워드
      Analytics_config().event('노트_추가_뷰__검색_키워드', {'검색_키워드': enteredKeyword});
      Analytics_config().musicSearchKeywordEvent(enteredKeyword);

      notifyListeners();
    });
  }

  // 검색 필터링 기능(인기검색)
  void runHighFitchFilter(String enteredKeyword) {
    EasyDebounce.debounce('searching', Duration(milliseconds: 500), () {
      highestResults = List.from(highestSongList);
      //공백 제거 && 대문자 → 소문자 변경
      enteredKeyword = enteredKeyword.replaceAll(' ', '').toLowerCase();

      if (!enteredKeyword.isEmpty) {
        highestResults = highestResults
            .where((string) =>
                (string.tj_title.replaceAll(' ', '').toLowerCase())
                    .contains(enteredKeyword) ||
                (string.tj_singer.replaceAll(' ', '').toLowerCase())
                    .contains(enteredKeyword) ||
                (string.search_keyword_singer_title
                        .replaceAll(' ', '')
                        .toLowerCase())
                    .contains(enteredKeyword) ||
                (string.search_keyword_title_singer
                        .replaceAll(' ', '')
                        .toLowerCase())
                    .contains(enteredKeyword))
            .toList();
      }
      highestFoundItems = highestResults;

      //!event : 최고음 검색 뷰 - 검색 키워드
      Analytics_config().event('최고음_검색_뷰__검색_키워드', {'검색_키워드': enteredKeyword});
      Analytics_config().musicSearchKeywordEvent(enteredKeyword);

      notifyListeners();
    });
  }

  void parseMusics(List<String> contents, List<MusicSearchItem> musicList) {
    late String title, singer, songNumber;
    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;
      bool errFlag = false;

      for (int i = 0; i < 3; i++) {
        end = str.indexOf('^', start);
        if (end == -1) {
          errFlag = true;
          break;
        }
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
      if (errFlag) continue;

      musicList.add(MusicSearchItem(
          title: title,
          singer: singer,
          songNumber: songNumber,
          search_keyword_title_singer: title + singer,
          search_keyword_singer_title: singer + title));
    }
  }
}
