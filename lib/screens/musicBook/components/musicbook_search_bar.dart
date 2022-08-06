import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final MusicSearchItemLists musicList;
  SearchBar({required this.musicList});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _clearTextField() {
    _controller.text = "";
    widget.musicList.runFilter(_controller.text, widget.musicList.tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;

    return Container(
      margin: EdgeInsets.fromLTRB(defaultSize, defaultSize * 1.5, defaultSize, defaultSize),
      decoration: BoxDecoration(
        color: kPrimaryLightBlackColor,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: TextField(
        controller: _controller,
        style: TextStyle(color: kPrimaryWhiteColor),
        onChanged: (text) => {
          widget.musicList.runFilter(text, widget.musicList.tabIndex),
        },
        enableInteractiveSelection: false,
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
                  onPressed: _clearTextField,
                  color: kPrimaryWhiteColor,
                ),
        ),
      ),
    );
  }
}
