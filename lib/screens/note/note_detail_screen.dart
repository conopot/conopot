import 'dart:convert';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/lyric.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/screens/note/components/editable_text_field.dart';
import 'package:conopot/screens/note/components/request_pitch_button.dart';
import 'package:conopot/config/size_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class NoteDetailScreen extends StatefulWidget {
  late Note note;
  NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  double defaultSize = SizeConfig.defaultSize;
  String lyric = "";

  final storage = new FlutterSecureStorage();

  void getLyrics(String songNum) async {
    //인터넷 연결 확인
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      String url =
          'https://880k1orwu8.execute-api.ap-northeast-2.amazonaws.com/default/Conopot_Lyrics?songNum=$songNum';
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          lyric =
              Lyric.fromJson(jsonDecode(utf8.decode(response.bodyBytes))).lyric;
          lyric = lyric.replaceAll('\n\n', '\n');
          //크롤링한 가사가 비어있는 경우
          if (lyric == "") {
            lyric =
                "해당 노래에 대한 가사 정보가 없습니다\n가사 요청은\n내 정보 페이지 하단의 문의하기를 이용해주세요 🙋‍♂️";
          }
        });
      } else {
        setState(() {
          lyric =
              "해당 노래에 대한 가사 정보가 없습니다\n가사 요청은\n내 정보 페이지 하단의 문의하기를 이용해주세요 🙋‍♂️";
        });
      }
    } else {
      setState(() {
        lyric = "인터넷 연결이 필요합니다 🤣\n인터넷이 연결되어있는지 확인해주세요!";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLyrics(widget.note.tj_songNumber);
  }

  bool _willTextOverflow(
      {required String text,
      required double maxWidth,
      required TextStyle style}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenWidth = SizeConfig.screenWidth;
    Analytics_config().noteDetailPageView();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "노트",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.delete_outline_outlined,
                  color: kMainColor,
                )),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: EdgeInsets.all(defaultSize * 1.5),
              margin: EdgeInsets.symmetric(horizontal: defaultSize),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: kPrimaryLightBlackColor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _willTextOverflow(
                                text: '${widget.note.tj_title}',
                                maxWidth: screenWidth * 0.7,
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: defaultSize * 1.7))
                            ? Container(
                                width: double.maxFinite,
                                height: defaultSize * 2.5,
                                child: Marquee(
                                  text: '${widget.note.tj_title}',
                                  style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: defaultSize * 1.7),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 20.0,
                                  pauseAfterRound: Duration(seconds: 10),
                                  startPadding: 0,
                                  accelerationDuration: Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                      Duration(milliseconds: 1000),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              )
                            : Text('${widget.note.tj_title}',
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: defaultSize * 1.7)),
                        SizedBox(height: defaultSize * 0.5),
                        _willTextOverflow(
                                text: '${widget.note.tj_singer}',
                                maxWidth: screenWidth * 0.7,
                                style: TextStyle(
                                    color: kPrimaryLightWhiteColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: defaultSize * 1.3))
                            ? Container(
                                width: double.maxFinite,
                                height: defaultSize * 2.5,
                                child: Marquee(
                                  text: '${widget.note.tj_singer}',
                                  style: TextStyle(
                                      color: kPrimaryLightWhiteColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: defaultSize * 1.3),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 20.0,
                                  pauseAfterRound: Duration(seconds: 10),
                                  startPadding: 0,
                                  accelerationDuration: Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                      Duration(milliseconds: 1000),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              )
                            : Text('${widget.note.tj_singer}',
                                style: TextStyle(
                                    color: kPrimaryLightWhiteColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: defaultSize * 1.3)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: GestureDetector(
                        onTap: () async {
                          Analytics_config()
                              .noteDetailViewYoutube(widget.note.tj_title);
                          final url = Uri.parse(
                              'https://www.youtube.com/results?search_query= ${widget.note.tj_title} ${widget.note.tj_singer}');
                          if (await canLaunchUrl(url)) {
                            launchUrl(url, mode: LaunchMode.inAppWebView);
                          }
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset('assets/icons/youtube.svg'),
                            Text(
                              "노래 듣기",
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: defaultSize),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: defaultSize),
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "노래방 번호",
                          style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.5,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: defaultSize),
                        Row(
                          children: [
                            SizedBox(
                              width: defaultSize * 4,
                              child: Text(
                                "TJ",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(width: defaultSize * 1.5),
                            Text(
                              widget.note.tj_songNumber,
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 1.5,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        SizedBox(height: defaultSize),
                        Row(
                          children: [
                            SizedBox(
                              width: defaultSize * 4,
                              child: Text(
                                "금영",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(width: defaultSize * 1.5),
                            widget.note.ky_songNumber == '?'
                                ? GestureDetector(
                                    onTap: () {
                                      showKySearchDialog(context);
                                    },
                                    child: Container(
                                        width: defaultSize * 4.7,
                                        height: defaultSize * 2.3,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: kMainColor,
                                        ),
                                        child: Center(
                                            child: Text(
                                          "검색",
                                          style: TextStyle(
                                              color: kPrimaryWhiteColor,
                                              fontSize: defaultSize * 1.2,
                                              fontWeight: FontWeight.w500),
                                        ))),
                                  )
                                : Text(
                                    widget.note.ky_songNumber,
                                    style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontSize: defaultSize * 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: defaultSize),
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.only(right: defaultSize),
                        padding: EdgeInsets.all(defaultSize * 1.5),
                        decoration: BoxDecoration(
                            color: kPrimaryLightBlackColor,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Row(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "최고음",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.2,
                                    fontWeight: FontWeight.w200),
                              ),
                              SizedBox(height: defaultSize * 0.2),
                              Text(
                                widget.note.pitchNum == 0
                                    ? "-"
                                    : "${pitchNumToString[widget.note.pitchNum]}",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: defaultSize),
                              Text(
                                "난이도",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.2,
                                    fontWeight: FontWeight.w200),
                              ),
                              SizedBox(height: defaultSize * 0.2),
                              Text(
                                pitchToLevel(widget.note.pitchNum),
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Spacer(),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: RequestPitchInfoButton(note: widget.note)),
                        ])),
                  )
                ],
              ),
            ),
            SizedBox(height: defaultSize),
            Container(
              margin: EdgeInsets.symmetric(horizontal: defaultSize),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: kPrimaryLightBlackColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              padding: EdgeInsets.all(defaultSize * 1.5),
              child: EditableTextField(note: widget.note),
            ),
            SizedBox(height: defaultSize),
            Container(
              margin: EdgeInsets.symmetric(horizontal: defaultSize),
              padding: EdgeInsets.all(defaultSize * 1.5),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: kPrimaryLightBlackColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("가사",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 1.5,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: defaultSize * 2),
                    Center(
                      child: Text(lyric.isEmpty ? "로딩중 입니다" : lyric.trim(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.4,
                              fontWeight: FontWeight.w300)),
                    ),
                  ]),
            )
          ]),
        ),
      ),
    );
  }

  // 금영 노래방 번호 검색 팝업 함수
  void showKySearchDialog(BuildContext context) async {
    double defaultSize = SizeConfig.defaultSize;
    //!event: 곡 상세정보 뷰 - 금영 검색
    Analytics_config().noteDetailViewFindKY(widget.note.tj_songNumber);
    Provider.of<MusicSearchItemLists>(context, listen: false)
        .runKYFilter(widget.note.tj_title);
    List<MusicSearchItem> kySearchSongList =
        Provider.of<MusicSearchItemLists>(context, listen: false).foundItems;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              width: SizeConfig.screenWidth * 0.8,
              height: SizeConfig.screenHeight * 0.6,
              color: kDialogColor,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: defaultSize * 1),
                      child: DefaultTextStyle(
                        style: TextStyle(
                            color: kPrimaryLightWhiteColor,
                            fontSize: defaultSize * 2),
                        child: Text(
                          "금영 번호 추가",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: defaultSize),
                        child: Divider(
                            height: 0.1, color: kPrimaryLightWhiteColor)),
                    kySearchSongList.length == 0
                        ? Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: DefaultTextStyle(
                              style: TextStyle(fontSize: defaultSize * 1.4),
                              child: Text(
                                "검색 결과가 없습니다 😪",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: kPrimaryLightWhiteColor),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: kySearchSongList.length,
                              itemBuilder: (context, index) => Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: defaultSize * 0.5),
                                child: Card(
                                  color: kPrimaryGreyColor,
                                  elevation: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Provider.of<NoteData>(context,
                                              listen: false)
                                          .editKySongNumber(
                                              widget.note,
                                              kySearchSongList[index]
                                                  .songNumber);
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: ListTile(
                                      title: Text(
                                        kySearchSongList[index].title,
                                        style: TextStyle(
                                            color: kPrimaryWhiteColor,
                                            fontSize: defaultSize * 1.4),
                                      ),
                                      subtitle: Text(
                                          kySearchSongList[index].singer,
                                          style: TextStyle(
                                              color: kPrimaryWhiteColor,
                                              fontSize: defaultSize * 1.2)),
                                      leading: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              kySearchSongList[index]
                                                  .songNumber,
                                              style: TextStyle(
                                                  color: kMainColor,
                                                  fontSize: defaultSize * 1.2)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                  ]),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Widget deleteButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Analytics_config().noteDeleteEvent(widget.note.tj_title);
        Provider.of<NoteData>(context, listen: false).deleteNote(widget.note);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Text("삭제", style: TextStyle(fontWeight: FontWeight.w600)),
    );

    Widget cancelButton = ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("취소", style: TextStyle(fontWeight: FontWeight.w600)));

    AlertDialog alert = AlertDialog(
      content: Text(
        "노트를 삭제 하시겠습니까?",
        style:
            TextStyle(fontWeight: FontWeight.w400, color: kPrimaryWhiteColor),
      ),
      actions: [
        cancelButton,
        deleteButton,
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

void play(String fitch) async {
  final player = AudioCache(prefix: 'assets/fitches/');
  await player.play('$fitch.mp3');
}

//최고음 -> 난이도 변환
String pitchToLevel(int pitchNum) {
  if (pitchNum == 0) {
    return '-';
  } else if (pitchNum < 21) {
    return '하';
  } else if (pitchNum < 23) {
    return '중하';
  } else if (pitchNum < 25) {
    return '중';
  } else if (pitchNum < 29) {
    return '중상';
  } else {
    return '상';
  }
}
