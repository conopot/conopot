import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/debounce.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/screens/feed/components/music_search_bar.dart';
import 'package:conopot/screens/feed/components/search_song_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistSearchSongScreen extends StatefulWidget {
  const PlaylistSearchSongScreen({super.key});

  @override
  State<PlaylistSearchSongScreen> createState() => _PlaylistSearchSongScreenState();
}

class _PlaylistSearchSongScreenState extends State<PlaylistSearchSongScreen> {

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
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(defaultSize * 4),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BackButton(
                            color: kPrimaryWhiteColor,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Expanded(child: MusicSearchBar(musicList: musicList))
                        ]),
                    centerTitle: false,
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: defaultSize * 1.8),
                      SearchSongList(
                        musicList: musicList,
                      ),
                    ],
                  ),
                )));
  }
}
