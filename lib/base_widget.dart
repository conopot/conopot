import 'package:conopot/config/constants.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/persistent_youtube_player.dart';
import 'package:conopot/screens/note/components/play_pause_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'config/size_config.dart';
import 'models/youtube_player_provider.dart';

class BaseWidget extends StatefulWidget {
  final Widget child;
  BaseWidget({required this.child});

  @override
  State<BaseWidget> createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {
  late YoutubePlayerController _controller;
  late var playingIndex;

  @override
  void initState() {
    Provider.of<YoutubePlayerProvider>(context, listen: false).refresh =
        refresh;
    super.initState();
  }

  void getIndex() async {
    playingIndex = await _controller.playlistIndex;
  }

  @override
  Widget build(BuildContext context) {
    var title = "";
    var singer = "";
    if (Provider.of<NoteData>(context, listen: false).notes.isNotEmpty) {
      title = Provider.of<NoteData>(context, listen: false)
          .notes[Provider.of<YoutubePlayerProvider>(context, listen: false)
              .playingIndex]
          .tj_title;
      singer = Provider.of<NoteData>(context, listen: false)
          .notes[Provider.of<YoutubePlayerProvider>(context, listen: false)
              .playingIndex]
          .tj_singer;
    }
    var appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    var navigationHeight =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Column(
            children: [
              SizedBox(height: appBarHeight),
              if (Provider.of<YoutubePlayerProvider>(context, listen: false)
                  .isMini) ...[Spacer()],
              Visibility(
                visible:
                    Provider.of<YoutubePlayerProvider>(context, listen: false)
                        .isHome,
                child: Container(
                  decoration: BoxDecoration(color: kPrimaryBlackColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(children: [
                        SizedBox(
                            height: Provider.of<YoutubePlayerProvider>(context,
                                        listen: true)
                                    .isMini
                                ? defaultSize * 0.01
                                : SizeConfig.defaultSize * 20,
                            width: Provider.of<YoutubePlayerProvider>(context,
                                        listen: true)
                                    .isMini
                                ? defaultSize * 0.01
                                : SizeConfig.screenWidth,
                            child: PersistentYoutubeVideoPlayer()),
                        if (Provider.of<YoutubePlayerProvider>(context,
                                listen: false)
                            .isMini)
                          AbsorbPointer(
                            child: SizedBox(
                              height: 6.5 * defaultSize,
                              width: 10 * defaultSize,
                              child: Image.network(
                                  "${Provider.of<YoutubePlayerProvider>(context, listen: false).getThumbnail()}"),
                            ),
                          )
                      ]),
                      if (Provider.of<YoutubePlayerProvider>(context,
                              listen: true)
                          .isMini) ...[
                        SizedBox(width: defaultSize),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${title}",
                                  style: TextStyle(
                                      fontSize: defaultSize * 1.1,
                                      fontWeight: FontWeight.w500,
                                      color: kPrimaryWhiteColor,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  "${singer}",
                                  style: TextStyle(
                                      fontSize: defaultSize * 0.9,
                                      fontWeight: FontWeight.w300,
                                      color: kPrimaryLightWhiteColor,
                                      overflow: TextOverflow.ellipsis),
                                )
                              ]),
                        ),
                        GestureDetector(
                            onTap: () {
                              Provider.of<YoutubePlayerProvider>(context,
                                      listen: false)
                                  .previousVideo();
                            },
                            child: Icon(Icons.skip_previous,
                                color: kPrimaryWhiteColor)),
                        SizedBox(width: defaultSize),
                        (Provider.of<YoutubePlayerProvider>(context,
                                    listen: false)
                                .isPlaying)
                            ? GestureDetector(
                                onTap: () {
                                  Provider.of<YoutubePlayerProvider>(context,
                                          listen: false)
                                      .stopVideo();
                                  // setState(() {
                                  //   _isPlaying = false;
                                  // });
                                },
                                child: Icon(Icons.pause,
                                    color: kPrimaryWhiteColor))
                            : GestureDetector(
                                onTap: () async {
                                  Provider.of<YoutubePlayerProvider>(context,
                                          listen: false)
                                      .playVideo();
                                  // setState(() {
                                  //   _isPlaying = true;
                                  // });
                                },
                                child: Icon(Icons.play_arrow,
                                    color: kPrimaryWhiteColor)),
                        SizedBox(width: defaultSize),
                        GestureDetector(
                            onTap: () {
                              Provider.of<YoutubePlayerProvider>(context,
                                      listen: false)
                                  .nextVideo();
                            },
                            child: Icon(
                              Icons.skip_next,
                              color: kPrimaryWhiteColor,
                            )),
                        SizedBox(width: defaultSize),
                        //   GestureDetector(
                        //       onTap: () {
                        //         Provider.of<YoutubePlayerProvider>(context,
                        //                 listen: false)
                        //             .closePlayer();
                        //         setState(() {});
                        //       },
                        //       child: Icon(
                        //         Icons.close,
                        //         color: kPrimaryWhiteColor,
                        //       )),
                        // SizedBox(width: defaultSize),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: navigationHeight),
            ],
          )
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
