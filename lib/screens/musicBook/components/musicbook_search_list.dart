import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/feed/song_detail_screen.dart';
import 'package:conopot/screens/note/note_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  late var songList;

  // bool isLoaded1 = false, isLoaded2 = false;

  // Map<String, String> Search_Native_UNIT_ID_ODD = kReleaseMode
  //     ? {
  //         //release 모드일때 (실기기 사용자)
  //         'android': 'ca-app-pub-7139143792782560/3104068385',
  //         'ios': 'ca-app-pub-7139143792782560/5971824166',
  //       }
  //     : {
  //         'android': 'ca-app-pub-3940256099942544/2247696110',
  //         'ios': 'ca-app-pub-3940256099942544/3986624511',
  //       };

  // Native 광고 T치
  // static final _kAdIndex = 0;
  // // TODO: Add a native ad instance
  // NativeAd? _ad_odd;

  // // TODO: Add _getDestinationItemIndex()
  // int _getDestinationItemIndex(int rawIndex) {
  //   // native 광고 index가 포함되어 있기 때문에, 그 이후 인덱스는 -1씩 줄여줘야 한다.
  //   if (_ad_odd != null && isLoaded1 == true) {
  //     return rawIndex - 1;
  //   }
  //   return rawIndex;
  // }

  // Widget nativeAdWidget(int idx) {
  //   return Container(
  //     height: 80.0,
  //     margin:
  //         EdgeInsets.fromLTRB(defaultSize, 0, defaultSize, defaultSize * 0.5),
  //     decoration: BoxDecoration(
  //         color: kPrimaryLightBlackColor,
  //         borderRadius: BorderRadius.all(Radius.circular(8))),
  //     child: AdWidget(
  //       ad: _ad_odd!,
  //     ),
  //   );
  // }

  @override
  void initState() {
    songList = Provider.of<MusicSearchItemLists>(context, listen: false)
        .initalMusicbookList;
    super.initState();
    // TODO: Create a NativeAd instance
    // _ad_odd = NativeAd(
    //   adUnitId: Search_Native_UNIT_ID_ODD[Platform.isIOS ? 'ios' : 'android']!,
    //   factoryId: 'listTile',
    //   request: AdRequest(),
    //   listener: NativeAdListener(
    //     onAdLoaded: (ad) {
    //       setState(() {
    //         _ad_odd = ad as NativeAd;
    //         isLoaded1 = true;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       ad.dispose();
    //       print('Ad load failed (code=${error.code} message=${error.message})');
    //     },
    //   ),
    // );

    // _ad_odd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return (Provider.of<NoteData>(context, listen: false)
            .controller
            .text
            .isEmpty)
        ? ListView.builder(
            padding: EdgeInsets.only(bottom: screenHeight * 0.3),
            itemCount: songList.length,
            itemBuilder: (context, index) {
              String songNumber = songList[index].songNumber;
              String songTitle = songList[index].title;
              String singer = songList[index].singer;
              Set<Note> entireNote =
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .entireNote;
              Note? note;
              for (Note e in entireNote) {
                if (e.tj_songNumber == songNumber) {
                  note = e;
                }
              }
              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Card(
                  margin: EdgeInsets.fromLTRB(
                      defaultSize, 0, defaultSize, defaultSize * 0.5),
                  color: kPrimaryLightBlackColor,
                  elevation: 1,
                  child: ListTile(
                      leading: SizedBox(
                        width: defaultSize * 6.5,
                        child: Center(
                          child: (index == 0)
                              ? Image(
                                  width: defaultSize * 4,
                                  height: defaultSize * 4,
                                  image: AssetImage('assets/images/first.png'),
                                )
                              : (index == 1)
                                  ? Image(
                                      width: defaultSize * 4,
                                      height: defaultSize * 4,
                                      image: AssetImage(
                                          'assets/images/second.png'),
                                    )
                                  : (index == 2)
                                      ? Image(
                                          width: defaultSize * 4,
                                          height: defaultSize * 4,
                                          image: AssetImage(
                                              'assets/images/third.png'),
                                        )
                                      : Text(
                                          (index + 1).toString() + "위",
                                          style: TextStyle(
                                            color: kMainColor,
                                            fontSize: defaultSize * 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                        ),
                      ),
                      title: Text(
                        songTitle,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        singer,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: kPrimaryLightWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 1.2),
                      ),
                      trailing: IntrinsicWidth(
                        child: Row(
                          children: [
                            SizedBox(
                              width: defaultSize * 5,
                              child: Center(
                                child: Text(
                                  songNumber,
                                  style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: defaultSize * 1.2),
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: kPrimaryWhiteColor),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (note != null)
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SongDetailScreen(note: note!)));
                      }),
                ),
              );
            },
          )
        : widget.musicList.foundItems.isNotEmpty
            ? ListView.builder(
                itemCount: widget.musicList.foundItems.length,
                itemBuilder: (context, index) {
                  final item = widget.musicList.foundItems[index];
                  String songNumber = item.songNumber;
                  String title = item.title;
                  String singer = item.singer;

                  return GestureDetector(
                    onTap: () {
                      if (widget.musicList.tabIndex == 1) {
                        Set<Note> entireNote =
                            Provider.of<MusicSearchItemLists>(context,
                                    listen: false)
                                .entireNote;
                        Note? note;
                        for (Note e in entireNote) {
                          if (e.tj_songNumber == songNumber) {
                            note = e;
                          }
                        }
                        if (note != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SongDetailScreen(note: note!)));
                        }
                      } else {
                        Provider.of<NoteData>(context, listen: false)
                            .showAddNoteDialogWithInfo(context,
                                isTj: false,
                                songNumber: songNumber,
                                title: title,
                                singer: singer);
                      }
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
                              child: Text("${songNumber}",
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
                        ),
                        if (widget.musicList.tabIndex == 1)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chevron_right,
                                  color: kPrimaryWhiteColor),
                              Text("상세정보",
                                  style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontSize: defaultSize))
                            ],
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

  @override
  void dispose() {
    super.dispose();
  }
}
