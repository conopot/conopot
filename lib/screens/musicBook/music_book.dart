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
                    Icon(Icons.help_outline, color: Colors.transparent),
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
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext cxt) {
                              return Align(
                                alignment: Alignment(1, -0.9),
                                child: Padding(
                                  padding: EdgeInsets.all(defaultSize),
                                  child: Material(
                                    color: kDialogColor.withOpacity(0.9),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: IntrinsicWidth(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Icon(Icons.line_style)),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    "test",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                        child: Icon(Icons.help_outline, color: kMainColor))
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
