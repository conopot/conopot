import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class PopSearchList extends StatelessWidget {
  final MusicSearchItemLists musicList;

  const PopSearchList({super.key, required this.musicList});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: musicList.foundItems.isNotEmpty
          ? ListView.builder(
              itemCount: musicList.foundItems.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                elevation: 1,
                child: ListTile(
                    leading: Container(
                      width: 35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (index == 0)
                              ? Image(
                                  image: AssetImage('assets/images/first.png'),
                                  width: 30,
                                  height: 30,
                                )
                              : (index == 1)
                                  ? Image(
                                      image: AssetImage(
                                          'assets/images/second.png'),
                                      width: 30,
                                      height: 30,
                                    )
                                  : (index == 2)
                                      ? Image(
                                          image: AssetImage(
                                              'assets/images/third.png'),
                                          width: 30,
                                          height: 30,
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              (index + 1).toString() + "위",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kTextColor),
                                            ),
                                          ],
                                        ),
                        ],
                      ),
                    ),
                    title: Text(
                      musicList.foundItems[index].title,
                      style: TextStyle(
                          color: kTitleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    subtitle: Text(musicList.foundItems[index].singer,
                        style: TextStyle(
                            color: kSubTitleColor,
                            fontWeight: FontWeight.bold)),
                    trailing: Text(
                      musicList.foundItems[index].songNumber,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBlackColor),
                    ),
                    onTap: () {
                      if (musicList.tabIndex == 1) {
                        _showAddDialog(
                            context, musicList.foundItems[index]);
                      }
                    }),
              ),
            )
          : Text(
              '검색 결과가 없습니다',
              style: TextStyle(fontSize: 18),
            ),
    );
  }
}

_showAddDialog(BuildContext context, MusicSearchItem item) {
  Widget okButton = ElevatedButton(
    onPressed: () {
      // !event : 인기차트 뷰 - 노트 추가
      Analytics_config.analytics.logEvent('인기차트 뷰 - 노트추가');
      Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
          item.songNumber,
          Provider.of<MusicSearchItemLists>(context, listen: false)
              .combinedSongList);
      Navigator.of(context).pop();
      if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
        Fluttertoast.showToast(
            msg: "이미 저장된 노래입니다😅",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        Provider.of<NoteData>(context, listen: false).initEmptyCheck();
      } else {
        Fluttertoast.showToast(
            msg: "노트가 생성되었습니다😆",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: kPrimaryColor,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    },
    child: Text("추가", style: TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.red),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("취소", style: TextStyle(fontWeight: FontWeight.bold)));

  AlertDialog alert = AlertDialog(
    content: Text(
      "'${item.title}' 노래를 애창곡노트에 추가하시겠습니까?",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    actions: [
      cancelButton,
      okButton,
    ],
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(child: alert);
      });
}
