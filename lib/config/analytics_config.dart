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

  //set user properties
  void userProps(Identify identify) {
    analytics.identify(identify);
  }

  // sending events
  void event(String eventName, Map<String, dynamic> properties) {
    //Amplitude
    analytics.logEvent(eventName, eventProperties: properties);

    //Google Analytics
    FirebaseAnalytics.instance
        .logEvent(name: eventName, parameters: properties);
  }

  //!event : 애창곡_노트_뷰__페이지뷰
  noteViewPageViewEvent() {
    event('애창곡_노트_뷰__페이지뷰', {});
  }

  //!event : 애창곡_노트_뷰__노트_추가_뷰_진입
  noteViewEnterEvent() {
    event('애창곡_노트_뷰__노트_추가_뷰_진입', {});
  }

  //!event : 애창곡_노트_뷰__노트_상세_정보_조회
  viewNoteEvent(Note note) {
    event('애창곡_노트_뷰__노트_상세_정보_조회', {
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
    event('애창곡_노트_뷰__배너_추천노래', {});
  }

  //!event : 애창곡_노트_뷰__배너_음역대측정
  noteViewBannerMeasureEvent() {
    event('애창곡_노트_뷰__배너_음역대측정', {});
  }

  //!event : 애창곡_노트_뷰__배너_노트설정
  noteViewBannerNoteSettingEvent() {
    event('애창곡_노트_뷰__배너_노트설정', {});
  }

  //!event : 노래검색__검색키워드
  musicSearchKeywordEvent(String keyword) {
    event('노래검색__검색키워드', {'검색_키워드': keyword});
  }

  //!event : 노래검색__가사검색
  musicSearchLyricEvent() {
    event('노래검색__가사검색', {});
  }

  //!event : 노래리스트__노트추가
  musicAddEvent(String songTitle) {
    event('노래리스트__노트추가', {'곡명': songTitle});
  }

  //!event : 일반_검색_뷰__노트추가
  searchViewNoteAddEvent(String title) {
    event('일반_검색_뷰__노트추가', {'곡명': title});
  }

  //!event : 노트_추가_뷰__페이지뷰
  addNotePageView() {
    event('노트_추가_뷰__페이지뷰', {});
  }

  //!event: 노트_추가_뷰__노래선택
  addViewSongClickEvent(String title) {
    event('노트_추가_뷰__노래선택', {'곡명': title});
  }

  //!event: 노트_추가_뷰__노트추가
  addViewSongAddEvent(String title) {
    event('노트_추가_뷰__노트추가', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__페이지뷰
  noteDetailPageView() {
    event('노트_상세정보_뷰__페이지뷰', {});
  }

  //!event: 노트_상세정보_뷰__금영번호찾기
  noteDetailViewFindKY(String tjNumber) {
    event('노트_상세정보_뷰__금영번호찾기', {'tj번호': tjNumber});
  }

  //!event: 노트_상세정보_뷰__유튜브_노래듣기
  noteDetailViewYoutube(String title) {
    event('노트_상세정보_뷰__유튜브_노래듣기', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__메모수정
  noteDetailViewMemo(String title) {
    event('노트_상세정보_뷰__메모수정', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__노트_삭제
  noteDeleteEvent(String title) {
    event('노트_상세정보_뷰__노트_삭제', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__최고음요청
  pitchRequestEvent(String title) {
    event('노트_상세정보_뷰__최고음요청', {'곡명': title});
  }

  //!event: 노트_상세정보_뷰__댓글_페이지뷰
  noteCommentPageView() {
    event('노트_상세정보_뷰__댓글_페이지뷰', {});
  }

  //!event: 노트_상세정보_뷰__댓글남기기
  noteLeaveCommentEvent() {
    event('노트_상세정보_뷰__댓글남기기', {});
  }

  //!event: 노트_상세정보_뷰__댓글좋아요
  noteLikeCommentEvent() {
    event('노트_상세정보_뷰__댓글좋아요', {});
  }

  //!event: 노트_상세정보_뷰__댓글신고하기
  noteReportCommentEvent() {
    event('노트_상세정보_뷰__댓글신고하기', {});
  }

  //!event: 노트_상세정보_뷰__댓글삭제하기
  noteDeleteCommentEvent() {
    event('노트_상세정보_뷰__댓글삭제하기', {});
  }

  //!event: 설정_뷰__페이지뷰
  settingPageView() {
    event('설정_뷰__페이지뷰', {});
  }

  //!event: 설정_뷰__채널톡
  settingChannelTalk() {
    event('설정_뷰__채널톡', {});
  }

  //!event: 애창곡_노트_설정_뷰__페이지뷰
  settingNotePageView() {
    event('애창곡_노트_설정_뷰__페이지뷰', {});
  }

  //!event: 애창곡_노트_설정_뷰__설정아이템
  settingNoteSettingItem(String item) {
    event('애창곡_노트_설정_뷰__설정아이템', {'아이템': item});
  }

  //!event: 음역대_측정_뷰__페이지뷰
  pitchMeasurePageView() {
    event('음역대_측정_뷰__페이지뷰', {});
  }

  //!event: 네비게이션__검색탭
  void clicksearchTapEvent() {
    event('네비게이션__검색탭', {});
  }

  // !event: 네비게이션__추천탭
  void clickRecommendationTapEvent() {
    event('네비게이션__추천탭', {});
  }

  // !event: 네비게이션__내정보탭
  void clickMyTapEvent() {
    event('네비게이션__내정보탭', {});
  }

  // !event: 일반_검색_뷰__노래_유튜브
  void clickYoutubeButtonOnSearchView() {
    event('일반_검색_뷰__노래_유튜브', {});
  }

  // !event: 추천_뷰__페이지뷰
  void recommendationPageVeiwEvent() {
    event('추천_뷰__페이지뷰', {});
  }

  // !event: 추천_뷰__음역대_측정
  void clickRecommendationPitchDetectionButtonEvent() {
    event('추천_뷰__음역대_측정', {});
  }

  // !event: 추천_뷰__맞춤_추천_더보기
  void clickCustomizeRecommendationButtonEvent() {
    event('추천_뷰__맞춤_추천_더보기', {});
  }

  // !event: 추천_뷰__맞춤_추천_리스트_아이템_클릭
  void clickCustomizeRecommendationListItemEvent() {
    event('추천_뷰__맞춤_추천_리스트_아이템_클릭', {});
  }

  // !event: 추천_뷰__TJ인기차트
  void clickTJChartEvent() {
    event('추천_뷰__TJ_인기차트', {});
  }

  // !event: 추천_뷰__금영_인기차트
  void clickKYChartEvent() {
    event('추천_뷰__금영_인기차트', {});
  }

  // !event: 추천_뷰__올타임_레전드
  void clickAllTimeLegendRecommendationEvent() {
    event('추천_뷰__올타임_레전드', {});
  }

  // !event: 추천_뷰__여심저격
  void clickLoveRecommendationEvent() {
    event('추천_뷰__여심저격', {});
  }

  // !event: 추천_뷰__커플끼리
  void clickCoupleRecommendationEvent() {
    event('추천_뷰__커플끼리', {});
  }

  // !event: 추천_뷰__분위기UP
  void clickTensionUpRecommendationEvent() {
    event('추천_뷰__분위기UP', {});
  }

  // !event: 추천_뷰__지치고힘들때
  void clickTiredRecommendationEvent() {
    event('추천_뷰__지치고힘들때', {});
  }

  // !event: 추천_뷰__비올때
  void clickRainRecommendationEvent() {
    event('추천_뷰__비올때', {});
  }

  // !event: 추천_뷰__발라드
  void clickBalladRecommendationEvent() {
    event('추천_뷰__발라드', {});
  }

  // !event: 추천_뷰__일본노래
  void clickJPOPRecommendationEvent() {
    event('추천_뷰__JPOP', {});
  }

  // !event: 추천_뷰__힙합
  void clickHipHopRecommendationEvent() {
    event('추천_뷰__힙합', {});
  }

  // !event: 추천_뷰__알앤비
  void clickRnbRecommendationEvent() {
    event('추천_뷰__알앤비', {});
  }

  // !event: 추천_뷰__팝
  void clickPopRecommendationEvent() {
    event('추천_뷰__팝', {});
  }

  // !event: 추천_뷰__만화주제가
  void clickCarttonRecommendationEvent() {
    event('추천_뷰__만화주제가', {});
  }

  // !event: 추천_뷰__트로트
  void clickOldrecommendationEvent() {
    event('추천_뷰__JPOP', {});
  }

  // !event: 추천_뷰__남성고음
  void clickManHighRecommendationEvent() {
    event('추천_뷰__남성고음', {});
  }

  // !event: 추천_뷰__여성고음
  void clickFemaleHighRecommendationEvent() {
    event('추천_뷰__여성고음', {});
  }

  // !event: 추천_뷰__남성저음
  void clickManLowRecommendationEvent() {
    event('추천_뷰__남성저음', {});
  }

  // !event: 추천_뷰__여성저음
  void clickFemaleLowRecommendationEvent() {
    event('추천_뷰__여성저음', {});
  }

  // !event: 추천_뷰__봄
  void clickSpringRecommendationEvent() {
    event('추천_뷰__봄', {});
  }

  // !event: 추천_뷰__여름
  void clickSummerRecommendationdEvent() {
    event('추천_뷰__여름', {});
  }

  // !event: 추천_뷰__가을
  void clickFallRecommendationEvent() {
    event('추천_뷰__가을', {});
  }

  // !event: 추천_뷰__겨울
  void clickWinterRecommendationEvent() {
    event('추천_뷰__올타임_겨울', {});
  }

  // !event: 추천_뷰__AI추천_더보기
  void clickMoreAIRecommendationEvent() {
    event('추천_뷰__AI추천_더보기', {});
  }

  // !event: 추천_뷰__AI추천받기
  void clickAIRecommendationEvent() {
    event('추천_뷰__AI추천받기', {});
  }

  // !event: 추천_뷰__AI추천다시받기
  void clickReAIRecommendationEvent() {
    event('추천_뷰__AI추천다시받기', {});
  }

  // !event: 추천_뷰__AI추천_노트추가하러가기
  void clickAINoteAddRecommendationEvent() {
    event('추천_뷰__AI추천_노트추가하러가기', {});
  }

  // !event: 리뷰요청_뷰__페이지뷰
  void reviewRequestPageVeiwEvent() {
    event('리뷰요청_뷰__페이지뷰', {});
  }

  // !event: 리뷰요청_뷰__네_좋아요
  void reviewRequestYesButtonEvent() {
    event('리뷰요청_뷰__네_좋아요', {});
  }

  // !event: 리뷰요청_뷰__그냥_그래요
  void reviewRequestNoButtonEvent() {
    event('리뷰요청_뷰__그냥_그래요', {});
  }

  // !event: 스토어연결_뷰__페이지뷰
  void storeRequestPageViewEvent() {
    event('스토어연결_뷰__페이지뷰', {});
  }

  // !event: 스토어연결_뷰__리뷰_남기기
  void storeRequestYesButtonEvent() {
    event('스토어연결_뷰__리뷰_남기기', {});
  }

  // !event: 스토어연결_뷰__다음에요
  void storeRequestNoButtonEvent() {
    event('스토어연결_뷰__다음에요', {});
  }

  // !event: 채널톡연결_뷰__페이지뷰
  void channelTalkRequestPageVeiwnEvent() {
    event('채널톡연결_뷰__페이지뷰', {});
  }

  // !event: 채널톡연결_뷰__1:1_문의하기
  void channelTalkRequestYesButtonEvent() {
    event('채널톡연결_뷰__1:1_문의하기', {});
  }

  // !event: 채널톡연결_뷰__다음에요
  void channelTalkRequestNoButtonEvent() {
    event('채널톡연결_뷰__다음에요', {});
  }

  //!event: 설정_뷰__공지사항
  settingNotice() {
    event('설정_뷰__공지사항', {});
  }

  //!event: 내정보_뷰__백업하기
  backUpNoteEvent() {
    event('내정보_뷰__백업하기', {});
  }

  //!event: 내정보_뷰__가져오기
  loadNoteEvent() {
    event('내정보_뷰__가져오기', {});
  }

  //!event: 내정보_뷰__로그인
  userloginEvent() {
    event('내정보_뷰__로그인', {});
  }

  //!event: 내정보_뷰__로그아웃
  userlogoutEvent() {
    event('내정보_뷰__로그아웃', {});
  }

  //!event: 내정보_뷰__탈퇴하기
  userunregisterEvent() {
    event('내정보_뷰__탈퇴하기', {});
  }

  //!event: 광고__앱오픈_성공
  adAppOpenSuccess() {
    event('광고__앱오픈_성공', {});
  }

  //!event: 광고__앱오픈_실패
  adAppOpenFail() {
    event('광고__앱오픈_실패', {});
  }

  //!event: 광고__종료_배너_성공
  adQuitBannerSuccess() {
    event('광고__종료_배너_성공', {});
  }

  //!event: 광고__종료_배너_실패
  adQuitBannerFail() {
    event('광고__종료_배너_실패', {});
  }

  //!event: 광고__노트추가_전면광고_성공
  adNoteAddInterstitialSuccess() {
    event('광고__노트추가_전면광고_성공', {});
  }

  //!event: 광고__노트추가_전면광고_실패
  adNoteAddInterstitialFail() {
    event('광고__노트추가_전면광고_실패', {});
  }

  //!event: 광고__음역대측정_전면광고_성공
  adPitchInterstitialSuccess() {
    event('광고__음역대측정_전면광고_성공', {});
  }

  //!event: 광고__음역대측정_전면광고_실패
  adPitchInterstitialFail() {
    event('광고__음역대측정_전면광고_실패', {});
  }

  //!event: 광고__AI추천_전면광고_성공
  adAiInterstitialSuccess() {
    event('광고__AI추천_전면광고_성공', {});
  }

  //!event: 광고__AI추천_전면광고_실패
  adAiInterstitialFail() {
    event('광고__AI추천_전면광고_실패', {});
  }

  //!event: 첫세션
  firstSessionEvent() {
    event('첫세션', {});
  }

  //!event: 노트가 없는 사용자
  emptyNoteUserEvent() {
    event('노트없는사용자', {});
  }

  //!event: 네비게이션__피드탭
  feedTabClickEvent() {
    event('네비게이션__피드탭', {});
  }

  //!event: 피드_뷰__페이지뷰
  feedPageView() {
    event('피드_뷰__페이지뷰', {});
  }

  //!event: 피드_뷰__인기순
  feedViewFamous() {
    event('피드_뷰__인기순', {});
  }

  //!event: 피드_뷰__최신순
  feedViewLatest() {
    event('피드_뷰__최신순', {});
  }

  //!event: 피드_뷰__좋아요
  feedViewClickLikeEvent() {
    event('피드_뷰__좋아요', {});
  }

  //!event: 피드_뷰__신고
  feedViewBanEvent() {
    event('피드_뷰__신고', {});
  }

  //!event: 피드_뷰__유저차단
  feedViewUserBlockEvent() {
    event('피드_뷰__유저차단', {});
  }

  //!event: 피드_뷰__애창곡리스트추가
  feedViewAddList() {
    event('피드_뷰__애창곡리스트추가', {});
  }

  //!event: 피드_뷰__애창곡리스트공유하기
  feedViewShare() {
    event('피드_뷰__애창곡리스트공유하기', {});
  }

  //!event: 애창곡_노트_뷰__광고제거
  addRemoveEvent() {
    event('애창곡_노트_뷰__광고제거', {});
  }
}
