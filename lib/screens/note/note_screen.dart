import 'dart:io';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/banner.dart';
import 'package:conopot/screens/note/components/empty_note_list.dart';
import 'package:conopot/screens/note/components/note_list.dart';
import 'package:conopot/screens/user/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'add_note_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

// 메인화면 - 애창곡 노트
class _NoteScreenState extends State<NoteScreen> {
  double defaultSize = SizeConfig.defaultSize;

  // Map<String, String> Search_Native_UNIT_ID = {
  //   'android': 'ca-app-pub-1461012385298546/5670829461',
  //   'ios': 'ca-app-pub-1461012385298546/4166176101',
  // };

  // // TODO: Add _kAdIndex
  // static final _kAdIndex = 2;

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
    Analytics_config().noteViewPageViewEvent();

    return Consumer<NoteData>(
      builder: (context, noteData, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "애창곡 노트",
            style: TextStyle(
              color: kMainColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserScreen()));
              },
            ),
          ],
        ),
        floatingActionButton: (!noteData.notes.isEmpty)
            ? Container(
                margin: EdgeInsets.fromLTRB(
                    0, 0, defaultSize * 0.5, defaultSize * 0.5),
                width: 72,
                height: 72,
                child: FittedBox(
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset('assets/icons/addButton.svg'),
                    onPressed: () {
                      Future.delayed(Duration.zero, () {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .initCombinedBook();
                      });
                      Analytics_config().noteViewEnterEvent();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNoteScreen(),
                        ),
                      );
                    },
                  ),
                ),
              )
            : null,
        body: Column(
          children: [
            CarouselSliderBanner(),
            if (noteData.notes.isEmpty) ...[
              EmptyNoteList()
            ] else ...[
              SizedBox(height: defaultSize),
              NoteList()
            ],
          ],
        ),
      ),
    );
  }
}
