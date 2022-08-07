import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:flutter/material.dart';

class PitchDropdown extends StatelessWidget {
  final MusicSearchItemLists musicList;
  const PitchDropdown({required this.musicList});

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: defaultSize),
      alignment: Alignment(0.9, 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: '정렬 조건',
          icon: const Icon(Icons.arrow_drop_down_sharp, color: kPrimaryLightWhiteColor,),
          elevation: 0,
          style: const TextStyle(color: kPrimaryWhiteColor, fontWeight: FontWeight.w300),
          onChanged: (String? newValue) {
            // !event : 간접 음역대 측정뷰 - 페이지뷰
            Analytics_config.analytics.logEvent('간접 음역대 측정뷰 - 정렬',
                eventProperties: {'정렬 조건': newValue});
            musicList.changeSortOption(option: newValue);
          },
          dropdownColor: kDialogColor,
          items: <String>['정렬 조건', '높은 음정순', '낮은 음정순']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
