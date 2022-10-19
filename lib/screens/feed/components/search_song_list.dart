import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class SearchSongList extends StatefulWidget {
  final MusicSearchItemLists musicList;
  const SearchSongList({super.key, required this.musicList});

  @override
  State<SearchSongList> createState() => _SearchSongListState();
}

class _SearchSongListState extends State<SearchSongList> {
  double defaultSize = SizeConfig.defaultSize;

  bool isLoaded1 = false;

  Map<String, String> Search_Native_UNIT_ID_ODD = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-7139143792782560/3104068385',
          'ios': 'ca-app-pub-7139143792782560/5971824166',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/2247696110',
          'ios': 'ca-app-pub-3940256099942544/3986624511',
        };

  // Native 광고 위치
  static final _kAdIndex = 0;
  // TODO: Add a native ad instance
  NativeAd? _ad_odd;

  // TODO: Add _getDestinationItemIndex()
  int _getDestinationItemIndex(int rawIndex) {
    // native 광고 index가 포함되어 있기 때문에, 그 이후 인덱스는 -1씩 줄여줘야 한다.
    if (isLoaded1 == true) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  Widget nativeAdWidget(int idx) {
    return Container(
      height: 80.0,
      margin:
          EdgeInsets.fromLTRB(defaultSize, 0, defaultSize, defaultSize * 0.5),
      decoration: BoxDecoration(
          color: kPrimaryLightBlackColor,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: AdWidget(
        ad: _ad_odd!,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // TODO: Create a NativeAd instance
    _ad_odd = NativeAd(
      adUnitId: Search_Native_UNIT_ID_ODD[Platform.isIOS ? 'ios' : 'android']!,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad_odd = ad as NativeAd;
            isLoaded1 = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad_odd!.load();
  }

  Widget _ListView(BuildContext context) {
    return widget.musicList.combinedFoundItems.isNotEmpty
        ? Consumer<NoteData>(
            builder: (context, notedata, child) => Expanded(
              child: ListView.builder(
                  itemCount: widget.musicList.combinedFoundItems.length +
                      ((isLoaded1) ? 1 : 0),
                  itemBuilder: (context, index) {
                    if ((index == 0) && (isLoaded1)) {
                      return Container(
                        height: 80.0,
                        margin: EdgeInsets.fromLTRB(
                            defaultSize, 0, defaultSize, defaultSize * 0.5),
                        decoration: BoxDecoration(
                            color: kPrimaryGreyColor,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: nativeAdWidget(index),
                      );
                    } else {
                      String songNumber = widget
                          .musicList
                          .combinedFoundItems[_getDestinationItemIndex(index)]
                          .tj_songNumber;
                      String title = widget
                          .musicList
                          .combinedFoundItems[_getDestinationItemIndex(index)]
                          .tj_title;
                      String singer = widget
                          .musicList
                          .combinedFoundItems[_getDestinationItemIndex(index)]
                          .tj_singer;
                      int pitchNum = widget
                          .musicList
                          .combinedFoundItems[_getDestinationItemIndex(index)]
                          .pitchNum;

                      return Container(
                        margin: EdgeInsets.fromLTRB(
                            defaultSize, 0, defaultSize, defaultSize * 0.5),
                        child: GestureDetector(
                          onTap: () {
                            Provider.of<NoteData>(context, listen: false)
                                .showAddListSongDialog(context, songNumber, title);
                          },
                          child: Container(
                            width: defaultSize * 35.5,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: kPrimaryLightBlackColor),
                            padding: EdgeInsets.all(defaultSize * 1.5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      SizedBox(
                                        height: defaultSize * 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: defaultSize * 1.5),
                                SizedBox(
                                    width: defaultSize * 2.1,
                                    height: defaultSize * 1.9,
                                    child: SvgPicture.asset(
                                        "assets/icons/listButton.svg", color: kMainColor,)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }),
            ),
          )
        : Expanded(
            child: Center(
              child: Text(
                '검색 결과가 없습니다',
                style: TextStyle(
                  fontSize: defaultSize * 1.8,
                  fontWeight: FontWeight.w300,
                  color: kPrimaryWhiteColor,
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return _ListView(context);
  }

  @override
  void dispose() {
    // TODO: Dispose a NativeAd object
    _ad_odd?.dispose();

    super.dispose();
  }
}
