import 'package:conopot/config/constants.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/screens/musicBook/components/search_bar.dart';
import 'package:conopot/screens/musicBook/components/search_list.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:provider/provider.dart';

class MusicBookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double widthSize = SizeConfig.screenWidth / 10;

    return Consumer<MusicSearchItemLists>(
      builder: (
        context,
        musicList,
        child,
      ) =>
          DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.black),
            automaticallyImplyLeading: false, // back button 숨기기 위함
            centerTitle: true,

            title: TabBar(
              isScrollable: true,
              onTap: (index) {
                musicList.changeTabIndex(index: index + 1);
              },
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Color(0xFF7B61FF),
              tabs: [
                Text(
                  'TJ',
                  style: TextStyle(
                    color: (musicList.tabIndex == 1)
                        ? kTextColor
                        : kTextLightColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '금영',
                  style: TextStyle(
                    color: (musicList.tabIndex == 2)
                        ? kTextColor
                        : kTextLightColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  SearchBar(musicList: musicList),
                  SearchList(musicList: musicList),
                ],
              ),
              Column(
                children: [
                  SearchBar(musicList: musicList),
                  SearchList(musicList: musicList),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
