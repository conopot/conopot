import 'dart:convert';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/debounce.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/post.dart';
import 'package:conopot/screens/feed/feed_detail_screen.dart';
import 'package:flutter/material.dart';
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
  var _emotionList = ["😀", "🥲", "😡", "😳", "🫠"];
  int userId = 0;
  late ScrollController _controller;
  String _searchKeyword = "";
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
      body: (_posts.isEmpty)
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FeedDetailScreen(
                                post: _posts[index],
                              )));
                },
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicWidth(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: defaultSize * 1.2),
                          child: Row(children: [
                            (_posts[index].userImage == null)
                                ? Container(
                                    width: defaultSize * 2.8,
                                    height: defaultSize * 2.8,
                                    child: SvgPicture.asset(
                                        "assets/icons/profile.svg"),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: SizedBox(
                                        width: defaultSize * 2.8,
                                        height: defaultSize * 2.8,
                                        child: Image.network(
                                            _posts[index].userImage!,
                                            fit: BoxFit.cover))),
                            SizedBox(width: defaultSize * 0.5),
                            Text(
                              "${_posts[index].userName}",
                              style: TextStyle(color: kPrimaryWhiteColor),
                            ),
                            Text("님의 노래방")
                          ]),
                        ),
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_posts[index].postTitle,
                                            style: TextStyle(
                                                color: kPrimaryWhiteColor,
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        SizedBox(height: defaultSize * 0.25),
                                        Text(
                                          _posts[index].postSubscription == null
                                              ? ""
                                              : _posts[index].postSubscription,
                                          style: TextStyle(
                                              color: kPrimaryWhiteColor,
                                              overflow: TextOverflow.ellipsis),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(height: defaultSize),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: defaultSize * 0.5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.favorite, color: kMainColor),
                                      SizedBox(width: defaultSize * 0.5),
                                      Text(
                                        "${_posts[index].postLikeCount}",
                                        style: TextStyle(color: kMainColor),
                                      ),
                                      Spacer(),
                                      Text(
                                          "${_posts[index].postMusicList.length}개의 노래",
                                          style: TextStyle(
                                              color: kPrimaryLightGreyColor))
                                    ],
                                  ),
                                )
                              ]),
                        ),
                      ),
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
        controller: _textController,
        enableInteractiveSelection: false,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.name,
        cursorColor: kMainColor,
        decoration: InputDecoration(
          hintText: '검색어 입력 후 엔터(↵)를 눌러주세요',
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
      String URL =
          'http://10.0.2.2:3000/post/search?postId=${_lastPostId}&userId=${userId}&keyword=${_searchKeyword}';
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
