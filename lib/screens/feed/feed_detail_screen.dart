import 'dart:convert';
import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:http/http.dart' as http;
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/components/edit_feed_detail_song_list.dart';
import 'package:conopot/screens/feed/components/feed_detail_song_list.dart';
import 'package:conopot/screens/feed/feed_report_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/post.dart';
import 'package:conopot/screens/note/components/youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class FeedDetailScreen extends StatefulWidget {
  Post post;
  FeedDetailScreen({super.key, required this.post});

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  String? videoId;
  int _index = 0;
  bool _like = false; // 좋아요 여부
  int _state = 0;
  int? _userId;
  var _emotionList = ["😀", "🥲", "😡", "😳", "🫠"];
  bool _isEditting = false;
  List<Note> postList = [];
  int _checkCount = 0;

  _indexChange(int index) {
    setState(() {
      _index = index;
      videoId = Provider.of<MusicSearchItemLists>(context, listen: false)
          .youtubeURL[widget.post.postMusicList[_index]];
    });
  }

  _checkCountChange(bool val) {
    setState(() {
      if (val == true)
        _checkCount += 1;
      else
        _checkCount -= 1;
    });
  }

  void initPostList() {
    // tjSongNumber 문자열로 돼 있는 리스트를 Note 배열로 변환
    Set<Note> entireNote =
        Provider.of<MusicSearchItemLists>(context, listen: false).entireNote;
    for (int i = 0; i < widget.post.postMusicList.length; i++) {
      Note note = entireNote.firstWhere(
          (element) => element.tj_songNumber == widget.post.postMusicList[i]);
      bool flag = false;
      postList.add(note);
    }
  }

  @override
  void initState() {
    _userId = Provider.of<NoteData>(context, listen: false).userId;
    getLikeInfo().then((result) {
      setState(() {
        if (result == 'true') {
          _like = true;
        } else {
          _like = false;
        }
      });
    });
    videoId = Provider.of<MusicSearchItemLists>(context, listen: false)
        .youtubeURL[widget.post.postMusicList[_index]];
    super.initState();
    initPostList();
  }

  // 사용자가 좋아요여부 대한 정보를 받아오는 함수
  getLikeInfo() async {
    try {
      String URL =
          'http://10.0.2.2:3000/playlist/heart?userId=${_userId}&postId=${widget.post.postId}';
      final response = await http.get(
        Uri.parse(URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      return response.body;
    } on SocketException {
      // 에러처리 (인터넷 연결 등등)
      EasyLoading.showError("인터넷 연결을 확인해주세요");
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(defaultSize * 0.5),
          decoration: BoxDecoration(
              color: kPrimaryGreyColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Text(
            "${_emotionList[widget.post.postIconId]} ${widget.post.postTitle}",
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leading: BackButton(
          color: kPrimaryLightWhiteColor,
          onPressed: () {
            Navigator.pop(context, _state); //뒤로가기
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                showReportListOption(context);
              },
              icon: Icon(
                Icons.more_vert,
                color: kPrimaryWhiteColor,
              ))
        ],
      ),
      floatingActionButton: (_isEditting == false)
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _checkCount = 0;
                  _isEditting = true;
                  Provider.of<NoteData>(context, listen: false)
                      .initAddFeedSong(widget.post.postMusicList);
                });
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(defaultSize, defaultSize * 0.5,
                    defaultSize, defaultSize * 0.5),
                decoration: BoxDecoration(
                    color: kPrimaryGreyColor,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add, color: kMainColor),
                      SizedBox(width: defaultSize),
                      Text(
                        "내 애창곡 리스트에 추가",
                        style: TextStyle(
                            color: kMainColor, fontSize: defaultSize * 1.3),
                      )
                    ],
                  ),
                ),
              ),
            )
          : IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_checkCount > 0) ...[
                    Text("${_checkCount}개의 곡을 선택했습니다.",
                        style: TextStyle(
                            color: kMainColor, fontSize: defaultSize * 1.3),
                        key: ValueKey(_checkCount))
                  ],
                  SizedBox(height: defaultSize * 0.5),
                  Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2,
                        defaultSize * 0.5, defaultSize * 2, defaultSize * 0.5),
                    decoration: BoxDecoration(
                        color: kPrimaryGreyColor,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: IntrinsicHeight(
                      child: IntrinsicWidth(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _checkCount = postList.length;
                                });
                                Provider.of<NoteData>(context, listen: false)
                                    .checkAllFeedSongs(postList);
                              },
                              child: Column(children: [
                                Icon(Icons.list, color: kMainColor),
                                Text(
                                  "전체 선택",
                                  style: TextStyle(
                                      color: kMainColor,
                                      fontSize: defaultSize * 1.1),
                                )
                              ]),
                            ),
                            SizedBox(width: defaultSize),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _checkCount = 0;
                                });
                                Provider.of<NoteData>(context, listen: false)
                                    .uncheckAllFeedSongs();
                              },
                              child: Column(children: [
                                Icon(Icons.playlist_remove, color: kMainColor),
                                Text(
                                  "전체 해제",
                                  style: TextStyle(
                                      color: kMainColor,
                                      fontSize: defaultSize * 1.1),
                                )
                              ]),
                            ),
                            SizedBox(width: defaultSize),
                            GestureDetector(
                              onTap: () {
                                if (_checkCount > 0) {
                                  Provider.of<NoteData>(context, listen: false)
                                      .addMultipleFeedSongs();
                                }
                              },
                              child: Column(children: [
                                Icon(Icons.list,
                                    color: (_checkCount == 0)
                                        ? kPrimaryLightGreyColor
                                        : kPrimaryWhiteColor),
                                Text(
                                  "추가",
                                  style: TextStyle(
                                    color: (_checkCount == 0)
                                        ? kPrimaryLightGreyColor
                                        : kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.1,
                                  ),
                                )
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(children: [
        if (videoId == null) ...[
          Text(
            "유튜브 영상을 지원하지 않는 노래입니다",
            style: TextStyle(color: kMainColor),
          ),
        ] else ...[
          YoutubeVideoPlayer(videoId: videoId!, key: ValueKey(videoId)),
        ],
        SizedBox(height: defaultSize * 2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultSize),
          child: GestureDetector(
            onTap: () async {
              if (Provider.of<NoteData>(context, listen: false).isLogined ==
                  false) {
                EasyLoading.showToast("로그인 이후 이용가능합니다.");
              } else {
                String URL = "";
                String body = "";
                setState(() {
                  if (_like == false) {
                    _like = true;
                    _state = 1;
                    URL = 'http://10.0.2.2:3000/playlist/heart';
                    body = jsonEncode({
                      "postId": widget.post.postId,
                      "userId":
                          Provider.of<NoteData>(context, listen: false).userId,
                      "postAuthorId": widget.post.postAuthorId,
                      "postTitle": widget.post.postTitle,
                      "username": Provider.of<NoteData>(context, listen: false)
                          .userNickname
                    });
                  } else {
                    _like = false;
                    _state = -1;
                    URL = 'http://10.0.2.2:3000/playlist/hate';
                    body = jsonEncode({
                      "postId": widget.post.postId,
                      "userId":
                          Provider.of<NoteData>(context, listen: false).userId,
                    });
                  }
                });
                try {
                  final response = await http.post(Uri.parse(URL),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: body);
                } on SocketException {
                  // 에러처리 (인터넷 연결 등등)
                  EasyLoading.showToast("인터넷 연결을 확인해주세요.");
                }
              }
            },
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                        width: defaultSize * 4,
                        height: defaultSize * 4,
                        child: Image.network(widget.post.userImage!,
                            fit: BoxFit.cover))),
                SizedBox(width: defaultSize),
                Text("${widget.post.userName}",
                    style: TextStyle(
                        color: kPrimaryLightWhiteColor,
                        fontSize: defaultSize * 1.5),
                    overflow: TextOverflow.ellipsis),
                Spacer(),
                (widget.post.postAuthorId ==
                            Provider.of<NoteData>(context, listen: false)
                                .userId &&
                        _isEditting == false)
                    ? SizedBox.shrink()
                    : (_isEditting == false)
                        ? Row(
                            children: [
                              (_like == true)
                                  ? Icon(Icons.favorite, color: kMainColor)
                                  : Icon(Icons.favorite_border,
                                      color: kMainColor),
                              SizedBox(width: defaultSize * 0.3),
                              Text("좋아요", style: TextStyle(color: kMainColor))
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              //리스트에 추가한 것으로 판단
                              Analytics_config().feedAddPlaylist();
                              setState(() {
                                _isEditting = false;
                              });
                            },
                            child: Text("완료",
                                style: TextStyle(color: kMainColor))),
              ],
            ),
          ),
        ),
        SizedBox(height: defaultSize * 2),
        (_isEditting == false)
            ? FeedDetailSongList(postList: postList, indexChange: _indexChange)
            : EditFeedDetailSongList(
                postList: postList, checkedCountChange: _checkCountChange)
      ]),
    );
  }

  // 신고, 차단 목록 bottom sheet
  showReportListOption(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        backgroundColor: kDialogColor,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
            child: IntrinsicHeight(
              child: Column(children: [
                SizedBox(height: defaultSize),
                Container(
                  height: 5,
                  width: 50,
                  color: kPrimaryLightWhiteColor,
                ),
                SizedBox(height: defaultSize * 3),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FeedReportScreen(post: widget.post),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(width: defaultSize),
                      Text(
                        "신고하기",
                        style: TextStyle(color: kPrimaryWhiteColor),
                      ),
                      Spacer(),
                      Icon(
                        Icons.chevron_right_outlined,
                        color: kPrimaryWhiteColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: defaultSize * 1.8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // 차단하기
                    showBlockDialog(context);
                  },
                  child: Row(
                    children: [
                      SizedBox(width: defaultSize),
                      Text(
                        "차단하기",
                        style: TextStyle(color: kPrimaryWhiteColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: defaultSize * 6.5,
                ),
              ]),
            ),
          );
        });
  }

  // 차단 여부 확인 다이어로그
  void showBlockDialog(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenWidth = SizeConfig.screenWidth;

    Widget cancelButton = Container(
      width: screenWidth * 0.3,
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                side: const BorderSide(width: 0.0),
                borderRadius: BorderRadius.circular(8),
              ))),
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: Text("취소",
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: kMainColor))),
    );

    Widget blockButton = Container(
      width: screenWidth * 0.3,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kMainColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              side: const BorderSide(width: 0.0),
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () async {
          try {
            String URL = 'http://10.0.2.2:3000/playlist/block';
            final response = await http.post(
              Uri.parse(URL),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                "userId": Provider.of<NoteData>(context, listen: false).userId,
                "blockUserId": widget.post.postAuthorId
              }),
            );
          } on SocketException {
            // 에러처리 (인터넷 연결 등등)
            EasyLoading.showError("인터넷 연결을 확인해주세요");
          }
          for (int i = 0; i < 3; i++) Navigator.of(context).pop();
        },
        child: Text("네, 차단할게요", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "${widget.post.userName}님의 모든 게시글을 보지 않으시겠어요?\n피드 목록에서 ${widget.post.userName}님의 게시글이 더는 보이지 않아요.",
            style: TextStyle(
                color: kPrimaryWhiteColor, fontSize: defaultSize * 1.4),
          )
        ]),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        cancelButton,
        blockButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }
}
