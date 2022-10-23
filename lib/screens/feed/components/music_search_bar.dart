import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/debounce.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:flutter/material.dart';

class MusicSearchBar extends StatefulWidget {
  final MusicSearchItemLists musicList;
  MusicSearchBar({required this.musicList});

  @override
  State<MusicSearchBar> createState() => _MusicSearchBarState();
}

class _MusicSearchBarState extends State<MusicSearchBar> {
  TextEditingController _controller = TextEditingController();
  double defaultSize = SizeConfig.defaultSize;
  final Debounce _debounce = Debounce(delay: Duration(milliseconds: 500));

  void _clearTextField() {
    _controller.text = "";
    widget.musicList.runHighFitchFilter(_controller.text);
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
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
        onChanged: (text) => {
          _debounce.call(() {
            widget.musicList.runCombinedFilter(text);
            setState(() {});
          })
        },
        autofocus: false,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.text,
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
