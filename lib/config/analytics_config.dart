import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/firebase/firebase_options.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

class Analytics_config {
  static late Amplitude analytics =
      Amplitude.getInstance(instanceName: "conopot");

  static FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;

  late Identify identify;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize SDK
    analytics.init('cf1298f461883c1cbf97daeb0393b987');

    // Enable COPPA privacy guard. This is useful when you choose not to report sensitive user information.
    analytics.enableCoppaControl();

    // Turn on automatic session events
    analytics.trackingSessionEvents(true);
  }

  void event(String eventName, Map<String, dynamic> properties) {
    //Amplitude
    analytics.logEvent(eventName, eventProperties: properties);

    //Google Analytics
    FirebaseAnalytics.instance
        .logEvent(name: eventName, parameters: properties);
  }

  noteViewPageViewEvent() {
    Analytics_config().event('애창곡_노트_뷰__페이지뷰', {});
  }

  //!event : 애창곡_노트_뷰__곡_추가_버튼클릭
  addNoteEvent(int noteCnt) async {
    Analytics_config().event('애창곡_노트_뷰__곡_추가_버튼클릭', {});

    final Identify identify = Identify()..set('노트 개수', noteCnt);

    await FirebaseAnalytics.instance
        .setUserProperty(name: 'noteCnt', value: noteCnt.toString());

    Analytics_config.analytics.identify(identify);
  }

  //!event : 애창곡_노트_뷰__노트_상세_정보_조회
  viewNoteEvent(Note note) {
    Analytics_config().event('애창곡_노트_뷰__노트_상세_정보_조회', {
      '곡_이름': note.tj_title,
      '가수_이름': note.tj_singer,
      'TJ_번호': note.tj_songNumber,
      '금영_번호': note.ky_songNumber,
      '최고음': pitchNumToString[note.pitchNum],
      '매칭_여부': (note.tj_songNumber == note.ky_songNumber),
      '메모_여부': note.memo
    });
  }

  //!event : 애창곡_노트_뷰__배너_추천노래
  noteViewBannerRecommandEvent() {
    Analytics_config().event('애창곡_노트_뷰__배너_추천노래', {});
  }

  //!event : 애창곡_노트_뷰__배너_음역대측정
  noteViewBannerMeasureEvent() {
    Analytics_config().event('애창곡_노트_뷰__배너_음역대측정', {});
  }

  //!event : 애창곡_노트_뷰__배너_노트설정
  noteViewBannerNoteSettingEvent() {
    Analytics_config().event('애창곡_노트_뷰__배너_노트설정', {});
  }

  //!event: 노트_추가_뷰__노래선택
  addSongClickEvent(FitchMusic fitchMusic) {
    Analytics_config().event('노트_추가_뷰__노래선택', {
      '곡_이름': fitchMusic.tj_title,
      '가수_이름': fitchMusic.tj_singer,
      'TJ_번호': fitchMusic.tj_songNumber,
      '금영_번호': fitchMusic.ky_songNumber,
      '최고음': fitchMusic.pitchNum,
      '매칭_여부': (fitchMusic.tj_songNumber == fitchMusic.ky_songNumber),
    });
  }

  //!event: 노트_상세정보_뷰__노트_삭제
  noteDeleteEvent(Note note) {
    Analytics_config().event('노트_상세정보_뷰__노트_삭제', {
      '곡_이름': note.tj_title,
      '가수_이름': note.tj_singer,
      'TJ_번호': note.tj_songNumber,
      '금영_번호': note.ky_songNumber,
      '최고음': pitchNumToString[note.pitchNum],
      '매칭_여부': (note.tj_songNumber == note.ky_songNumber),
    });
  }

  //!event: 노트_상세정보_뷰__최고음_들어보기
  pitchListenEvent() {
    Analytics_config().event('노트_상세정보_뷰__최고음_들어보기', {});
  }

  //!event: 곡 상세정보 뷰 - 유튜브 클릭
  youtubeClickEvent(Note note) {
    Analytics_config()
        .event('노트_상세정보_뷰__유튜브_클릭', {'곡_이름': note.tj_title, '메모': note.memo});
  }

  //!event: 곡 상세정보 뷰 - 금영 검색
  kySearchEvent(String tjNumber) {
    Analytics_config().event('노트_상세정보_뷰__금영_검색', {'TJ_번호': tjNumber});
  }

  //!event: 곡 상세정보 뷰 - 메모 수정
  songMemoEditEvent(String title) {
    Analytics_config().event('노트_상세정보_뷰__메모_수정', {'곡_이름': title});
  }

  //!event: 일반 노래 검색 뷰 - 페이지뷰
  musicBookScreenPageViewEvent() {
    Analytics_config().event('일반_노래_검색_뷰__페이지뷰', {});
  }

  //!event: 인기 차트 검색 뷰 - 페이지뷰
  popChartScreenPageViewEvent() {
    Analytics_config().event('인기_차트_검색_뷰__페이지뷰', {});
  }

  //!event: 최고음 차트 검색 뷰 - 페이지뷰
  pitchChartScreenPageViewEvent() {
    Analytics_config().event('최고음_차트_검색_뷰__페이지뷰', {});
  }

  //!event: 곡 상세정보 - 최고음 요청
  pitchRequestEvent(Note note) {
    Analytics_config().event('노트_상세_정보__최고음_요청_이벤트', {
      '곡_이름': note.tj_title,
      '가수_이름': note.tj_singer,
      'TJ_번호': note.tj_songNumber,
      '금영_번호': note.ky_songNumber,
      '매칭_여부': (note.tj_songNumber == note.ky_songNumber),
      '메모_여부': note.memo
    });
  }

  //!event: 애창곡 노트 뷰 - 최고음 배너 클릭 시
  void pitchBannerClickEvent(int noteCnt) {
    Analytics_config().event('애창곡_노트_뷰__최고음_배너_클릭', {});
  }

  //!event: 애창곡 노트 뷰 - 노트 설정 배너 클릭 시
  void noteSettingBannerClickEvent(int noteCnt) {
    Analytics_config().event('애창곡_노트_뷰__노트설정_배너_클릭', {});
  }

  //!event: 내 정보 - 최고음 측정 여부
  void checkPitchMeasureEvent(int noteCnt) {
    Analytics_config().event('내_정보__최고음_측정_여부', {});
  }

  //!event: 최고음 검색 뷰 - 정렬
  void pitchSortEvent(String sortOptionStr) {
    Analytics_config().event('최고음_검색_뷰__정렬', {'정렬_기준': sortOptionStr});
  }
}
