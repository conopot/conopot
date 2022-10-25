import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/playlist_serach_song_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddedPlaylist extends StatefulWidget {
  AddedPlaylist({Key? key}) : super(key: key);

  @override
  State<AddedPlaylist> createState() => _AddedPlaylistState();
}

// 플레이리스트 생성 플레이리스트 리스트뷰
class _AddedPlaylistState extends State<AddedPlaylist> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    double screenHieght = SizeConfig.screenHeight;

    return Consumer<NoteData>(
      builder: (context, noteData, child) {
        var items = noteData.lists.map(
          (list) {
            return Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, defaultSize * 0.5),
              key: Key(
                '${noteData.lists.indexOf(list)}',
              ),
              child: Container(
                height: list.memo.isEmpty
                    ? defaultSize * 7 * SizeConfig.textScaleFactor
                    : defaultSize * 8,
                key: Key(
                  '${noteData.lists.indexOf(list)}',
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: kPrimaryLightBlackColor,
                ),
                child: Row(
                  children: [
                    SizedBox(width: defaultSize),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${list.tj_title}',
                            style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (list.memo.isEmpty) ...[
                            SizedBox(height: defaultSize * 0.3)
                          ],
                          Text(
                            '${list.tj_singer}',
                            style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (list.memo.isNotEmpty) ...[
                            SizedBox(height: defaultSize * 0.3),
                            Container(
                              padding: EdgeInsets.all(defaultSize * 0.5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: kPrimaryGreyColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  list.memo,
                                  style: TextStyle(
                                      color: kPrimaryLightWhiteColor,
                                      fontSize: defaultSize * 1.2,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ).toList();
        items.add(Container(
              margin: EdgeInsets.only(top: defaultSize),
              key: ValueKey(1),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Provider.of<MusicSearchItemLists>(context, listen: false).initCombinedBook();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaylistSearchSongScreen(),
                      ),
                    );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultSize),
                      decoration: BoxDecoration(color: kPrimaryLightBlackColor),
                      child: Icon(
                        Icons.add,
                        color: kPrimaryWhiteColor,
                      ),
                    ),
                    SizedBox(width: defaultSize * 0.8),
                    Text(
                      "노래 추가",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: defaultSize * 1.5),
                    )
                  ],
                ),
              ),
            ));
        return Theme(
          data: ThemeData(
            canvasColor: Colors.transparent,
          ),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            padding: EdgeInsets.only(bottom: screenHieght * 0.3),
            children: items,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final Note note = noteData.lists.removeAt(oldIndex);
                noteData.lists.insert(newIndex, note);
              });
            },
          ),
        );
      },
    );
  }
}
