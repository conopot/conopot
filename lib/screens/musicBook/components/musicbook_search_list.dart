import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchList extends StatefulWidget {
  final MusicSearchItemLists musicList;
  const SearchList({super.key, required this.musicList});

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  double defaultSize = SizeConfig.defaultSize;
  double screenHeight = SizeConfig.screenHeight;

  @override
  Widget build(BuildContext context) {
    return widget.musicList.foundItems.isNotEmpty
        ? ListView.builder(
            itemCount: widget.musicList.foundItems.length,
            itemBuilder: (context, index) {
              String songNumber = widget.musicList.foundItems[index].songNumber;
              String title = widget.musicList.foundItems[index].title;
              String singer = widget.musicList.foundItems[index].singer;

              return GestureDetector(
                  onTap: () {
                    Provider.of<NoteData>(context, listen: false).showAddNoteDialogWithInfo(context, songNumber: songNumber, title: title, singer: singer);
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        defaultSize, 0, defaultSize, defaultSize),
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Row(children: [
                      SizedBox(
                        width: defaultSize * 6,
                        child: Center(
                            child: Text(
                                "${songNumber}",
                                style: TextStyle(
                                    color: kMainColor,
                                    fontSize: defaultSize * 1.4,
                                    fontWeight: FontWeight.w500))),
                      ),
                      SizedBox(width: defaultSize),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${title}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 1.4,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: defaultSize * 0.5),
                            Text(
                              "${singer}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: kPrimaryLightWhiteColor,
                                  fontSize: defaultSize * 1.2,
                                  fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                );
            })
        : Center(
            child: Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: defaultSize * 1.8,
                color: kPrimaryWhiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
  }
}
