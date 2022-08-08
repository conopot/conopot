import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PitchDropdownOption extends StatefulWidget {
  @override
  State<PitchDropdownOption> createState() => _PitchDropdownOptionState();
}

class _PitchDropdownOptionState extends State<PitchDropdownOption> {
  String optionString = '모든 노래';
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        alignment: Alignment(0.9, 0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: optionString,
            icon: const Icon(Icons.arrow_drop_down_sharp),
            elevation: 16,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            onChanged: (String? newValue) {
              musicList.changeSortOption(option: newValue);
              setState(() {
                if (newValue != null) {
                  optionString = newValue;
                }
              });
            },
            items: <String>['모든 노래', '내 음역대의 노래']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
