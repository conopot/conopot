import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:conopot/screens/pitch/pitch_measure.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class PitchSearchList extends StatelessWidget {
  double defaultSize = SizeConfig.defaultSize;

  void _showAddDialog(BuildContext context, FitchMusic item) {
    Widget okButton = ElevatedButton(
      onPressed: () {
        Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
            item.tj_songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
        if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
          Fluttertoast.showToast(
              msg: "이미 등록된 곡입니다 😢",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xFFFF7878),
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
          Provider.of<NoteData>(context, listen: false).initEmptyCheck();
        } else {
          Fluttertoast.showToast(
              msg: "노래가 추가 되었습니다 🎉",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
        }
      },
      child: Text("추가",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryGreyColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        "취소",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        "'${item.tj_title}' 노래를 애창곡 노트에 추가하시겠습니까?",
        style:
            TextStyle(fontWeight: FontWeight.w400, color: kPrimaryWhiteColor),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
      backgroundColor: kDialogColor,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Expanded(
              child: musicList.highestFoundItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: musicList.highestFoundItems.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Card(
                          margin: EdgeInsets.fromLTRB(
                              defaultSize, 0, defaultSize, defaultSize * 0.5),
                          color: kPrimaryLightBlackColor,
                          elevation: 1,
                          child: ListTile(
                              leading: SizedBox(
                                width: defaultSize * 6.5,
                                child: Center(
                                  child: Text(
                                    pitchNumToString[musicList
                                        .highestFoundItems[index].pitchNum],
                                    style: TextStyle(
                                      color: kMainColor,
                                      fontSize: defaultSize * 1.1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                musicList.highestFoundItems[index].tj_title,
                                style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                musicList.highestFoundItems[index].tj_singer,
                                style: TextStyle(
                                    color: kPrimaryLightWhiteColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: defaultSize * 1.2),
                              ),
                              onTap: () {
                                // !event : 음역대 측정 결과 뷰 - 내 최고음 주변의 인기곡들
                                Analytics_config.analytics
                                    .logEvent('음역대 측정 결과 뷰 - 내 최고음 주변의 인기곡들');
                                if (musicList.tabIndex == 1) {
                                  _showAddDialog(context,
                                      musicList.highestFoundItems[index]);
                                }
                              }),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "텅",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 18),
                          ),
                          SizedBox(height: SizeConfig.defaultSize),
                          Text(
                            "내 최고음 근처 인기곡들이 없어요",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: kPrimaryLightWhiteColor,
                                fontSize: defaultSize * 1.5),
                          ),
                          SizedBox(height: SizeConfig.defaultSize),
                          ElevatedButton(
                            onPressed: () {
                              int count = 0;
                              Navigator.of(context).popUntil((_) => count++ >= 2);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PitchMeasure()));
                            },
                            child: Text(
                              "다시 측정하기",
                              style: TextStyle(
                                  color: kPrimaryBlackColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                side: BorderSide(color: kPrimaryBlackColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0))),
                          ),
                        ],
                      ),
                    )),
    );
  }
}
