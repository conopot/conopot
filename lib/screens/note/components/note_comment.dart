import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/comment.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteComment extends StatefulWidget {
  final int musicId;
  NoteComment({super.key, required this.musicId});

  @override
  State<NoteComment> createState() => _NoteCommentState();
}

class _NoteCommentState extends State<NoteComment> {
  TextEditingController _controller = TextEditingController();
  bool isAnonymous = true;
  bool isLoading = true;
  String content = "";
  late var userId;

  List<Comment> _comments = [];

  @override
  void initState() {
    userId = Provider.of<NoteData>(context, listen: false).userId;
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    var items = _comments.map((e) {
      return commentWidget(e);
    }).toList();
    return Column(
      children: [
        Expanded(
            child: ListView(
                children: (isLoading)
                    ? [Text("로딩중", style: TextStyle(color: kPrimaryWhiteColor))]
                    : (_comments.isEmpty)
                        ? items
                        : items)),
        Container(
          height: defaultSize * 5,
          margin: EdgeInsets.symmetric(horizontal: defaultSize),
          padding:
              EdgeInsets.fromLTRB(defaultSize * 1.5, 0, defaultSize * 1.5, 0),
          decoration: BoxDecoration(
              color: kPrimaryGreyColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: kPrimaryLightGreyColor,
                ),
                child: SizedBox(
                  width: defaultSize * 2,
                  height: defaultSize * 2,
                  child: Checkbox(
                      checkColor: kPrimaryBlackColor,
                      activeColor: kMainColor,
                      value: isAnonymous,
                      onChanged: (bool? value) {
                        setState(() {
                          isAnonymous = value!;
                        });
                      }),
                ),
              ),
              SizedBox(width: defaultSize * 0.5),
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize * 0.3),
                child: Text(
                  "익명",
                  style: TextStyle(
                      color:
                          (isAnonymous) ? kMainColor : kPrimaryLightGreyColor,
                      fontSize: defaultSize * 1.3,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: defaultSize),
              Expanded(
                child: TextFormField(
                  style: TextStyle(color: kPrimaryWhiteColor),
                  onChanged: (text) => {
                    setState(() {
                      content = text;
                    })
                  },
                  controller: _controller,
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.multiline,
                  maxLength: 100,
                  cursorColor: kMainColor,
                  decoration: InputDecoration(
                    counter: SizedBox.shrink(),
                    hintText: '댓글을 입력하세요.',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: defaultSize * 1.3,
                      color: kPrimaryLightGreyColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(width: defaultSize),
              GestureDetector(
                  onTap: () {
                    if (content.isNotEmpty) {
                      leaveComment();
                      setState(() {
                        _controller.text = "";
                        content = "";
                      });
                      FocusScope.of(context).requestFocus(new FocusNode());
                      EasyLoading.show();
                      Timer(const Duration(seconds: 2), () {
                        setState(() {
                          load();
                          EasyLoading.dismiss();
                        });
                      });
                    }
                  },
                  child: Icon(Icons.send, color: kMainColor))
            ],
          ),
        ),
      ],
    );
  }

  load() async {
    _comments = [];
    try {
      // String? serverURL = dotenv.env['USER_SERVER_URL'];
      String? serverURL = 'http://10.0.2.2:3000';
      String URL =
          '${serverURL}/comment?userId=${userId}&musicId=${widget.musicId}';
      final response = await http.get(
        Uri.parse(URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      if (!data.containsKey('comments')) throw Exception();
      setState(() {
        if (data['comments'].isNotEmpty) {
          for (var e in data['comments']) {
            _comments.add(Comment.fromJson(e));
          }
        }
        isLoading = false;
      });
      return _comments;
    } on SocketException catch (e) {
      // 에러처리 (인터넷 연결 등등)
      EasyLoading.showToast("인터넷 연결을 확인해주세요.");
    } on Exception catch (e) {
      EasyLoading.showToast("인터넷 연결을 확인해주세요.");
    }
  }

  void leaveComment() async {
    var anoymous = (isAnonymous) ? 1 : 0;
    try {
      // String? serverURL = dotenv.env['USER_SERVER_URL'];
      String? serverURL = 'http://10.0.2.2:3000';
      String URL = '${serverURL}/comment';
      final response = await http.post(
        Uri.parse(URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'musicId': widget.musicId,
          'comment': content,
          'authorId': userId,
          'anonymous': anoymous
        }),
      );
    } on SocketException catch (e) {
      // 에러처리 (인터넷 연결 등등)
      EasyLoading.showToast("인터넷 연결을 확인해주세요.");
    } on Exception catch (e) {
      EasyLoading.showToast("인터넷 연결을 확인해주세요.");
    }
  }

  // Widget emptyCommentScreen() {
    
  // }

  Widget commentWidget(Comment comment) {
    double defaultSize = SizeConfig.defaultSize;
    return Container(
      margin: EdgeInsets.fromLTRB(defaultSize, 0, defaultSize, defaultSize),
      decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Container(
        margin: EdgeInsets.all(defaultSize * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                (comment.authorImage == null)
                    ? Container(
                        width: defaultSize * 3,
                        height: defaultSize * 3,
                        child: Image.asset("assets/images/profile.png"),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                            width: defaultSize * 3,
                            height: defaultSize * 3,
                            child: Image.network(comment.authorImage!,
                                fit: BoxFit.cover))),
                SizedBox(width: defaultSize * 0.5),
                Expanded(
                  child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "${comment.authorName}",
                            style: TextStyle(
                              fontSize: defaultSize * 1.3,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryWhiteColor,
                            )),
                      ])),
                ),
                Container(
                  padding: EdgeInsets.all(defaultSize * 0.5),
                  decoration: BoxDecoration(
                      color: kPrimaryGreyColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Icon(
                      Icons.favorite,
                      color: kMainColor,
                      size: defaultSize * 1.5,
                    ),
                    Container(
                        height: defaultSize * 1.5,
                        child: VerticalDivider(
                          color: kMainColor,
                          thickness: 2,
                        )),
                    Icon(Icons.more_vert,
                        color: kMainColor, size: defaultSize * 1.5)
                  ]),
                )
              ],
            ),
            SizedBox(
              height: defaultSize * 0.8,
            ),
            Padding(
              padding: EdgeInsets.only(left: defaultSize * 0.2),
              child: Text("${comment.commentText.trim()}",
                  maxLines: null,
                  style: TextStyle(
                      color: kPrimaryLightWhiteColor,
                      fontSize: defaultSize * 1.4)),
            ),
            SizedBox(height: defaultSize * 0.8),
            Row(
              children: [
                Icon(Icons.favorite,
                    color: kMainColor, size: defaultSize * 1.4),
                SizedBox(width: defaultSize * 0.5),
                Text(
                  "${comment.commentLikeCount}",
                  style:
                      TextStyle(color: kMainColor, fontSize: defaultSize * 1.3),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
