import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchCheckBox extends StatefulWidget {
  PitchCheckBox({Key? key}) : super(key: key);

  @override
  State<PitchCheckBox> createState() => _PitchCheckBoxState();
}

class _PitchCheckBoxState extends State<PitchCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicSearchItemLists>(
      builder: (context, musicList, child) => Expanded(
        child: musicList.highestFoundItems.isNotEmpty
            ? ListView.builder(
                itemCount: musicList.highestFoundItems.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.white,
                  elevation: 1,
                  child: CheckboxListTile(
                    title: Text(
                      musicList.highestFoundItems[index].tj_title,
                      style: TextStyle(
                        color: kTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      musicList.highestFoundItems[index].tj_singer,
                      style: TextStyle(
                        color: kSubTitleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    secondary: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pitchNumToString[
                              musicList.highestFoundItems[index].pitchNum],
                          style: TextStyle(
                            color: kTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
              )
            : Text(
                '검색 결과가 없습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
