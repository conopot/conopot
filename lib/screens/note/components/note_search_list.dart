import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class NoteSearchList extends StatefulWidget {
  final MusicSearchItemLists musicList;
  const NoteSearchList({super.key, required this.musicList});

  @override
  State<NoteSearchList> createState() => _NoteSearchListState();
}

class _NoteSearchListState extends State<NoteSearchList> {
  double defaultSize = SizeConfig.defaultSize;

  // 노트 추가 다이어로그 팝업 함수
  void _showAddNoteDialog(BuildContext context, FitchMusic item) {
    // 확인 버튼
    Widget okButton = ElevatedButton(
      onPressed: () {
        Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
            item.tj_songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
        if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
          Fluttertoast.showToast(
              msg: "이미 등록된 곡입니다 😢",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xFFFF7878),
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
          Provider.of<NoteData>(context, listen: false).initEmptyCheck();
        } else {
          Fluttertoast.showToast(
              msg: "노래가 추가 되었습니다 🎉",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
        }
      },
      child: Text("추가",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    // 취소 버튼
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
      child: Text(
        "취소",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: "'${item.tj_title}' ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
              text: "노래를 애창곡 노트에 추가하시겠습니까?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ))
        ]),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
      backgroundColor: kDialogColor,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  Widget _ListView(BuildContext context) {
    return widget.musicList.combinedFoundItems.isNotEmpty
        ? Consumer<NoteData>(
            builder: (context, notedata, child) => Expanded(
              child: ListView.builder(
                itemCount: widget.musicList.combinedFoundItems.length,
                itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.fromLTRB(
                      defaultSize, 0, defaultSize, defaultSize * 0.5),
                  child: Container(
                    height: defaultSize * 9,
                    width: defaultSize * 35.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: kPrimaryLightBlackColor),
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.musicList.combinedFoundItems[index]
                                    .tj_title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: defaultSize * 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryWhiteColor,
                                ),
                              ),
                              Text(
                                widget.musicList.combinedFoundItems[index]
                                    .tj_singer,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: defaultSize * 1.2,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryLightWhiteColor,
                                ),
                              ),
                              SizedBox(
                                height: defaultSize * 0.5,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: defaultSize * 4.5,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${widget.musicList.combinedFoundItems[index].tj_songNumber}',
                                        style: TextStyle(
                                          color: kMainColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: defaultSize * 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (widget.musicList.combinedFoundItems[index]
                                          .pitchNum !=
                                      0) ...[
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: kPrimaryGreyColor,
                                            ),
                                            padding: EdgeInsets.all(3),
                                            child: Text(
                                              "최고음",
                                              style: TextStyle(
                                                color: kPrimaryWhiteColor,
                                                fontSize: defaultSize * 0.8,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: defaultSize * 0.3),
                                        Text(
                                          pitchNumToString[widget
                                              .musicList
                                              .combinedFoundItems[index]
                                              .pitchNum],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: defaultSize * 1.2,
                                            color: kPrimaryWhiteColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: defaultSize * 1.5),
                        SizedBox(
                            width: defaultSize * 2.1,
                            height: defaultSize * 1.9,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  notedata.setSelectedIndex(index);
                                  notedata.clickedItem = widget
                                      .musicList.combinedFoundItems[index];
                                });
                                _showAddNoteDialog(context,
                                    widget.musicList.combinedFoundItems[index]);
                                //!event: 곡 추가 뷰 - 리스트 클릭 시
                                Provider.of<NoteData>(context, listen: false)
                                    .addSongClickEvent(widget
                                        .musicList.combinedFoundItems[index]);
                              },
                              child: SvgPicture.asset(
                                  "assets/icons/listButton.svg"),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Expanded(
          child: Center(
            child: Text(
                '검색 결과가 없습니다',
                style: TextStyle(
                  fontSize: defaultSize * 1.8,
                  fontWeight: FontWeight.w300,
                  color: kPrimaryWhiteColor,
                ),
              ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _ListView(context);
  }
}
