import 'package:conopot/config/analytics_config.dart';
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
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    Analytics_config().musicBookScreenPageViewEvent();

    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          Scaffold(
        appBar: AppBar(
            // automaticallyImplyLeading: false, // back button 숨기기 위함
            centerTitle: false,
            title: Text("노래방 책")),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                onTap: (index) {
                  musicList.changeTabIndex(index: index + 1);
                },
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
              SearchBar(musicList: musicList),
              Expanded(
                child: TabBarView(
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
