import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/components/post_list.dart';
import 'package:conopot/screens/feed/feed_creation_screen.dart';
import 'package:conopot/screens/feed/feed_search_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class FeedScrrenController {
  late int lastPostId;
  late void Function(int lastPostId) loadMore;
}

class FeedScreen extends StatefulWidget {
  FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late ScrollController _controller;
  final FeedScrrenController feedScrrenController = FeedScrrenController();
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  //AdMob
  Map<String, String> App_Quit_Banner_UNIT_ID = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-7139143792782560/8735916434',
          'ios': 'ca-app-pub-7139143792782560/5121811348',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/6300978111',
          'ios': 'ca-app-pub-3940256099942544/2934735716',
        };

  // TODO: Add _bannerAd
  BannerAd? _bannerAd;

  @override
  void initState() {
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.maxScrollExtent ==
            _controller.position.pixels) {
          feedScrrenController.loadMore(feedScrrenController.lastPostId);
        }
      });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();
  }

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    _anchoredAdaptiveAd = BannerAd(
      // TODO: replace with your own ad unit.
      adUnitId: App_Quit_Banner_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
      size: size!,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      appBar: AppBar(
        title: Text("피드"),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => FeedSearchScrren()));
              },
              icon: Icon(Icons.search))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          Provider.of<NoteData>(context, listen: false).lists = [];
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => CreateFeedScreen()));
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(
              defaultSize, defaultSize * 0.5, defaultSize, defaultSize * 0.5),
          decoration: BoxDecoration(
              color: kMainColor,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: IntrinsicWidth(
            child: Row(
              children: [
                Icon(Icons.library_music, color: kPrimaryWhiteColor),
                SizedBox(width: defaultSize),
                Text(
                  "내 플레이리스트 자랑하기",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 1.3,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(controller: _controller, children: [
          // Container(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       if (_anchoredAdaptiveAd != null && _isLoaded)
          //         Container(
          //           color: Colors.transparent,
          //           width: _anchoredAdaptiveAd!.size.width.toDouble(),
          //           height: _anchoredAdaptiveAd!.size.height.toDouble(),
          //           child: AdWidget(ad: _anchoredAdaptiveAd!),
          //         )
          //     ],
          //   ),
          //   decoration: BoxDecoration(
          //       color: kPrimaryLightBlackColor,
          //       borderRadius: BorderRadius.all(Radius.circular(8))),
          // ),
          SizedBox(height: defaultSize),
          Container(
            padding: EdgeInsets.fromLTRB(
                defaultSize, defaultSize * 1.5, defaultSize, defaultSize * 1.5),
            margin: EdgeInsets.all(defaultSize),
            decoration: BoxDecoration(
                color: kPrimaryLightBlackColor.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "🎤 싱스타그램",
                style: TextStyle(
                    color: kMainColor,
                    fontSize: defaultSize * 1.6,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: defaultSize * 0.5),
              Text(
                "다른 사람들은 노래방에서 어떤 노래를 부를까?",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.5,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: defaultSize * 0.5),
              Text(
                "궁금할 땐 싱스타그램에서 찾아보고 내 플레이리스트도 자랑해보세요!",
                style: TextStyle(
                    color: kPrimaryLightGreyColor, fontSize: defaultSize * 1.3),
              ),
            ]),
          ),
          SizedBox(height: defaultSize),
          PostListView(controller: feedScrrenController)
        ]),
      ),
    );
  }
}
