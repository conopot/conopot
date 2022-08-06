import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:flutter/material.dart';

class PitchSearchBar extends StatefulWidget {
  final MusicSearchItemLists musicList;
  PitchSearchBar({required this.musicList});

  @override
  State<PitchSearchBar> createState() => _PitchSearchBarState();
}

class _PitchSearchBarState extends State<PitchSearchBar> {
  TextEditingController _controller = TextEditingController();
  double defaultSize = SizeConfig.defaultSize;

  void _clearTextField() {
    _controller.text = "";
    widget.musicList.runHighFitchFilter(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryLightBlackColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: TextField(
        style: TextStyle(color: kPrimaryWhiteColor),
        controller: _controller,
        onChanged: (text) => {widget.musicList.runHighFitchFilter(text)},
        enableInteractiveSelection: false,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.name,
        cursorColor: kMainColor,
        decoration: InputDecoration(
          hintText: '노래, 가수 검색',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: defaultSize * 1.5,
            color: kPrimaryLightGreyColor,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: kPrimaryWhiteColor,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _clearTextField();
                    widget.musicList.initCombinedBook();
                  },
                  color: kPrimaryWhiteColor,
                ),
        ),
      ),
    );
  }
}