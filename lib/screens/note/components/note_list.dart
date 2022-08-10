import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/note/note_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

// 애창곡 노트뷰 노트 리스트
class _NoteListState extends State<NoteList> {
  double defaultSize = SizeConfig.defaultSize;

  // 애창곡 노트 설정에 따라 달라지는 정보 (최고음 or TJ 노래번호)
  Widget _userSettingInfo(int setNum, Note note, int userPitch) {
    if (setNum == 0) {
      return Center(
        child: Text(
          '${note.tj_songNumber}',
          style: TextStyle(
            color: kMainColor,
            fontSize: defaultSize * 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (setNum == 1) {
      if (note.pitchNum != 0) {
        return Center(
          child: Text(
            pitchNumToString[note.pitchNum],
            style: TextStyle(
              color: kMainColor,
              fontSize: defaultSize * 0.9,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }
    return Text('');
  }

  @override
  Widget build(BuildContext context) {
    double screenHieght = SizeConfig.screenHeight;

    return Expanded(
      child: Consumer<NoteData>(
        builder: (context, noteData, child) {
          return Theme(
            data: ThemeData(
              canvasColor: Colors.transparent,
            ),
            child: ReorderableListView(
              padding: EdgeInsets.only(bottom: screenHieght * 0.5),
              children: noteData.notes
                  .map(
                    (note) => Container(
                      height: Platform.isIOS ? defaultSize * 9.7 : null,
                      margin: EdgeInsets.fromLTRB(
                          defaultSize, 0, defaultSize * 0.5, defaultSize * 0.5),
                      key: Key(
                        '${noteData.notes.indexOf(note)}',
                      ),
                      child: Slidable(
                          endActionPane: ActionPane(
                              extentRatio: .25,
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    noteData.deleteNote(note);
                                  },
                                  backgroundColor: kPrimaryLightBlackColor,
                                  foregroundColor: kMainColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  icon: Icons.delete_outlined,
                                ),
                              ]),
                          child: GestureDetector(
                            onTap: () {
                              Analytics_config().viewNoteEvent(note);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteDetailScreen(
                                    note: note,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(defaultSize * 1.25,
                                  defaultSize * 1.25, 0, defaultSize * 1.25),
                              key: Key(
                                '${noteData.notes.indexOf(note)}',
                              ),
                              margin: EdgeInsets.fromLTRB(
                                  0, 0, defaultSize * 0.5, 0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: kPrimaryLightBlackColor,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${note.tj_title}',
                                        style: TextStyle(
                                          color: kPrimaryWhiteColor,
                                          fontSize: defaultSize * 1.4,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${note.tj_singer}',
                                        style: TextStyle(
                                          color: kPrimaryLightWhiteColor,
                                          fontSize: defaultSize * 1.2,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: defaultSize),
                                      Container(
                                        padding:
                                            EdgeInsets.all(defaultSize * 0.5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: kPrimaryGreyColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          note.memo,
                                          style: TextStyle(
                                              color: kPrimaryLightWhiteColor,
                                              fontSize: defaultSize * 1.2,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )
                                    ],
                                  )),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: defaultSize),
                                    child: SizedBox(
                                        width: defaultSize * 5,
                                        child: Center(
                                          child: _userSettingInfo(
                                              Provider.of<MusicSearchItemLists>(
                                                      context,
                                                      listen: true)
                                                  .userNoteSetting,
                                              note,
                                              Provider.of<MusicSearchItemLists>(
                                                      context,
                                                      listen: true)
                                                  .userMaxPitch),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                  )
                  .toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final Note note = noteData.notes.removeAt(oldIndex);
                  noteData.notes.insert(newIndex, note);
                  Provider.of<NoteData>(context, listen: false).reorderEvent();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
