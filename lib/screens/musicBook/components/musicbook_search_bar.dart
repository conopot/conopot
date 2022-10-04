import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/debounce.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatefulWidget {
  final MusicSearchItemLists musicList;
  SearchBar({required this.musicList});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String _dropdwonValue = "제목";
  final Debounce _debounce = Debounce(delay: Duration(milliseconds: 500));

  @override
  void initState() {
    Provider.of<NoteData>(context, listen: false).controller =
        TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    //Provider.of<NoteData>(context, listen: false).controller.dispose();
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _clearTextField() {
      Provider.of<NoteData>(context, listen: false).controller.text = "";
      widget.musicList.runFilter(
          Provider.of<NoteData>(context, listen: false).controller.text,
          widget.musicList.tabIndex,
          _dropdwonValue);
    }

    double defaultSize = SizeConfig.defaultSize;
    return Container(
      margin: EdgeInsets.fromLTRB(
          defaultSize, defaultSize * 1.5, defaultSize, defaultSize),
      decoration: BoxDecoration(
        color: kPrimaryLightBlackColor,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Row(
        children: [
          SizedBox(width: defaultSize * 1.5),
          DropdownButton(
            items: const [
              DropdownMenuItem(child: Text("제목"), value: "제목"),
              DropdownMenuItem(child: Text("가수"), value: "가수"),
              DropdownMenuItem(child: Text("번호"), value: "번호"),
            ],
            value: _dropdwonValue,
            iconEnabledColor: kMainColor,
            dropdownColor: kPrimaryBlackColor,
            underline: SizedBox(),
            style: TextStyle(color: kPrimaryWhiteColor),
            onChanged: (String? selectedValue) {
              if (selectedValue is String) {
                _clearTextField();
                setState(() {
                  _dropdwonValue = selectedValue;
                });
              }
            },
          ),
          SizedBox(width: defaultSize),
          Expanded(
            child: TextField(
              controller:
                  Provider.of<NoteData>(context, listen: false).controller,
              style: TextStyle(color: kPrimaryWhiteColor),
              onChanged: (text) => {
                _debounce.call(() {
                  widget.musicList.runFilter(
                      text, widget.musicList.tabIndex, _dropdwonValue);
                })
              },
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.name,
              cursorColor: kMainColor,
              decoration: InputDecoration(
                hintText: '노래 검색',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: defaultSize * 1.5,
                  color: kPrimaryLightGreyColor,
                ),
                border: InputBorder.none,
                suffixIcon: Provider.of<NoteData>(context, listen: false)
                        .controller
                        .text
                        .isEmpty
                    ? Icon(
                        Icons.search,
                        color: kPrimaryWhiteColor,
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearTextField,
                        color: kPrimaryWhiteColor,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
