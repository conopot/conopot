import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
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

  // Map<String, String> Search_Native_UNIT_ID = {
  //   'android': 'ca-app-pub-1461012385298546/5670829461',
  //   'ios': 'ca-app-pub-1461012385298546/4166176101',
  // };

  // // TODO: Add _kAdIndex
  // static final _kAdIndex = 4;

  // // TODO: Add a native ad instance
  // NativeAd? _ad;

  // // TODO: Add _getDestinationItemIndex()
  // int _getDestinationItemIndex(int rawIndex) {
  //   if (rawIndex >= _kAdIndex && _ad != null) {
  //     return rawIndex - 1;
  //   }
  //   return rawIndex;
  // }

  @override
  void initState() {
    super.initState();

    // TODO: Create a NativeAd instance
    // _ad = NativeAd(
    //   adUnitId: Search_Native_UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
    //   factoryId: 'listTile',
    //   request: AdRequest(),
    //   listener: NativeAdListener(
    //     onAdLoaded: (ad) {
    //       print('Native Ad load Success ${ad.responseInfo}');
    //       print('Native Ad load Success ${ad.adUnitId}');
    //       setState(() {
    //         _ad = ad as NativeAd;
    //       });
    //     },
    //     onAdFailedToLoad: (ad, error) {
    //       // Releases an ad resource when it fails to load
    //       ad.dispose();
    //       print('Ad load failed (code=${error.code} message=${error.message})');
    //     },
    //   ),
    // );

    // if (_ad != null) _ad!.load();
  }

  @override
  Widget build(BuildContext context) {
    return widget.musicList.foundItems.isNotEmpty
        ? ListView.builder(
            itemCount: widget.musicList.foundItems.length,
            itemBuilder: (context, index) {
              // TODO: Get adjusted item index from _getDestinationItemIndex()
              final item = widget.musicList.foundItems[index];
              String songNumber = item.songNumber;
              String title = item.title;
              String singer = item.singer;

              return GestureDetector(
                onTap: () {
                  if (widget.musicList.tabIndex == 1) {
                    Provider.of<NoteData>(context, listen: false)
                        .showAddNoteDialogWithInfo(context,
                            isTj: true,
                            songNumber: songNumber,
                            title: title,
                            singer: singer);
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
