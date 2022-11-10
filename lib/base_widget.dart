import 'package:conopot/config/constants.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/persistent_youtube_player.dart';
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
  bool _isPlaying = false;

  @override
  void initState() {
    _controller =
        Provider.of<YoutubePlayerProvider>(context, listen: false).controller;
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
                  .isHome) ...[Spacer()],
              Visibility(
                visible: !Provider.of<YoutubePlayerProvider>(context,
                            listen: false)
                        .isHome ||
                    (Provider.of<YoutubePlayerProvider>(context, listen: false)
                            .isHome &&
                        Provider.of<YoutubePlayerProvider>(context,
                                listen: false)
                            .isPlaying),
                child: Container(
                  decoration: BoxDecoration(color: kPrimaryBlackColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: Provider.of<YoutubePlayerProvider>(context,
                                      listen: true)
                                  .isHome
                              ? 6.5 * defaultSize
                              : SizeConfig.defaultSize * 20,
                          width: Provider.of<YoutubePlayerProvider>(context,
                                      listen: true)
                                  .isHome
                              ? 10 * defaultSize
                              : SizeConfig.screenWidth,
                          child: PersistentYoutubeVideoPlayer()),
                      if (Provider.of<YoutubePlayerProvider>(context,
                              listen: true)
                          .isHome) ...[
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
                              _controller.previousVideo();
                            },
                            child: Icon(Icons.skip_previous,
                                color: kPrimaryWhiteColor)),
                        SizedBox(width: defaultSize),
                        (_isPlaying)
                            ? GestureDetector(
                                onTap: () async {
                                  _controller.stopVideo();
                                  setState(() {
                                    _isPlaying = false;
                                  });
                                },
                                child: Icon(Icons.pause,
                                    color: kPrimaryWhiteColor))
                            : GestureDetector(
                                onTap: () {
                                  _controller.playVideo();
                                  setState(() {
                                    _isPlaying = true;
                                  });
                                },
                                child: Icon(Icons.play_arrow,
                                    color: kPrimaryWhiteColor)),
                        SizedBox(width: defaultSize),
                        GestureDetector(
                            onTap: () async {
                              await _controller.nextVideo();
                            },
                            child: Icon(
                              Icons.skip_next,
                              color: kPrimaryWhiteColor,
                            )),
                        SizedBox(width: defaultSize),
                        GestureDetector(
                            onTap: () {
                              Provider.of<YoutubePlayerProvider>(context,
                                      listen: false)
                                  .closePlayer();
                            },
                            child: Icon(
                              Icons.close,
                              color: kPrimaryWhiteColor,
                            )),
                        SizedBox(width: defaultSize),
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
}
