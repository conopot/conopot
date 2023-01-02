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
import 'package:toast/toast.dart';

class NoteSearchList extends StatefulWidget {
  final MusicSearchItemLists musicList;
  const NoteSearchList({super.key, required this.musicList});

  @override
  State<NoteSearchList> createState() => _NoteSearchListState();
}

class _NoteSearchListState extends State<NoteSearchList> {
  double defaultSize = SizeConfig.defaultSize;

  // bool isLoaded1 = false;

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

  // // Native 광고 위치
  // static final _kAdIndex = 0;
  // // TODO: Add a native ad instance
  // NativeAd? _ad_odd;

  // // TODO: Add _getDestinationItemIndex()
  // int _getDestinationItemIndex(int rawIndex) {
  //   // native 광고 index가 포함되어 있기 때문에, 그 이후 인덱스는 -1씩 줄여줘야 한다.
  //   if (isLoaded1 == true) {
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
    // TODO: implement initState
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

  Widget _ListView(BuildContext context) {
    return widget.musicList.foundItems.isNotEmpty
        ? Consumer<NoteData>(
            builder: (context, notedata, child) => Expanded(
              child: ListView.builder(
                  itemCount: widget.musicList.foundItems.length,
                  itemBuilder: (context, index) {
                    String songNumber =
                        widget.musicList.foundItems[(index)].songNumber;
                    String title = widget.musicList.foundItems[(index)].title;
                    String singer = widget.musicList.foundItems[(index)].singer;
                    // int pitchNum =
                    //     widget.musicList.foundItems[(index)].pitchNum;

                    return Container(
                      margin: EdgeInsets.fromLTRB(
                          defaultSize, 0, defaultSize, defaultSize * 0.5),
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<NoteData>(context, listen: false)
                              .showAddNoteDialog(context, songNumber, title);
                          //!event: 곡 추가 뷰 - 리스트 클릭 시
                          // Analytics_config().addViewSongClickEvent(widget
                          //     .musicList.combinedFoundItems[index].tj_title);
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
                                    SizedBox(
                                      height: defaultSize * 0.5,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: defaultSize * 4.5,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '${songNumber}',
                                              style: TextStyle(
                                                color: kMainColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: defaultSize * 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (widget
                                                .musicList
                                                .combinedFoundItems[(index)]
                                                .pitchNum !=
                                            0) ...[
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: defaultSize * 0.3),
                                            ],
                                          )
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: defaultSize * 1.5),
                              SizedBox(
                                  width: defaultSize * 2.1,
                                  height: defaultSize * 1.9,
                                  child: SvgPicture.asset(
                                      "assets/icons/listButton.svg")),
                            ],
                          ),
                        ),
                      ),
                    );
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
    ToastContext().init(context);
    return _ListView(context);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
