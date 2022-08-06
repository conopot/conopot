import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchCheckBox extends StatefulWidget {
  PitchCheckBox({Key? key}) : super(key: key);

  @override
  State<PitchCheckBox> createState() => _PitchCheckBoxState();
}

class _PitchCheckBoxState extends State<PitchCheckBox> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicSearchItemLists>(
      builder: (context, musicList, child) => Expanded(
        child: musicList.highestFoundItems.isNotEmpty
            ? ListView.builder(
                itemCount: musicList.highestFoundItems.length,
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: Card(
                    margin: EdgeInsets.fromLTRB(defaultSize, 0, defaultSize, defaultSize * 0.5),
                    color: kPrimaryLightBlackColor,
                    elevation: 0,
                    child: Theme(
                      data: ThemeData(unselectedWidgetColor: kPrimaryWhiteColor, toggleableActiveColor: kMainColor),
                      child: CheckboxListTile(
                        title: Text(
                          musicList.highestFoundItems[index].tj_title,
                          style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 1.25,
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        subtitle: Text(
                          musicList.highestFoundItems[index].tj_singer,
                          style: TextStyle(
                            color: kPrimaryLightWhiteColor,
                            fontSize: defaultSize * 1.1,
                            fontWeight: FontWeight.w300,
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                        secondary: SizedBox(
                          width: defaultSize * 6,
                          child: Center(
                            child: Text(
                              pitchNumToString[
                                  musicList.highestFoundItems[index].pitchNum],
                              style: TextStyle(
                                color: kMainColor,
                                fontWeight: FontWeight.w400,
                                fontSize: defaultSize * 1.1
                              ),
                            ),
                          ),
                        ),
                        value: musicList.isChecked[index],
                        onChanged: (bool? value) {
                          setState(() {
                            musicList.isChecked[index] = value!;
                            if (value == true) {
                              musicList.checkedMusics
                                  .add(musicList.highestFoundItems[index]);
                            } else {
                              musicList.checkedMusics
                                  .remove(musicList.highestFoundItems[index]);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              )
            : Text(
                '검색 결과가 없습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
