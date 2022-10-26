import 'dart:convert';
import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/post.dart';
import 'package:conopot/screens/feed/feed_detail_screen.dart';
import 'package:conopot/screens/feed/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PostListView extends StatefulWidget {
  final FeedScrrenController controller;
  PostListView({super.key, required this.controller});

  @override
  State<PostListView> createState() => _PostListViewState(controller);
}

class _PostListViewState extends State<PostListView> {
  double defaultSize = SizeConfig.defaultSize;
  int _lastPostId = 0;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  List<Post> _posts = [];
  int _option = 1; // 인기 or 최신
  late ScrollController _controller;
  int userId = 0;

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

  _PostListViewState(FeedScrrenController _controller) {
    _controller.lastPostId = _lastPostId;
    _controller.loadMore = _loadMore;
  }

  @override
  void initState() {
    super.initState();
    userId = Provider.of<NoteData>(context, listen: false).userId;
    _firstLoad(_option);
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.maxScrollExtent ==
            _controller.position.pixels) {
          _loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = _posts.map(
      (e) {
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FeedDetailScreen(
                          post: _posts[_posts.indexOf(e)],
                        )));
            if (result == 1) {
              _posts[_posts.indexOf(e)].postLikeCount += 1;
              setState(() {});
            } else if (result == -1) {
              _posts[_posts.indexOf(e)].postLikeCount -= 1;
              setState(() {});
            }
          },
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultSize * 1.2),
                  child: Row(children: [
                    (_posts[_posts.indexOf(e)].userImage == null)
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
                                    _posts[_posts.indexOf(e)].userImage!,
                                    fit: BoxFit.cover))),
                    SizedBox(width: defaultSize * 0.5),
                    Expanded(
                      child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(children: [
                            TextSpan(
                                text: "${_posts[_posts.indexOf(e)].userName}",
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
                                  "${_emotionList[_posts[_posts.indexOf(e)].postIconId]}",
                                  style: TextStyle(fontSize: defaultSize * 3)),
                              SizedBox(width: defaultSize),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_posts[_posts.indexOf(e)].postTitle,
                                        style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.4,
                                            overflow: TextOverflow.ellipsis)),
                                    SizedBox(height: defaultSize * 0.25),
                                    Text(
                                      _posts[_posts.indexOf(e)]
                                                  .postSubscription ==
                                              null
                                          ? ""
                                          : _posts[_posts.indexOf(e)]
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
                            margin: EdgeInsets.only(left: defaultSize * 0.5),
                            child: Row(
                              children: [
                                Icon(Icons.favorite,
                                    color: kMainColor, size: defaultSize * 1.8),
                                SizedBox(width: defaultSize * 0.5),
                                Text(
                                  "${_posts[_posts.indexOf(e)].postLikeCount}",
                                  style: TextStyle(
                                      color: kMainColor,
                                      fontSize: defaultSize * 1.3),
                                ),
                                Spacer(),
                                Text(
                                    "${_posts[_posts.indexOf(e)].postMusicList.length}개의 노래",
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
        );
      },
    ).toList();
    if (_isLoadMoreRunning == true)
      items.add(
        GestureDetector(
          onTap: () {},
          child: Center(
              child: SpinKitFadingCircle(
            color: kPrimaryWhiteColor,
            size: defaultSize * 3,
          )),
        ),
      );
    if (_hasNextPage == false && _isFirstLoadRunning == false)
      items.add(GestureDetector(
        onTap: () {},
        child: Center(
          child: Text(
            "더 이상 게시물이 없습니다.",
            style: TextStyle(color: kPrimaryLightWhiteColor),
          ),
        ),
      ));
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(right: defaultSize),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    if (_option == 2) {
                      _hasNextPage = true;
                      _option = 1;
                      _posts = [];
                      _lastPostId = 0;
                      _firstLoad(_option);
                    }
                  });
                },
                child: _option == 1
                    ? Container(
                        padding: EdgeInsets.fromLTRB(defaultSize,
                            defaultSize * 0.5, defaultSize, defaultSize * 0.5),
                        decoration: BoxDecoration(
                            color: kMainColor.withOpacity(0.9),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Text(
                          "인기",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.fromLTRB(defaultSize,
                            defaultSize * 0.5, defaultSize, defaultSize * 0.5),
                        child: Text(
                          "인기",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              SizedBox(
                width: defaultSize * 0.5,
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    if (_option == 1) {
                      _hasNextPage = true;
                      _option = 2;
                      _posts = [];
                      _lastPostId = 0;
                      _firstLoad(_option);
                    }
                  });
                },
                child: _option == 2
                    ? Container(
                        padding: EdgeInsets.fromLTRB(defaultSize,
                            defaultSize * 0.5, defaultSize, defaultSize * 0.5),
                        decoration: BoxDecoration(
                            color: kMainColor.withOpacity(0.9),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Text(
                          "최신",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.fromLTRB(defaultSize,
                            defaultSize * 0.5, defaultSize, defaultSize * 0.5),
                        child: Text(
                          "최신",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
            ],
          ),
        ),
        SizedBox(height: defaultSize * 1.5),
        ListView(
          padding: EdgeInsets.only(bottom: SizeConfig.screenHeight * 0.1),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          controller: _controller,
          children: items,
        ),
      ],
    );
  }

  // 최초로 인기 게시물을 불러오는 함수
  void _firstLoad(int option) async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      String? serverURL = dotenv.env['USER_SERVER_URL'];
      // option = 1 인기순, option = 2 최신순
      String URL = (option == 1)
          ? '${serverURL}/post/sort/famous?postId=${_lastPostId}&userId=${userId}'
          : '${serverURL}/post/sort/latest?postId=${_lastPostId}&userId=${userId}';
      final response = await http.get(
        Uri.parse(URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      setState(() {
        if (data['lastPostId'] != null) {
          _lastPostId = data['lastPostId'];
        }
        for (var e in data['posts']) {
          _posts.add(Post.fromJson(e));
        }
        _isFirstLoadRunning = false;
      });
    } on SocketException catch (e) {
      // 에러처리 (인터넷 연결 등등)
      EasyLoading.showToast("인터넷 연결을 확인해주세요");
    }
  }

  // 추가적인 게시물을 불러오는 함수
  void _loadMore() async {
    if (_isFirstLoadRunning == true ||
        _isLoadMoreRunning == true ||
        _hasNextPage == false) return;

    setState(() {
      // api 호출시 List Veiew의 하단에 Loading Indicator를 띄운다.
      _isLoadMoreRunning = true;
    });
    try {
      String? serverURL = dotenv.env['USER_SERVER_URL'];
      String URL = (_option == 1)
          ? '${serverURL}/post/sort/famous?postId=${_lastPostId}&userId=${userId}'
          : '${serverURL}/post/sort/latest?postId=${_lastPostId}&userId=${userId}';
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
        });
      }
    } catch (err) {
      // 에러 처리 (인터넷 연결 에러 등등)
    }
    setState(() {
      _isLoadMoreRunning = false;
    });
  }
}
