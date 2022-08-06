import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class NoteSearchList extends StatefulWidget {
  final MusicSearchItemLists musicList;
  const NoteSearchList({super.key, required this.musicList});

  @override
  State<NoteSearchList> createState() => _NoteSearchListState();
}

class _NoteSearchListState extends State<NoteSearchList> {
  double defaultSize = SizeConfig.defaultSize;

  Widget _ListView(BuildContext context) {
    return widget.musicList.combinedFoundItems.isNotEmpty
        ? Consumer<NoteData>(
            builder: (context, notedata, child) => Expanded(
              child: ListView.builder(
                itemCount: widget.musicList.combinedFoundItems.length,
                itemBuilder: (context, index) {
                  String songNumber = widget.musicList.combinedFoundItems[index].tj_songNumber;
                  String title = widget.musicList.combinedFoundItems[index].tj_title;
                  String singer = widget.musicList.combinedFoundItems[index].tj_singer;
                  int pitchNum = widget.musicList.combinedFoundItems[index].pitchNum;

                  return Container(
                  margin: EdgeInsets.fromLTRB(
                      defaultSize, 0, defaultSize, defaultSize * 0.5),
                  child: Container(
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
                                title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: defaultSize * 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryWhiteColor,
                                ),
                              ),
                              SizedBox(
                                height: defaultSize * 0.2,
                              ),
                              Text(
                                singer,
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
                                        '${songNumber}',
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
                                          pitchNumToString[pitchNum],
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
                                Provider.of<NoteData>(context, listen: false).showAddNoteDialog(context, songNumber, title);
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
                );
                }
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
