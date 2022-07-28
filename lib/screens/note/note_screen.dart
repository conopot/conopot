import 'package:carousel_slider/carousel_slider.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/musicBook/music_screen.dart';
import 'package:conopot/screens/pitch/pitch_main_screen.dart';
import 'package:conopot/screens/pitch/pitch_measure.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:conopot/screens/note/note_detail_screen.dart';
import 'package:conopot/screens/user/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import 'add_note_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(
        builder: (context, noteData, child) => Scaffold(
              appBar: AppBar(
                title: Text(
                  "애창곡 노트",
                  style: TextStyle(
                    color: kPrimaryBlackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MusicBookScreen()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.account_circle),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserScreen()));
                    },
                  ),
                ],
              ),
              floatingActionButton: (!noteData.notes.isEmpty)
                  ? Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                      width: 75,
                      height: 75,
                      child: FittedBox(
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          elevation: 5.0,
                          child: SvgPicture.asset('assets/icons/addButton.svg'),
                          onPressed: () {
                            Future.delayed(Duration.zero, () {
                              Provider.of<MusicSearchItemLists>(context,
                                      listen: false)
                                  .initCombinedBook();
                            });
                            noteData.setSelectedIndex(-1);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AddNoteScreen()),
                            );
                          },
                        ),
                      ),
                    )
                  : null,
              body: Column(
                children: [
                  _CarouselSlider(context),
                  (noteData.notes.isEmpty)
                      ? emptyNoteView()
                      : _ReorderListView(),
                ],
              ),
            ));
  }

  // carouselslider
  Widget _CarouselSlider(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.12,
        enableInfiniteScroll: true,
        viewportFraction: 0.9,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
      ),
      items: [
        // banner 1
        GestureDetector(
          onTap: () {
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .pitchBannerClickEvent(
                    Provider.of<NoteData>(context, listen: false).notes.length);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PitchMainScreen()),
            );
          },
          child: Stack(children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Color(0x402F80ED),
                borderRadius: BorderRadius.all(
                  Radius.circular(7),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/banner_sound.svg',
                  height: 45,
                  width: 45,
                ),
                SizedBox(width: SizeConfig.defaultSize * 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "노래방 전투력 측정 😎",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4b5f7e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "당신의 최고음을 측정해보세요",
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF1b1a5b),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ]),
        ),
        // banner 2
        GestureDetector(
          onTap: () {
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .noteSettingBannerClickEvent(
                    Provider.of<NoteData>(context, listen: false).notes.length);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MusicBookScreen()),
            );
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Color(0x406BDA68),
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/banner_music_book2.svg',
                    height: 45,
                    width: 45,
                  ),
                  SizedBox(width: SizeConfig.defaultSize * 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "불편한 노래방 반주기는 이제 그만! 😡",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4b5f7e),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "앱에서 노래방 번호를 검색해보세요",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1b1a5b),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // banner 3
        GestureDetector(
          onTap: () {
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .noteSettingBannerClickEvent(
                    Provider.of<NoteData>(context, listen: false).notes.length);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => noteSettingScreen()),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            width: SizeConfig.screenWidth * 0.9,
            decoration: BoxDecoration(
              color: Color(0x40832FED),
              borderRadius: BorderRadius.all(
                Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/banner_music.svg',
                  height: 45,
                  width: 45,
                ),
                SizedBox(width: SizeConfig.defaultSize * 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "최고음 표시가 가능한 것을 아시나요? 🧐",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4b5f7e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        child: Text(
                          "우측 상단 [MY] - [애창곡 노트 설정]",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1b1a5b),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // emptyNoteView
  Widget emptyNoteView() {
    return Expanded(
        child: Column(
      children: [
        SizedBox(
          height: SizeConfig.screenHeight / 5,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "나만의 ",
                style: TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                  text: '첫 애창곡',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                    fontSize: 20,
                  )),
              TextSpan(
                text: "을 저장해보세요!",
                style: TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: SizeConfig.defaultSize * 30,
        ),
        Container(
          height: SizeConfig.screenHeight * 0.2,
          width: SizeConfig.screenWidth * 0.5,
          child: FittedBox(
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 5.0,
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initCombinedBook();
                });
                Provider.of<NoteData>(context, listen: false)
                    .setSelectedIndex(-1);
                Provider.of<NoteData>(context, listen: false).addNoteEvent();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddNoteScreen()),
                );
              },
              child: SvgPicture.asset('assets/icons/addButton.svg'),
            ),
          ),
        ),
      ],
    ));
  }

  // redorderlistview
  Widget _ReorderListView() {
    return Expanded(
      child: Consumer<NoteData>(
        builder: (context, noteData, child) {
          return ReorderableListView(
            children: noteData.notes
                .map(
                  (note) => Card(
                      key: Key(
                        '${noteData.notes.indexOf(note)}',
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Slidable(
                          key: Key(
                            '${noteData.notes.indexOf(note)}',
                          ),
                          endActionPane: ActionPane(
                              extentRatio: .20,
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (BuildContext context) {
                                    noteData.deleteNote(note);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                ),
                              ]),
                          child: GestureDetector(
                            child: ListTile(
                              title: RichText(
                                  text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: note.tj_title,
                                      style: TextStyle(
                                        color: kTitleColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  TextSpan(text: " "),
                                  TextSpan(
                                      text: note.tj_singer,
                                      style: TextStyle(
                                        color: kSubTitleColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              )),
                              onTap: () {
                                Provider.of<NoteData>(context, listen: false)
                                    .viewNoteEvent(note);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteDetailScreen(
                                      note: note,
                                    ),
                                  ),
                                );
                              },
                              subtitle: Text(
                                note.memo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Container(
                                width: 80,
                                child: Row(
                                  children: [
                                    UserSetWidget(
                                        Provider.of<MusicSearchItemLists>(
                                                context,
                                                listen: true)
                                            .userNoteSetting,
                                        note,
                                        Provider.of<MusicSearchItemLists>(
                                                context,
                                                listen: true)
                                            .userMaxPitch),
                                  ],
                                ),
                              ),
                            ),
                          ))),
                )
                .toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final Note note = noteData.notes.removeAt(oldIndex);
                noteData.notes.insert(newIndex, note);
                Provider.of<NoteData>(context, listen: false).reorderEvent();
              });
            },
          );
        },
      ),
    );
  }
}

Widget UserSetWidget(int setNum, Note note, int userPitch) {
  if (setNum == 0) {
    return RichText(
        text: TextSpan(
            style: TextStyle(
              fontSize: 15,
            ),
            children: [
          TextSpan(
            text: 'TJ ',
            style: TextStyle(
              color: Color(0xFFFF4B00),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: note.tj_songNumber,
            style: TextStyle(
                color: kPrimaryBlackColor, fontWeight: FontWeight.bold),
          ),
        ]));
  } else if (setNum == 1) {
    if (note.pitchNum != 0) {
      return Text(
        pitchNumToString[note.pitchNum],
        style: TextStyle(
          color: (note.pitchNum >= 29) ? kPrimaryColor : kPrimaryGreenColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
  return Text('');
}
