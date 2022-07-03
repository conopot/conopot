import 'package:carousel_slider/carousel_slider.dart';
import 'package:conopot/models/note_data.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "애창곡 노트",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 5.0,
          child: SvgPicture.asset('assets/icons/addButton.svg'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddNoteScreen()),
            );
          },
        ),
        body: Column(children: [
          _CarouselSlider(),
          _ReorderListView(),
        ]));
  }

  // 배너 아이템 위젯
  List<Widget> _banner = [
    // banner 1
    Stack(children: [
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0x402F80ED),
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
        ),
      ),
      Align(
        alignment: Alignment(-0.8, 0.0),
        child: SvgPicture.asset(
          'assets/icons/banner_sound.svg',
          height: 45,
          width: 45,
        ),
      ),
      Align(
        alignment: Alignment(0, 0),
        child: Column(
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
        ),
      ),
    ]),
    // banner 2
    Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Color(0x40832FED),
            borderRadius: BorderRadius.all(
              Radius.circular(7),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.8, 0.0),
          child: SvgPicture.asset(
            'assets/icons/banner_music.svg',
            height: 45,
            width: 45,
          ),
        ),
        Align(
          alignment: Alignment(0.4, 0),
          child: Column(
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
              Text(
                "우측 상단 [내 정보] - [애창곡 노트 설정]",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1b1a5b),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ];

  // carouselslider
  Widget _CarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.12,
        enableInfiniteScroll: false,
        viewportFraction: 1,
      ),
      items: _banner,
    );
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
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                      child: ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: note.title,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  )),
                              TextSpan(text: " "),
                              TextSpan(
                                  text: note.singer,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  )),
                            ],
                          ),
                        ),
                        subtitle: Text(note.memo),
                        trailing: Text(note.songNumber),
                      ),
                    ),
                  ),
                )
                .toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final Note note = noteData.notes.removeAt(oldIndex);
                noteData.notes.insert(newIndex, note);
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "애창곡 노트",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 5.0,
        child: SvgPicture.asset('assets/icons/addButton.svg'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNoteScreen()),
          );
        },
      ),
      body: _ReorderListView(),
    );
  }
}
