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

  //!event: 네비게이션__검색탭
  void clicksearchTapEvent() {
    Analytics_config().event('네비게이션__검색탭', {});
  }

  // !event: 네비게이션__추천탭
  void clickRecommendationTapEvent() {
    Analytics_config().event('네비게이션__추천탭', {});
  }

  // !event: 일반_검색_뷰__노래_유튜브
  void clickYoutubeButtonOnSearchView() {
    Analytics_config().event('일반_검색_뷰__노래_유튜브', {});
  }

  // !event: 추천_뷰__페이지뷰
  void recommendationPageVeiwEvent() {
    Analytics_config().event('추천_뷰__페이지뷰', {});
  }

  // !event: 추천_뷰__음역대_측정
  void clickRecommendationPitchDetectionButtonEvent() {
    Analytics_config().event('추천_뷰__음역대_측정', {});
  }

  // !event: 추천_뷰__맞춤_추천_더보기
  void clickCustomizeRecommendationButtonEvent() {
    Analytics_config().event('추천_뷰__맞춤_추천_더보기', {});
  }

  // !event: 추천_뷰__맞춤_추천_리스트_아이템_클릭
  void clickCustomizeRecommendationListItemEvent() {
    Analytics_config().event('추천_뷰__맞춤_추천_리스트_아이템_클릭', {});
  }

  // !event: 추천_뷰__TJ인기차트
  void clickTJChartEvent() {
    Analytics_config().event('추천_뷰__TJ_인기차트', {});
  }

  // !event: 추천_뷰__금영_인기차트
  void clickKYChartEvent() {
    Analytics_config().event('추천_뷰__금영_인기차트', {});
  }

  // !event: 추천_뷰__올타임_레전드
  void clickAllTimeLegendRecommendationEvent() {
    Analytics_config().event('추천_뷰__올타임_레전드', {});
  }

  // !event: 추천_뷰__여심저격
  void clickLoveRecommendationEvent() {
    Analytics_config().event('추천_뷰__여심저격', {});
  }

  // !event: 추천_뷰__커플끼리
  void clickCoupleRecommendationEvent() {
    Analytics_config().event('추천_뷰__커플끼리', {});
  }

  // !event: 추천_뷰__분위기UP
  void clickTensionUpRecommendationEvent() {
    Analytics_config().event('추천_뷰__분위기UP', {});
  }

  // !event: 추천_뷰__지치고힘들때
  void clickTiredRecommendationEvent() {
    Analytics_config().event('추천_뷰__지치고힘들때', {});
  }

  // !event: 추천_뷰__비올때
  void clickRainRecommendationEvent() {
    Analytics_config().event('추천_뷰__비올때', {});
  }

  // !event: 추천_뷰__발라드
  void clickBalladRecommendationEvent() {
    Analytics_config().event('추천_뷰__발라드', {});
  }

  // !event: 추천_뷰__힙합
  void clickHipHopRecommendationEvent() {
    Analytics_config().event('추천_뷰__힙합', {});
  }

  // !event: 추천_뷰__알앤비
  void clickRnbRecommendationEvent() {
    Analytics_config().event('추천_뷰__알앤비', {});
  }

  // !event: 추천_뷰__팝
  void clickPopRecommendationEvent() {
    Analytics_config().event('추천_뷰__팝', {});
  }

  // !event: 추천_뷰__만화주제가
  void clickCarttonRecommendationEvent() {
    Analytics_config().event('추천_뷰__만화주제가', {});
  }

  // !event: 추천_뷰__JPOP
  void clickJPOPRecommendationEvent() {
    Analytics_config().event('추천_뷰__JPOP', {});
  }

  // !event: 추천_뷰__남성고음
  void clickManHighRecommendationEvent() {
    Analytics_config().event('추천_뷰__남성고음', {});
  }

  // !event: 추천_뷰__여성고음
  void clickFemaleHighRecommendationEvent() {
    Analytics_config().event('추천_뷰__여성고음', {});
  }

  // !event: 추천_뷰__남성저음
  void clickManLowRecommendationEvent() {
    Analytics_config().event('추천_뷰__남성저음', {});
  }

  // !event: 추천_뷰__여성저음
  void clickFemaleLowRecommendationEvent() {
    Analytics_config().event('추천_뷰__여성저음', {});
  }

  // !event: 추천_뷰__봄
  void clickSpringRecommendationEvent() {
    Analytics_config().event('추천_뷰__봄', {});
  }

  // !event: 추천_뷰__여름
  void clickSummerRecommendationdEvent() {
    Analytics_config().event('추천_뷰__여름', {});
  }

  // !event: 추천_뷰__가을
  void clickFallRecommendationEvent() {
    Analytics_config().event('추천_뷰__가을', {});
  }

  // !event: 추천_뷰__겨울
  void clickWinterRecommendationEvent() {
    Analytics_config().event('추천_뷰__올타임_겨울', {});
  }

  //!event: 네비게이션__검색탭
  void clicksearchTapEvent() {
    Analytics_config().event('네비게이션__검색탭', {});
  }

  // !event: 네비게이션__추천탭
  void clickRecommendationTapEvent() {
    Analytics_config().event('네비게이션__추천탭', {});
  }

  // !event: 일반_검색_뷰__노래_유튜브
  void clickYoutubeButtonOnSearchView() {
    Analytics_config().event('일반_검색_뷰__노래_유튜브', {});
  }

  // !event: 추천_뷰__페이지뷰
  void recommendationPageVeiwEvent() {
    Analytics_config().event('추천_뷰__페이지뷰', {});
  }

  // !event: 추천_뷰__음역대_측정
  void clickRecommendationPitchDetectionButtonEvent() {
    Analytics_config().event('추천_뷰__음역대_측정', {});
  }

  // !event: 추천_뷰__맞춤_추천_더보기
  void clickCustomizeRecommendationButtonEvent() {
    Analytics_config().event('추천_뷰__맞춤_추천_더보기', {});
  }

  // !event: 추천_뷰__맞춤_추천_리스트_아이템_클릭
  void clickCustomizeRecommendationListItemEvent() {
    Analytics_config().event('추천_뷰__맞춤_추천_리스트_아이템_클릭', {});
  }

  // !event: 추천_뷰__TJ인기차트
  void clickTJChartEvent() {
    Analytics_config().event('추천_뷰__TJ_인기차트', {});
  }

  // !event: 추천_뷰__금영_인기차트
  void clickKYChartEvent() {
    Analytics_config().event('추천_뷰__금영_인기차트', {});
  }

  // !event: 추천_뷰__올타임_레전드
  void clickAllTimeLegendRecommendationEvent() {
    Analytics_config().event('추천_뷰__올타임_레전드', {});
  }

  // !event: 추천_뷰__여심저격
  void clickLoveRecommendationEvent() {
    Analytics_config().event('추천_뷰__여심저격', {});
  }

  // !event: 추천_뷰__커플끼리
  void clickCoupleRecommendationEvent() {
    Analytics_config().event('추천_뷰__커플끼리', {});
  }

  // !event: 추천_뷰__분위기UP
  void clickTensionUpRecommendationEvent() {
    Analytics_config().event('추천_뷰__분위기UP', {});
  }

  // !event: 추천_뷰__지치고힘들때
  void clickTiredRecommendationEvent() {
    Analytics_config().event('추천_뷰__지치고힘들때', {});
  }

  // !event: 추천_뷰__비올때
  void clickRainRecommendationEvent() {
    Analytics_config().event('추천_뷰__비올때', {});
  }

  // !event: 추천_뷰__발라드
  void clickBalladRecommendationEvent() {
    Analytics_config().event('추천_뷰__발라드', {});
  }

  // !event: 추천_뷰__힙합
  void clickHipHopRecommendationEvent() {
    Analytics_config().event('추천_뷰__힙합', {});
  }

  // !event: 추천_뷰__알앤비
  void clickRnbRecommendationEvent() {
    Analytics_config().event('추천_뷰__알앤비', {});
  }

  // !event: 추천_뷰__팝
  void clickPopRecommendationEvent() {
    Analytics_config().event('추천_뷰__팝', {});
  }

  // !event: 추천_뷰__만화주제가
  void clickCarttonRecommendationEvent() {
    Analytics_config().event('추천_뷰__만화주제가', {});
  }

  // !event: 추천_뷰__JPOP
  void clickJPOPRecommendationEvent() {
    Analytics_config().event('추천_뷰__JPOP', {});
  }

  // !event: 추천_뷰__남성고음
  void clickManHighRecommendationEvent() {
    Analytics_config().event('추천_뷰__남성고음', {});
  }

  // !event: 추천_뷰__여성고음
  void clickFemaleHighRecommendationEvent() {
    Analytics_config().event('추천_뷰__여성고음', {});
  }

  // !event: 추천_뷰__남성저음
  void clickManLowRecommendationEvent() {
    Analytics_config().event('추천_뷰__남성저음', {});
  }

  // !event: 추천_뷰__여성저음
  void clickFemaleLowRecommendationEvent() {
    Analytics_config().event('추천_뷰__여성저음', {});
  }

  // !event: 추천_뷰__봄
  void clickSpringRecommendationEvent() {
    Analytics_config().event('추천_뷰__봄', {});
  }

  // !event: 추천_뷰__여름
  void clickSummerRecommendationdEvent() {
    Analytics_config().event('추천_뷰__여름', {});
  }

  // !event: 추천_뷰__가을
  void clickFallRecommendationEvent() {
    Analytics_config().event('추천_뷰__가을', {});
  }

  // !event: 추천_뷰__겨울
  void clickWinterRecommendationEvent() {
    Analytics_config().event('추천_뷰__올타임_겨울', {});
  }
}
