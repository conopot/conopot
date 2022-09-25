import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SongBySameSingerList extends StatefulWidget {
  final Note note;
  const SongBySameSingerList({required this.note});

  @override
  State<SongBySameSingerList> createState() => _SongBySameSingerListState();
}

class _SongBySameSingerListState extends State<SongBySameSingerList> {
  List<FitchMusic> list = [];

  @override
  void initState() {
    list = Provider.of<MusicSearchItemLists>(context, listen: false)
        .findSongbySameSinger(widget.note.tj_singer, widget.note.tj_title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final defaultSize = SizeConfig.defaultSize;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: defaultSize),
      decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      padding: EdgeInsets.all(defaultSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.note.tj_singer}이(가) 부른 다른 노래',
            style: TextStyle(color: kPrimaryWhiteColor, fontWeight: FontWeight.w500, fontSize: defaultSize * 1.5),
          ),
          SizedBox(height: defaultSize),
          ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: list.length > 10 ? 10 : list.length,
              itemBuilder: ((context, index) {
                String songNumber = list[index].tj_songNumber;
                String title = list[index].tj_title;
                String singer = list[index].tj_singer;
                int pitchNum = list[index].pitchNum;
                return Container(
                  margin: EdgeInsets.only(bottom: defaultSize * 0.5),
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<NoteData>(context, listen: false)
                          .showAddNoteDialog(context, songNumber, title);
                    },
                    child: Container(
                      width: defaultSize * 35.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: kPrimaryGreyColor),
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
                                    if (pitchNum != 0) ...[
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
                              child: SvgPicture.asset(
                                  "assets/icons/listButton.svg")),
                        ],
                      ),
                    ),
                  ),
                );
              }))
        ],
      ),
    );
  }
}
