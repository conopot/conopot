import 'dart:convert';
import 'dart:io';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/debounce.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/post.dart';
import 'package:conopot/screens/feed/feed_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FeedSearchScrren extends StatefulWidget {
  FeedSearchScrren({super.key});

  @override
  State<FeedSearchScrren> createState() => _FeedSearchScrrenState();
}

class _FeedSearchScrrenState extends State<FeedSearchScrren> {
  double defaultSize = SizeConfig.defaultSize;
  final Debounce _debounce = Debounce(delay: Duration(milliseconds: 500));
  List<Post> _posts = [];
  int _lastPostId = 0;
  bool _isLoadMoreRunning = false;
  bool _hasNextPage = true;
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
  late ScrollController _controller;
  String _searchKeyword = "";
  bool _isResult = true;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_hasNextPage == true &&
            _isLoadMoreRunning == false &&
            _controller.position.maxScrollExtent ==
                _controller.position.pixels) {
          load();
        }
      });
    userId = Provider.of<NoteData>(context, listen: false).userId;
  }

  void _clearTextField() {
    _textController.text = "";
    _posts = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: feedSearchBar()),
      body: (!_isResult)
          ? Center(
              child: Text(
                "검색 결과가 없습니다.",
                style: TextStyle(
                    color: kPrimaryWhiteColor, fontSize: defaultSize * 2),
              ),
            )
          : ListView.builder(
              controller: _controller,
              itemCount: _posts.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FeedDetailScreen(
                                post: _posts[index],
                              )));
                  if (result == 1) {
                    _posts[index].postLikeCount += 1;
                    setState(() {});
                  } else if (result == -1) {
                    _posts[index].postLikeCount -= 1;
                    setState(() {});
                  }
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
                                  child:
                                      Image.asset("assets/images/profile.png"),
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
                                        style: TextStyle(
                                            fontSize: defaultSize * 3)),
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
                                            _posts[index].postSubscription ==
                                                    null
                                                ? ""
                                                : _posts[index]
                                                    .postSubscription!
                                                    .trim()
                                                    .replaceAll("\n", " "),
                                            style: TextStyle(
                                                color: kPrimaryLightWhiteColor,
                                                fontSize: defaultSize * 1.2,
                                                overflow:
                                                    TextOverflow.ellipsis),
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
    );
  }

  Widget feedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryLightBlackColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: TextField(
        style: TextStyle(color: kPrimaryWhiteColor),
        onSubmitted: (value) async {
          setState(() {
            _searchKeyword = value;
          });
          load();
        },
        onChanged: ((value) {
          setState(() {
            _isResult = true;
          });
        }),
        controller: _textController,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.text,
        cursorColor: kMainColor,
        decoration: InputDecoration(
          hintText: '검색어 입력 후 확인 버튼을 눌러주세요',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: defaultSize * 1.35,
            color: kPrimaryLightGreyColor,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: kPrimaryWhiteColor,
          ),
          suffixIcon: _textController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _isResult = true;
                      _clearTextField();
                    });
                  },
                  color: kPrimaryWhiteColor,
                ),
        ),
      ),
    );
  }

  void load() async {
    setState(() {
      // api 호출시 List Veiew의 하단에 Loading Indicator를 띄운다.
      _isLoadMoreRunning = true;
    });
    if (_lastPostId == 0) {
      _posts = [];
    }
    try {
      String? serverURL = dotenv.env['USER_SERVER_URL'];
      String URL =
          '${serverURL}/post/search?postId=${_lastPostId}&userId=${userId}&keyword=${_searchKeyword}';
      final response = await http.get(
        Uri.parse(URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      // 새로 받아온 게시물
      final List fetchedPosts = data['posts'];
      if (fetchedPosts.isNotEmpty) {
        setState(() {
          _lastPostId = data['lastPostId'];
          for (var e in fetchedPosts) {
            _posts.add(Post.fromJson(e));
          }
        });
      } else {
        // 게시물이 더 이상 없을 때
        setState(() {
          _hasNextPage = false;
          _isResult = false;
        });
      }
    } on SocketException {
      // 에러 처리 (인터넷 연결 에러 등등)
      EasyLoading.showToast("인터넷 연결을 확인해주세요.");
    }
    setState(() {
      _isLoadMoreRunning = false;
    });
  }
}
