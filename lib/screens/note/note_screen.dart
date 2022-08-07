import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/banner.dart';
import 'package:conopot/screens/note/components/empty_note_list.dart';
import 'package:conopot/screens/note/components/note_list.dart';
import 'package:conopot/screens/user/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'add_note_screen.dart';

import 'package:http/http.dart' as http;

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

// 메인화면 - 애창곡 노트
class _NoteScreenState extends State<NoteScreen> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(
      builder: (context, noteData, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "애창곡 노트",
            style: TextStyle(
              color: kMainColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserScreen()));
              },
            ),
          ],
        ),
        floatingActionButton: (!noteData.notes.isEmpty)
            ? Container(
                margin: EdgeInsets.fromLTRB(0, 0, defaultSize * 0.5, defaultSize * 0.5),
                width: 72,
                height: 72,
                child: FittedBox(
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset('assets/icons/addButton.svg'),
                    onPressed: () {
                      Future.delayed(Duration.zero, () {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .initCombinedBook();
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNoteScreen(),
                        ),
                      );
                    },
                  ),
                ),
              )
            : null,
        body: Column(
          children: [
            CarouselSliderBanner(),
            if (noteData.notes.isEmpty)...[ EmptyNoteList()]
            else...[SizedBox(height: defaultSize),NoteList()],
          ],
        ),
      ),
    );
  }
}
