import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/youtube_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class EditNoteList extends StatefulWidget {
  EditNoteList({Key? key}) : super(key: key);

  @override
  State<EditNoteList> createState() => _EditNoteListState();
}

// 애창곡 노트뷰 노트 리스트
class _EditNoteListState extends State<EditNoteList> {
  double defaultSize = SizeConfig.defaultSize;

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
              buildDefaultDragHandles: true,
              padding: EdgeInsets.only(bottom: screenHieght * 0.3),
              children: noteData.notes.map(
                (note) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(
                        defaultSize, 0, defaultSize * 0.5, defaultSize * 0.5),
                    key: Key(
                      '${noteData.notes.indexOf(note)}',
                    ),
                    child: Slidable(
                        endActionPane: ActionPane(
                            extentRatio: .18,
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (value) {
                                  Provider.of<NoteData>(context, listen: false)
                                      .showDeleteDialog(context, note);
                                },
                                backgroundColor: kPrimaryLightBlackColor,
                                foregroundColor: kMainColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                icon: Icons.delete_outlined,
                              ),
                            ]),
                        child: Container(
                          height: note.memo.isEmpty
                              ? defaultSize * 7 * SizeConfig.textScaleFactor
                              : defaultSize * 8,
                          key: Key(
                            '${noteData.notes.indexOf(note)}',
                          ),
                          margin:
                              EdgeInsets.fromLTRB(0, 0, defaultSize * 0.5, 0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                            color: kPrimaryLightBlackColor,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                  checkColor: kMainColor,
                                  activeColor: Colors.transparent,
                                  side: BorderSide(color: kPrimaryLightGreyColor),
                                  shape: CircleBorder(),
                                  value: noteData.isChecked[
                                      noteData.notes.indexOf(note)],
                                  onChanged: (bool? val) {
                                    // deleteSet에 삭제할 노래들을 관리
                                    if (val == true) {
                                      noteData.checkSong(note);
                                    } else {
                                      noteData.unCheckSong(note);
                                    }
                                    setState(() {
                                      noteData.isChecked[noteData.notes
                                          .indexOf(note)] = val!;
                                    });
                                  }),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    if (note.memo.isEmpty) ...[
                                      SizedBox(height: defaultSize * 0.3)
                                    ],
                                    Text(
                                      '${note.tj_singer}',
                                      style: TextStyle(
                                        color: kPrimaryLightWhiteColor,
                                        fontSize: defaultSize * 1.2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (note.memo.isNotEmpty) ...[
                                      SizedBox(height: defaultSize * 0.3),
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
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            note.memo,
                                            style: TextStyle(
                                                color:
                                                    kPrimaryLightWhiteColor,
                                                fontSize: defaultSize * 1.2,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: defaultSize),
                                child: ReorderableDragStartListener(
                                    index: noteData.notes.indexOf(note),
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: kPrimaryLightGreyColor,
                                    )),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ).toList(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final Note note = noteData.notes.removeAt(oldIndex);
                  noteData.notes.insert(newIndex, note);
                  Provider.of<NoteData>(context, listen: false).reorderEvent();
                  Provider.of<YoutubePlayerProvider>(context, listen: false)
                      .reorder(oldIndex, newIndex);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
