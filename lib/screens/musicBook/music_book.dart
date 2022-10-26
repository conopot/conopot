import 'dart:ui';

import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/musicBook/components/musicbook_search_bar.dart';
import 'package:conopot/screens/musicBook/components/musicbook_search_list.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:provider/provider.dart';

class MusicBookScreen extends StatefulWidget {
  @override
  State<MusicBookScreen> createState() => _MusicBookScreenState();
}

class _MusicBookScreenState extends State<MusicBookScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: Text(
              "노래방 책",
              style: TextStyle(fontWeight: FontWeight.w700),
            )),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.transparent),
                    Spacer(),
                    TabBar(
                      onTap: (index) {
                        Provider.of<MusicSearchItemLists>(context,
                                listen: false)
                            .changeTabIndex(index: index + 1);
                        Provider.of<NoteData>(context, listen: false)
                            .controller
                            .text = "";
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      controller: _tabController,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: kMainColor,
                      labelColor: kPrimaryWhiteColor,
                      unselectedLabelColor: kPrimaryLightGreyColor,
                      tabs: [
                        Text(
                          'TJ',
                          style: TextStyle(
                            fontSize: defaultSize * 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '금영',
                          style: TextStyle(
                            fontSize: defaultSize * 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(defaultSize * 3),
                                child: Material(
                                  color: kDialogColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: EdgeInsets.all(defaultSize * 1.5),
                                    child: IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("가사 검색시 주의사항 안내",
                                                  style: TextStyle(
                                                      color: kPrimaryWhiteColor,
                                                      fontSize:
                                                          defaultSize * 1.7)),
                                            ],
                                          ),
                                          SizedBox(height: defaultSize * 2),
                                          Text(
                                              "1. 가사 입력시 한글의 경우 띄어쓰기를 정확히 해주세요.",
                                              style: TextStyle(
                                                  color: kPrimaryWhiteColor,
                                                  fontSize: defaultSize * 1.4)),
                                          Text(
                                              "ex) '또모르지내마음이' (x) -> '또 모르지 내 마음이' (o)",
                                              style: TextStyle(
                                                  color: kPrimaryWhiteColor,
                                                  fontSize: defaultSize * 1.4)),
                                          SizedBox(height: defaultSize * 1.5),
                                          Text(
                                              "2. 입력창에 가사를 입력한 후 키보드의 확인 버튼 또는 완료 버튼을 눌러주세요.",
                                              style: TextStyle(
                                                  color: kPrimaryWhiteColor,
                                                  fontSize: defaultSize * 1.4)),
                                          SizedBox(height: defaultSize * 3)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(Icons.info_outline, color: kMainColor)
                    ),
                  ],
                ),
              ),
              SearchBar(musicList: musicList),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    SearchList(musicList: musicList),
                    SearchList(musicList: musicList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
