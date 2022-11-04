import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/screens/note/components/note_search_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'components/note_search_bar.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  @override
  void initState() {
    Analytics_config().addNotePageView();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("노래 추가", style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
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
          ],
        ),
      ),
    );
  }
}
