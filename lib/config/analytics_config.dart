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

  //!event : 애창곡_노트_뷰__페이지뷰
  noteViewPageViewEvent() {
    Analytics_config().event('애창곡_노트_뷰__페이지뷰', {});
  }

  //!event : 애창곡_노트_뷰__곡_추가_버튼클릭
  addNoteEvent() {
    Analytics_config().event('애창곡_노트_뷰__곡_추가_버튼클릭', {});
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

  musicSearchKeywordEvent(String keyword) {
    Analytics_config().event('노래검색__검색키워드', {'검색_키워드': keyword});
  }

  musicAddEvent(String songTitle) {
    Analytics_config().event('노래리스트__곡추가', {'곡명': songTitle});
  }

  addNotePageView() {
    Analytics_config().event('노트_추가_뷰__페이지뷰', {});
  }

  //!event: 노트_추가_뷰__노래선택
  addViewSongClickEvent(String title) {
    Analytics_config().event('노트_추가_뷰__노래선택', {'곡명': title});
  }

  //!event: 노트_추가_뷰__노래추가
  addViewSongAddEvent(String title) {
    Analytics_config().event('노트_추가_뷰__노래선택', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__페이지뷰
  noteDetailPageView() {
    Analytics_config().event('노트_상세정보_뷰__페이지뷰', {});
  }

  //!event: 노트_상세정보_뷰__금영번호찾기
  noteDetailViewFindKY(String tjNumber) {
    Analytics_config().event('노트_상세정보_뷰__금영번호찾기', {'tj번호': tjNumber});
  }

  //!event: 노트_상세정보_뷰__유튜브_노래듣기
  noteDetailViewYoutube(String title) {
    Analytics_config().event('노트_상세정보_뷰__유튜브_노래듣기', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__메모수정
  noteDetailViewMemo(String title) {
    Analytics_config().event('노트_상세정보_뷰__메모수정', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__노트_삭제
  noteDeleteEvent(String title) {
    Analytics_config().event('노트_상세정보_뷰__삭제', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__최고음요청
  pitchRequestEvent(String title) {
    Analytics_config().event('노트_상세정보_뷰__최고음요청', {'곡명': title});
  }

  //!event: 설정_뷰__페이지뷰
  settingPageView() {
    Analytics_config().event('설정_뷰__페이지뷰', {});
  }

  //!event: 설정_뷰__채널톡
  settingChannelTalk() {
    Analytics_config().event('설정_뷰__채널톡', {});
  }

  //!event: 애창곡_노트_설정_뷰__페이지뷰
  settingNotePageView() {
    Analytics_config().event('애창곡_노트_설정_뷰__페이지뷰', {});
  }

  //!event: 애창곡_노트_설정_뷰__설정아이템
  settingNoteSettingItem(String item) {
    Analytics_config().event('애창곡_노트_설정_뷰__설정아이템', {'아이템': item});
  }

  //!event: 음역대_측정_뷰__페이지뷰
  pitchMeasurePageView() {
    Analytics_config().event('음역대_측정_뷰__페이지뷰', {});
  }
}
