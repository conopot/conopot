import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/youtube_player_provider.dart';
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
    return WillPopScope(
      onWillPop: () async {
        if (Provider.of<YoutubePlayerProvider>(context, listen: false)
            .isHomeTab) {
          Provider.of<YoutubePlayerProvider>(context, listen: false)
              .openPlayer();
          Provider.of<YoutubePlayerProvider>(context, listen: false).refresh();
        }
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("노래 추가",
              style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true,
          leading: BackButton(
            color: kPrimaryLightWhiteColor,
            onPressed: () {
              if (Provider.of<YoutubePlayerProvider>(context, listen: false)
                  .isHomeTab) {
                Provider.of<YoutubePlayerProvider>(context, listen: false)
                    .openPlayer();
                Provider.of<YoutubePlayerProvider>(context, listen: false)
                    .refresh();
              }
              Navigator.of(context).pop();
            },
          ),
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
      ),
    );
  }
}
