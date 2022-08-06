import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/screens/pitch/pitch_measure.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchSearchList extends StatelessWidget {
  double defaultSize = SizeConfig.defaultSize;

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
                      itemBuilder: (context, index) {
                        String songNumber =
                            musicList.highestFoundItems[index].tj_songNumber;
                        String title =
                            musicList.highestFoundItems[index].tj_title;

                        return ClipRRect(
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
                                  Provider.of<NoteData>(context, listen: false)
                                      .showAddNoteDialog(
                                          context, songNumber, title);
                                }),
                          ),
                        );
                      })
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
                              Navigator.of(context)
                                  .popUntil((_) => count++ >= 2);
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
