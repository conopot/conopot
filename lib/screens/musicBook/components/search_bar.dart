import 'package:conopot/models/music_search_item_lists.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final MusicSearchItemLists musicList;

  const SearchBar({required this.musicList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: TextField(
        onChanged: (text) => {
          musicList.runFilter(text, musicList.tabIndex),
        },
        enableInteractiveSelection: false,
        focusNode: FocusNode(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintText: '제목 및 가수명을 입력하세요',
          contentPadding: EdgeInsets.all(0),
          suffixIcon: Icon(Icons.search),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFF7B61FF),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
        ),
      ),
    );
  }
}