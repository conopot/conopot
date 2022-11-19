import 'dart:convert';
import 'dart:io';
import 'package:conopot/screens/user/user_feed_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class UserSharePlaylistScreen extends StatefulWidget {
  UserSharePlaylistScreen({super.key});

  @override
  State<UserSharePlaylistScreen> createState() =>
      _UserSharePlaylistScreenState();
}

class _UserSharePlaylistScreenState extends State<UserSharePlaylistScreen> {
  bool _isLoading = false;
  List<Post> _posts = [];
  var _emotionList = [
    "😀",
    "🥲",
    "😡",
    "😳",
    "😎",
    "🎤",
    "🎁",
    "🧸",
    "🎧",
    "💌"
  ];
  int userId = 0;
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  Widget adaptiveAdShow() {
    return (Provider.of<NoteData>(context, listen: false).isUserAdRemove() ==
            true) //리워드 효과 시
        ? SizedBox.shrink()
        //광고를 불러온 경우
        : (_anchoredAdaptiveAd != null && _isLoaded)
            ? Container(
                color: Colors.transparent,
                width: _anchoredAdaptiveAd!.size.width.toDouble(),
                height: _anchoredAdaptiveAd!.size.height.toDouble(),
                child: AdWidget(ad: _anchoredAdaptiveAd!),
              )
            //광고를 불러오지 못한 경우
            : Container(
                color: Colors.transparent,
                width: Provider.of<NoteData>(context, listen: false)
                    .size!
                    .width
                    .toDouble(),
                height: Provider.of<NoteData>(context, listen: false)
                    .size!
                    .height
                    .toDouble(),
                child: SizedBox(),
              );
  }

  @override
  void initState() {
    Provider.of<NoteData>(context, listen: false).isUserRewarded();
    userId = Provider.of<NoteData>(context, listen: false).userId;
    _firstLoad();
    super.initState();
  }

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<NoteData>(context, listen: false).isUserAdRemove() == false)
      _loadAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // TODO: Dispose a BannerAd object
    _anchoredAdaptiveAd?.dispose();
  }

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: App_Quit_Banner_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
      size: size!,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
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
          title: Text("내가 공유한 플레이리스트",
              style: TextStyle(color: kPrimaryWhiteColor)),
          centerTitle: false),
      body: ListView(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [adaptiveAdShow()],
            ),
            decoration: BoxDecoration(
                color: kPrimaryLightBlackColor,
                borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
          SizedBox(height: defaultSize),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _posts.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => UserFeedDetailScreen(
                              post: _posts[index],
                            ))).then((value) {
                  _posts = [];
                  _firstLoad();
                  setState(() {});
                });
              },
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultSize * 1.2),
                      child: Row(children: [
                        (_posts[index].userImage == null)
                            ? Container(
                                width: defaultSize * 3.5,
                                height: defaultSize * 3.5,
                                child: Image.asset("assets/images/profile.png"),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: SizedBox(
                                    width: defaultSize * 3.5,
                                    height: defaultSize * 3.5,
                                    child: Image.network(
                                        _posts[index].userImage!,
                                        fit: BoxFit.cover))),
                        SizedBox(width: defaultSize * 0.5),
                        Expanded(
                          child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "${_posts[index].userName}",
                                    style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                    )),
                                TextSpan(
                                    text: "님의 노래방 플레이리스트",
                                    style: TextStyle(
                                      color: kPrimaryLightGreyColor,
                                    )),
                              ])),
                        ),
                        Icon(Icons.chevron_right, color: kPrimaryWhiteColor)
                      ]),
                    ),
                    SizedBox(height: defaultSize),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          defaultSize, 0, defaultSize, defaultSize),
                      padding: EdgeInsets.all(defaultSize * 1.5),
                      decoration: BoxDecoration(
                          color: kPrimaryLightBlackColor,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: IntrinsicHeight(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: defaultSize),
                              Row(
                                children: [
                                  Text(
                                      "${_emotionList[_posts[index].postIconId]}",
                                      style:
                                          TextStyle(fontSize: defaultSize * 3)),
                                  SizedBox(width: defaultSize),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_posts[index].postTitle,
                                            style: TextStyle(
                                                color: kPrimaryWhiteColor,
                                                fontSize: defaultSize * 1.4,
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        SizedBox(height: defaultSize * 0.25),
                                        Text(
                                          _posts[index].postSubscription == null
                                              ? ""
                                              : _posts[index]
                                                  .postSubscription
                                                  .trim()
                                                  .replaceAll("\n", " "),
                                          style: TextStyle(
                                              color: kPrimaryLightWhiteColor,
                                              fontSize: defaultSize * 1.2,
                                              overflow: TextOverflow.ellipsis),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: defaultSize),
                              Container(
                                margin:
                                    EdgeInsets.only(left: defaultSize * 0.5),
                                child: Row(
                                  children: [
                                    Icon(Icons.favorite,
                                        color: kMainColor,
                                        size: defaultSize * 1.8),
                                    SizedBox(width: defaultSize * 0.5),
                                    Text(
                                      "${_posts[index].postLikeCount}",
                                      style: TextStyle(
                                          color: kMainColor,
                                          fontSize: defaultSize * 1.3),
                                    ),
                                    Spacer(),
                                    Text(
                                        "${_posts[index].postMusicList.length}개의 노래",
                                        style: TextStyle(
                                            fontSize: defaultSize * 1.3,
                                            color: kPrimaryLightGreyColor))
                                  ],
                                ),
                              )
                            ]),
                      ),
                    ),
                    SizedBox(height: defaultSize * 0.5)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _firstLoad() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? serverURL = dotenv.env['USER_SERVER_URL'];
      String URL = '${serverURL}/playlist/mylist?userId=${userId}';
      final response = await http.get(
        Uri.parse(URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      setState(() {
        for (var e in data['posts']) {
          _posts.add(Post.fromJson(e));
        }
      });
    } on SocketException {
      // 에러처리 (인터넷 연결 등등)
      EasyLoading.showToast("인터넷 연결을 확인해주세요");
    }
    setState(() {
      _isLoading = false;
    });
  }
}
