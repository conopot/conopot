import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/screens/musicBook/components/search_bar.dart';
import 'package:conopot/screens/note/components/note_search_list.dart';
import 'package:conopot/screens/note/components/note_serach_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import '../musicBook/components/search_list.dart';
import 'components/note_search_bar.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("곡추가"),
      ),
      body: Consumer<MusicSearchItemLists>(
        builder: (
          context,
          musicList,
          child,
        ) =>
            Column(
          children: [
            NoteSearchBar(musicList: musicList),
            NoteSearchList(musicList: musicList),
            NoteSearchTextfiled(),
          ],
        ),
      ),
    );
  }
}
