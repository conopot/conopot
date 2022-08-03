import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/screens/note/components/editable_text_field.dart';
import 'package:conopot/screens/note/components/request_pitch_button.dart';
import 'package:conopot/config/size_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    Text(
                      '${widget.note.tj_title}',
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: defaultSize * 1.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: defaultSize * 0.5),
                    Text(
                      '${widget.note.tj_singer}',
                      style: TextStyle(
                          color: kPrimaryLightWhiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: defaultSize * 1.3),
                      overflow: TextOverflow.ellipsis,
                    )
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
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: EdgeInsets.only(left: defaultSize),
                  padding: EdgeInsets.all(defaultSize * 1.5),
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
                              widget.note.pitchNum == 0
                                  ? "-"
                                  : "${pitchNumToString[widget.note.pitchNum]}",
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

  void _showDeleteDialog(BuildContext context) {
    Widget deleteButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Provider.of<NoteData>(context, listen: false)
            .noteDeleteEvent(widget.note);
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
