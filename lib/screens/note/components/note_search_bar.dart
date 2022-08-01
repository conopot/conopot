import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteSearchBar extends StatefulWidget {
  final MusicSearchItemLists musicList;
  NoteSearchBar({required this.musicList});

  @override
  State<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends State<NoteSearchBar> {
  final TextEditingController _controller = TextEditingController();
  double defaultSize = SizeConfig.defaultSize;

  void _clearTextField() {
    _controller.text = "";
    widget.musicList.runCombinedFilter(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(defaultSize),
      child: Container(
        width: defaultSize * 34.5,
        height: defaultSize * 3.5,
        decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: TextField(
          style: TextStyle(color: kPrimaryWhiteColor),
          controller: _controller,
          onChanged: (text) => {widget.musicList.runCombinedFilter(text)},
          onTap: () {
            Provider.of<NoteData>(context, listen: false).setSelectedIndex(-1);
          },
          enableInteractiveSelection: false,
          textAlign: TextAlign.left,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: '노래, 가수 검색',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: defaultSize * 1.5,
              color: kPrimaryLightGreyColor,
            ),
            contentPadding: EdgeInsets.all(defaultSize),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.1),
            ),
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
      ),
    );
  }
}
