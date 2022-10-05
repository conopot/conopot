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

  bool isLoaded1 = false, isLoaded2 = false;

  Map<String, String> Search_Native_UNIT_ID_ODD = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-7139143792782560/3104068385',
          'ios': 'ca-app-pub-1461012385298546/416617610',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/2247696110',
          'ios': 'ca-app-pub-3940256099942544/3986624511',
        };

  Map<String, String> Search_Native_UNIT_ID_EVEN = kReleaseMode
      ? {
          //release 모드일때 (실기기 사용자)
          'android': 'ca-app-pub-7139143792782560/3200544377',
          'ios': 'ca-app-pub-1461012385298546/416617610',
        }
      : {
          'android': 'ca-app-pub-3940256099942544/2247696110',
          'ios': 'ca-app-pub-3940256099942544/3986624511',
        };

  // Native 광고 위치
  static final _kAdIndex = 15;
  // TODO: Add a native ad instance
  NativeAd? _ad_odd, _ad_even;

  // TODO: Add _getDestinationItemIndex()
  int _getDestinationItemIndex(int rawIndex) {
    // native 광고 index가 포함되어 있기 때문에, 그 이후 인덱스는 -1씩 줄여줘야 한다.
    if (_ad_odd != null &&
        _ad_even != null &&
        isLoaded1 == true &&
        isLoaded2 == true) {
      return rawIndex - 1 - (rawIndex ~/ _kAdIndex);
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
        ad: (idx % 2 == 0) ? _ad_even! : _ad_odd!,
      ),
    );
  }

  @override
  void initState() {
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

    _ad_even = NativeAd(
      adUnitId: Search_Native_UNIT_ID_EVEN[Platform.isIOS ? 'ios' : 'android']!,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad_even = ad as NativeAd;
            isLoaded2 = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _ad_odd!.load();
    _ad_even!.load();
  }

  @override
  Widget build(BuildContext context) {
    return widget.musicList.foundItems.isNotEmpty
        ? ListView.builder(
            itemCount: widget.musicList.foundItems.length +
                ((_ad_odd != null && _ad_even != null && isLoaded1 && isLoaded2)
                    ? (widget.musicList.foundItems.length ~/ _kAdIndex) + 1
                    : 0),
            itemBuilder: (context, index) {
              if ((index % _kAdIndex == 0) &&
                  (_ad_odd != null &&
                      _ad_even != null &&
                      isLoaded1 &&
                      isLoaded2)) {
                return Container(
                  height: 80.0,
                  margin: EdgeInsets.fromLTRB(
                      defaultSize, 0, defaultSize, defaultSize * 0.5),
                  decoration: BoxDecoration(
                      color: kPrimaryLightBlackColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: nativeAdWidget(index),
                );
              } else {
                // TODO: Get adjusted item index from _getDestinationItemIndex()
                final item = widget
                    .musicList.foundItems[_getDestinationItemIndex(index)];
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
              }
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
    // TODO: Dispose a NativeAd object
    _ad_odd?.dispose();
    _ad_even?.dispose();

    super.dispose();
  }
}
