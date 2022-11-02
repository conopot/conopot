import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/screens/note/add_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class MemoShapeButton extends StatelessWidget {
  const MemoShapeButton({super.key});

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Container(
      margin: EdgeInsets.all(defaultSize),
      padding: EdgeInsets.symmetric(horizontal: defaultSize),
      height: defaultSize * 8,
      decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
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
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "내 노래방 애창곡을",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.4,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                "애창곡 노트에 저장해보세요!",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.4,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: kMainColor),
              Text("노래추가", style: TextStyle(color: kMainColor, fontWeight: FontWeight.w500, fontSize: defaultSize * 1.3))
            ],
          )
        ]),
      ),
    );
  }
}
