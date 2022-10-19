import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/screens/note/add_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class EmptyIconNote extends StatelessWidget {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Provider.of<MusicSearchItemLists>(context, listen: false)
              .initCombinedBook();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          );
        },
        child: Container(
          child: SvgPicture.asset(
            "assets/icons/addButtonWithPointer.svg",
            height: defaultSize * 20,
            width: defaultSize * 20,
            // color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
