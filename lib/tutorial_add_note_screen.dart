import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/note_search_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'screens/note/components/note_search_bar.dart';

class TutorialAddNoteScreen extends StatefulWidget {
  const TutorialAddNoteScreen({Key? key}) : super(key: key);

  @override
  State<TutorialAddNoteScreen> createState() => _TutorialAddNoteScreenState();
}

class _TutorialAddNoteScreenState extends State<TutorialAddNoteScreen> {
  @override
  void initState() {
    Provider.of<NoteData>(context, listen: false).isOnboarding = true;
    Analytics_config().addNotePageView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      body: SafeArea(
        child: Consumer<MusicSearchItemLists>(
          builder: (
            context,
            musicList,
            child,
          ) =>
              Column(
            children: [
              SizedBox(height: defaultSize),
              Text(
                "노래방에서 자주 부르는 노래 하나를 추가해주세요 😉",
                style: TextStyle(
                    color: kMainColor,
                    fontWeight: FontWeight.w500,
                    fontSize: defaultSize * 1.3),
              ),
              SizedBox(height: defaultSize),
              NoteSearchBar(musicList: musicList),
              NoteSearchList(musicList: musicList),
            ],
          ),
        ),
      ),
    );
  }
}
