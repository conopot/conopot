import 'dart:convert';
import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// 맞춤 추천 상세페이지
class CustomizeRecommendationDetailScreen extends StatefulWidget {
  late String title;
  late List<FitchMusic> songList = [];
  late MusicSearchItemLists musicList;

  CustomizeRecommendationDetailScreen(
      {Key? key,
      required this.musicList,
      required this.title,
      required this.songList})
      : super(key: key);
  @override
  State<CustomizeRecommendationDetailScreen> createState() =>
      _CustomizeRecommendationDetailScreenState();
}

class _CustomizeRecommendationDetailScreenState
    extends State<CustomizeRecommendationDetailScreen> {
  final storage = new FlutterSecureStorage();
  double defaultSize = SizeConfig.defaultSize;

  bool isLoaded1 = false, isLoaded2 = false;

  Map<String, String> Search_Native_UNIT_ID_ODD = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-7139143792782560/3104068385',
          'ios': 'ca-app-pub-7139143792782560/5971824166',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/2247696110',
          'ios': 'ca-app-pub-3940256099942544/3986624511',
        };

  Map<String, String> Search_Native_UNIT_ID_EVEN = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-7139143792782560/3200544377',
          'ios': 'ca-app-pub-7139143792782560/9111358943',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/2247696110',
          'ios': 'ca-app-pub-3940256099942544/3986624511',
        };

  // Native 광고 위치
  static final _kAdIndex = 15;
  // TODO: Add a native ad instance
  NativeAd? _ad_odd, _ad_even;

  // TODO: Add _getDestinationItemIndex()
  int _getDestinationItemIndex(int rawIndex) {
    // native 광고 index가 포함되어 있기 때문에, 그 이후 인덱스는 -1씩 줄여줘야 한다.
    if (isLoaded1 == true && isLoaded2 == true) {
      return rawIndex - 1 - (rawIndex ~/ _kAdIndex);
    }
    return rawIndex;
  }

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

  createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AI_Recommand_Interstitial_UNIT_ID[
            Platform.isIOS ? 'ios' : 'android']!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
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
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void requestCFApi() async {
    widget.musicList.recommendRequest = true;
    storage.write(key: "recommendRequest", value: 'true');
    await EasyLoading.show(status: '분석중 입니다...');
    String url = 'https://recommendcf-pfenq2lbpq-du.a.run.app/recommendCF';
    List<String> musicArr =
        Provider.of<NoteData>(context, listen: false).userMusics;
    if (musicArr.length > 20) {
      // 저장한 노트수가 20개 보다 많은 경우 자르기
      musicArr = musicArr.sublist(0, 20);
    }
    Future<dynamic> myFuture = new Future(() async {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"musicArr": musicArr.toString()}),
      );
      return response;
    });
    myFuture.then((response) {
      if (response.statusCode == 200) {
        String? recommendList = response.body;
        if (recommendList != null) {
          widget.musicList.saveAiRecommendationList(recommendList);
          setState(() {});
          EasyLoading.showSuccess('분석에 성공했습니다!');
        } else {
          setState(() {});
          EasyLoading.showError('분석을 위한 데이터가 부족합니다😿\n노트를 좀더 추가해주세요');
        }
      } else {
        setState(() {});
        EasyLoading.showError('서버 문제가 발생했습니다😿\n채널톡에 문의해주세요');
      }
    }, onError: (e) {
      setState(() {});
      EasyLoading.showError('분석에 실패했습니다😿\n인터넷 연결을 확인해 주세요');
    });
  }

  Widget nativeAdWidget(int idx) {
    return Container(
      height: 80.0,
      margin:
          EdgeInsets.fromLTRB(defaultSize, 0, defaultSize, defaultSize * 0.5),
      decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: AdWidget(
        ad: (idx % 2 == 0) ? _ad_even! : _ad_odd!,
      ),
    );
  }

  @override
  void initState() {
    _interstitialAd = createInterstitialAd();
    super.initState();
    // TODO: Create a NativeAd instance
    _ad_odd = NativeAd(
      adUnitId: Search_Native_UNIT_ID_ODD[Platform.isIOS ? 'ios' : 'android']!,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad_odd = ad as NativeAd;
            isLoaded1 = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad_even = NativeAd(
      adUnitId: Search_Native_UNIT_ID_EVEN[Platform.isIOS ? 'ios' : 'android']!,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad_even = ad as NativeAd;
            isLoaded2 = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad_odd!.load();
    _ad_even!.load();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenHeight = SizeConfig.screenHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              //!event: 추천_뷰__AI추천_더보기
              Analytics_config().clickReAIRecommendationEvent();
              if (Provider.of<NoteData>(context, listen: false)
                      .userMusics
                      .length <
                  5) {
                EasyLoading.showError('최소 5개 이상의 노트를 추가해 주세요 🙀');
              } else {
                requestCFApi();
                //전면 광고
                bool pitchMeasureInterstitialSetting = Firebase_Remote_Config()
                    .remoteConfig
                    .getBool('pitchMeasureInterstitialSetting');
                if (pitchMeasureInterstitialSetting == true &&
                    _interstitialAd != null) _showInterstitialAd();
              }
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("추천 다시 받기",
                    style: TextStyle(
                        color: kMainColor,
                        fontSize: defaultSize * 1.3,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: screenHeight * 0.3),
          itemCount: widget.songList.length +
              ((isLoaded1 && isLoaded2)
                  ? (widget.songList.length ~/ _kAdIndex) + 1
                  : 0),
          itemBuilder: (context, index) {
            if ((index % _kAdIndex == 0) && (isLoaded1 && isLoaded2)) {
              return Container(
                height: 80.0,
                margin: EdgeInsets.fromLTRB(
                    defaultSize, 0, defaultSize, defaultSize * 0.5),
                decoration: BoxDecoration(
                    color: kPrimaryLightBlackColor,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: nativeAdWidget(index),
              );
            } else {
              String songNumber = widget
                  .songList[_getDestinationItemIndex(index)].tj_songNumber;
              String title =
                  widget.songList[_getDestinationItemIndex(index)].tj_title;
              String singer =
                  widget.songList[_getDestinationItemIndex(index)].tj_singer;
              int pitchNum =
                  widget.songList[_getDestinationItemIndex(index)].pitchNum;

              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Card(
                  margin: EdgeInsets.fromLTRB(
                      defaultSize, 0, defaultSize, defaultSize * 0.5),
                  color: kPrimaryLightBlackColor,
                  elevation: 1,
                  child: ListTile(
                      leading: SizedBox(
                        width: defaultSize * 6.5,
                        child: Center(
                          child: Text(
                            songNumber,
                            style: TextStyle(
                              color: kMainColor,
                              fontSize: defaultSize * 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        singer,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: kPrimaryLightWhiteColor,
                            fontWeight: FontWeight.w300,
                            fontSize: defaultSize * 1.2),
                      ),
                      onTap: () {
                        //!event: 추천_뷰__맞춤_추천_리스트_아이템_클릭
                        Analytics_config()
                            .clickCustomizeRecommendationListItemEvent();
                        Provider.of<NoteData>(context, listen: false)
                            .showAddNoteDialogWithInfo(context,
                                isTj: true,
                                songNumber: songNumber,
                                title: title,
                                singer: singer);
                      }),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a NativeAd object
    _ad_odd?.dispose();
    _ad_even?.dispose();

    super.dispose();
  }
}
