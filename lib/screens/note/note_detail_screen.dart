import 'dart:convert';
import 'package:conopot/config/constants.dart';
import 'package:conopot/screens/note/components/editable_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:conopot/config/size_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/chart/components/pitch_search_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/music_search_item.dart';
import '../../models/note.dart';

class NoteDetailScreen extends StatefulWidget {
  late Note note;
  NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
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
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(defaultSize * 1.5),
            margin: EdgeInsets.symmetric(horizontal: defaultSize),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: kPrimaryLightBlackColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.note.tj_title}',
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 1.5)),
                    SizedBox(height: defaultSize * 0.5),
                    Text('${widget.note.tj_singer}',
                        style: TextStyle(
                            color: kPrimaryLightWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 1.3))
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(
                            'https://www.youtube.com/results?search_query= ${widget.note.tj_title} ${widget.note.tj_singer}');
                        if (await canLaunchUrl(url)) {
                          launchUrl(url, mode: LaunchMode.inAppWebView);
                        }
                      },
                      child: SvgPicture.asset('assets/icons/youtube.svg'),
                    ),
                    Text(
                      "노래 듣기",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: defaultSize),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: defaultSize),
                padding: EdgeInsets.all(defaultSize * 1.5),
                height: defaultSize * 11.1,
                width: defaultSize * 12.2,
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
                          width: defaultSize * 3,
                          child: Text(
                            "TJ",
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 1.5,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: defaultSize * 1.5),
                        SizedBox(
                          width: defaultSize * 4.7,
                          child: Text(
                            widget.note.tj_songNumber,
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 1.5,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: defaultSize),
                    Row(
                      children: [
                        SizedBox(
                          width: defaultSize * 3,
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
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
                            : SizedBox(
                                width: defaultSize * 4.7,
                                child: Text(
                                  widget.note.ky_songNumber,
                                  style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                  height: defaultSize * 11.1,
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
                                widget.note.pitchNum == 0 ?
                                "-" :  "${pitchNumToString[widget.note.pitchNum]}",
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
                                widget.note.pitchNum == 0 ?
                                "-" :  "${pitchNumToString[widget.note.pitchNum]}",
                                style: TextStyle(
                                    color: kPrimaryWhiteColor,
                                    fontSize: defaultSize * 1.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Spacer(),
                          Align(alignment: Alignment.bottomRight, child: pitchInfo(pitchNumToString[widget.note.pitchNum])),
                        ])
                ),
              )
            ],
          )
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.only(left: 20),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               widget.note.tj_title,
          //               overflow: TextOverflow.ellipsis,
          //               maxLines: 1,
          //               style: TextStyle(
          //                 color: kTitleColor,
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 23,
          //               ),
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Text(
          //               widget.note.tj_singer,
          //               overflow: TextOverflow.ellipsis,
          //               maxLines: 1,
          //               style: TextStyle(
          //                   color: kSubTitleColor,
          //                   fontSize: 15,
          //                   fontWeight: FontWeight.bold),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     Container(
          //       width: 80,
          //       alignment: Alignment.center,
          //       child: Column(
          //         children: [
          //           IconButton(
          //               padding: EdgeInsets.only(right: 10),
          //               icon: SvgPicture.asset('assets/icons/youtube.svg'),
          //               onPressed: () async {
          //                 final url = Uri.parse(
          //                     'https://www.youtube.com/results?search_query= ${widget.note.tj_title} ${widget.note.tj_singer}');
          //                 if (await canLaunchUrl(url)) {
          //                   launchUrl(url, mode: LaunchMode.inAppWebView);
          //                 }
          //               }),
          //           Align(
          //               alignment: Alignment(-0.3, 0),
          //               child: Text(
          //                 "노래 듣기",
          //                 style: TextStyle(
          //                     fontSize: 13, fontWeight: FontWeight.bold),
          //               )),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // Container(
          //   padding: EdgeInsets.only(top: 10),
          //   height: 1,
          //   child: Divider(
          //     color: Color(0xFFD2CDCD),
          //   ),
          // ),
          // SizedBox(
          //   height: 20,
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20, right: 20),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       SizedBox(
          //         height: 10,
          //       ),
          //       Row(
          //         children: [
          //           Container(
          //               width: 50,
          //               child: Text("TJ",
          //                   style: TextStyle(
          //                       fontSize: 18, fontWeight: FontWeight.bold))),
          //           SizedBox(width: 10),
          //           Container(
          //             width: 70,
          //             height: 28,
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.all(Radius.circular(5)),
          //               color: Color(0x30826A6A),
          //             ),
          //             child: Center(
          //                 child: Text(
          //               widget.note.tj_songNumber,
          //               style:
          //                   TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          //             )),
          //           ),
          //           SizedBox(width: 30),
          //           Container(
          //             child: Text("최고음",
          //                 style: TextStyle(
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.bold,
          //                 )),
          //             width: 60,
          //           ),
          //           SizedBox(width: 10),
          //           _pitchInfo(pitchNumToString[widget.note.pitchNum]),
          //         ],
          //       ),
          //       SizedBox(height: 10),
          //       Row(
          //         children: [
          //           Container(
          //             width: 50,
          //             child: Text(
          //               "금영",
          //               style:
          //                   TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //           SizedBox(width: 10),
          //           widget.note.ky_songNumber == '?'
          //               ? GestureDetector(
          //                   onTap: () {
          //                     _showKySearchDialog(context);
          //                   },
          //                   child: Container(
          //                     width: 70,
          //                     height: 28,
          //                     decoration: BoxDecoration(
          //                       borderRadius:
          //                           BorderRadius.all(Radius.circular(5)),
          //                       color: Color(0x30826A6A),
          //                     ),
          //                     child: Align(
          //                       alignment: Alignment.centerLeft,
          //                       child: Icon(Icons.search),
          //                     ),
          //                   ),
          //                 )
          //               : Container(
          //                   width: 70,
          //                   height: 28,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.all(Radius.circular(5)),
          //                     color: Color(0x30826A6A),
          //                   ),
          //                   child: Center(
          //                     child: Text(
          //                       widget.note.ky_songNumber,
          //                       style: TextStyle(
          //                           fontWeight: FontWeight.bold, fontSize: 17),
          //                     ),
          //                   ),
          //                 ),
          //           SizedBox(width: 30),
          //           if (pitchNumToString[widget.note.pitchNum] != '?')
          //             Row(
          //               children: [
          //                 Container(
          //                   child: Text("최고음\n들어보기",
          //                       style: TextStyle(
          //                           fontSize: 13, fontWeight: FontWeight.bold)),
          //                   width: 55,
          //                 ),
          //                 TextButton(
          //                   onPressed: () {
          //                     Provider.of<NoteData>(context, listen: false)
          //                         .pitchListenEvent();
          //                     play(pitchNumToCode[widget.note.pitchNum]);
          //                   },
          //                   child: Icon(
          //                     Icons.play_circle_outline_outlined,
          //                     color: Colors.black,
          //                     size: 40.0,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //         ],
          //       ),
          //       SizedBox(height: 15),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             "메모",
          //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //           ),
          //           SizedBox(height: 10),
          //           Stack(children: [
          //             Container(
          //               width: MediaQuery.of(context).size.width,
          //               height: 50,
          //               decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.all(Radius.circular(5)),
          //                   color: Color(0xFFF5F5FA)),
          //             ),
          //             Container(
          //               child: EditableTextField(note: widget.note),
          //               padding: EdgeInsets.only(left: 15),
          //             )
          //           ]),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: 15,
          // ),
          // Expanded(
          //   child: _recommendList(widget.note.pitchNum),
          // ),
        ]),
      ),
    );
  }

  // 금영 노래방 번호 검색 팝업 함수
  void showKySearchDialog(BuildContext context) async {
    //!event: 곡 상세정보 뷰 - 금영 검색
    Provider.of<NoteData>(context, listen: false)
        .kySearchEvent(widget.note.tj_songNumber);
    Provider.of<MusicSearchItemLists>(context, listen: false)
        .runKYFilter(widget.note.tj_title);
    List<MusicSearchItem> kySearchSongList =
        Provider.of<MusicSearchItemLists>(context, listen: false).foundItems;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Container(
              width: SizeConfig.screenWidth * 0.8,
              height: SizeConfig.screenHeight * 0.6,
              color: Colors.white,
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: DefaultTextStyle(
                    style: TextStyle(color: Colors.black, fontSize: 30),
                    child: Text(
                      "금영 번호 추가",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                kySearchSongList.length == 0
                    ? Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: DefaultTextStyle(
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          child: Text(
                            "검색 결과가 없습니다 😪",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryLightGreenColor),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: kySearchSongList.length,
                          itemBuilder: (context, index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            height: 100,
                            child: Card(
                              elevation: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Provider.of<NoteData>(context, listen: false)
                                      .changeKySongNumber(widget.note,
                                          kySearchSongList[index].songNumber);
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                                child: ListTile(
                                  title: Text(kySearchSongList[index].title),
                                  subtitle:
                                      Text(kySearchSongList[index].singer),
                                  trailing:
                                      Text(kySearchSongList[index].songNumber),
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

  // 정보요청 다이어로그 창
  void showRequestDialog(BuildContext context) {
    Widget requestButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            //!event
            Provider.of<NoteData>(context, listen: false)
                .pitchRequestEvent(widget.note);
            // 정보요청
            noteInfoPostRequest(widget.note);
            // 정보요청
            Navigator.of(context).pop();

            Fluttertoast.showToast(
                msg: "최고음 정보를 요청하였습니다 :)",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          child: Text(
            "정보 요청",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        "최고음이 표시 되지 않을 경우 정보를 요청해주세요 ☺️",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [requestButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  void _showDeleteDialog(BuildContext context) {
    Widget okButton = ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.red),
      onPressed: () {
        Provider.of<NoteData>(context, listen: false)
            .noteDeleteEvent(widget.note);
        Provider.of<NoteData>(context, listen: false).deleteNote(widget.note);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Text("삭제", style: TextStyle(fontWeight: FontWeight.bold)),
    );

    Widget cancelButton = ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("취소", style: TextStyle(fontWeight: FontWeight.bold)));

    AlertDialog alert = AlertDialog(
      content: Text(
        "노트가 삭제 됩니다",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  Widget pitchInfo(String pitch) {
    return pitch == '?'
        ? GestureDetector(
            onTap: () {
              showRequestDialog(context);
            },
            child: Container(
              width: 80,
              height: 25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Color(0xFF7F8A8E),
              ),
              child: Center(
                child: Text(
                  "정보요청",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        : Container(
            width: 95,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color(0xFFF54141),
            ),
            child: Center(
              child: Text(
                pitch,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
  }

  Widget _recommendList(int pitchNum) {
    Provider.of<MusicSearchItemLists>(context, listen: false)
        .initPitchMusic(pitchNum: pitchNum);
    return pitchNum == 0
        ? Container()
        : Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: '비슷한 음역대 노래 추천',
                      style: TextStyle(
                        color: kTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              PitchSearchList(),
            ],
          );
  }
}

void noteInfoPostRequest(Note note) async {
  String url =
      'https://zeq3b9zt96.execute-api.ap-northeast-2.amazonaws.com/conopot/Conopot_Mailing';

  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      "fields": {
        "MusicName": "${note.tj_title}",
        "MusicSinger": "${note.tj_singer}",
        "MusicNumberTJ": "${note.tj_songNumber}",
        "MusicNumberKY": "${note.ky_songNumber}",
        "Calls": 1,
        "Status": "To do"
      }
    }),
  );
}

void play(String fitch) async {
  final player = AudioCache(prefix: 'assets/fitches/');
  await player.play('$fitch.mp3');
}
