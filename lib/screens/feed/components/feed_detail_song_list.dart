import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/screens/feed/song_detail_screen.dart';
import 'package:flutter/material.dart';

class FeedDetailSongList extends StatefulWidget {
  List<Note> postList;
  Function indexChange;
  FeedDetailSongList(
      {super.key, required this.postList, required this.indexChange});

  @override
  State<FeedDetailSongList> createState() => _FeedDetailSongListState();
}

class _FeedDetailSongListState extends State<FeedDetailSongList> {
  @override
  Widget build(BuildContext context) {
    Analytics_config().feedPlaylistView();
    double defaultSize = SizeConfig.defaultSize;
    return Expanded(
      child: ListView.builder(
          itemCount: widget.postList.length,
          itemBuilder: (context, index) {
            String songNumber = widget.postList[index].tj_songNumber;
            String title = widget.postList[index].tj_title;
            String singer = widget.postList[index].tj_singer;
            return Container(
              margin: EdgeInsets.fromLTRB(
                  defaultSize, 0, defaultSize, defaultSize * 0.5),
              child: Container(
                width: defaultSize * 35.5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: kPrimaryLightBlackColor),
                padding: EdgeInsets.all(defaultSize * 1.5),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.indexChange(index);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: defaultSize * 4.5,
                          child: Center(
                            child: Text("${songNumber}",
                                style: TextStyle(color: kMainColor)),
                          )),
                      SizedBox(width: defaultSize),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: defaultSize * 1.4,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryWhiteColor,
                              ),
                            ),
                            SizedBox(
                              height: defaultSize * 0.2,
                            ),
                            Text(
                              singer,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: defaultSize * 1.2,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryLightWhiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: defaultSize),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SongDetailScreen(
                                        note: widget.postList[index])));
                          },
                          child: Column(
                            children: [
                              Icon(Icons.chevron_right,
                                  color: kPrimaryWhiteColor),
                              Text("상세정보",
                                  style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontSize: defaultSize))
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
