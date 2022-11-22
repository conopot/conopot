import 'package:conopot/config/constants.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/persistent_youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  YoutubePlayerController _controller = YoutubePlayerController();
  late var playingIndex;

  @override
  void initState() {
    Provider.of<YoutubePlayerProvider>(context, listen: false).refresh =
        refresh;
    _controller =
        Provider.of<YoutubePlayerProvider>(context, listen: false).controller;
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
      resizeToAvoidBottomInset: false,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    (Provider.of<YoutubePlayerProvider>(context, listen: false)
                            .videoList
                            .isEmpty)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                color: kPrimaryBlackColor,
                                height: defaultSize * 6,
                                child: Row(
                                  children: [
                                    SizedBox(width: defaultSize * 2),
                                    Icon(Icons.list, color: kPrimaryWhiteColor),
                                    SizedBox(width: defaultSize),
                                    Text(
                                      '곡 목록이 없습니다.',
                                      style: TextStyle(
                                          color: kPrimaryWhiteColor,
                                          fontWeight: FontWeight.w300,
                                          fontSize: defaultSize * 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : (Stack(children: [
                            SizedBox(
                                height: Provider.of<YoutubePlayerProvider>(
                                            context,
                                            listen: true)
                                        .isMini
                                    ? defaultSize * 6
                                    : SizeConfig.defaultSize * 20,
                                width: Provider.of<YoutubePlayerProvider>(
                                            context,
                                            listen: true)
                                        .isMini
                                    ? defaultSize * 15
                                    : SizeConfig.screenWidth,
                                child: PersistentYoutubeVideoPlayer(
                                    controller: _controller)),
                            // if (Provider.of<YoutubePlayerProvider>(context,
                            //         listen: false)
                            //     .isMini)
                            //   AbsorbPointer(
                            //     child: SizedBox(
                            //       height: 6.5 * defaultSize,
                            //       width: 10 * defaultSize,
                            //       child: Image.network(errorBuilder:
                            //           ((context, error, stackTrace) {
                            //         return SizedBox(
                            //             height: 6.5 * defaultSize,
                            //             width: 10 * defaultSize,
                            //             child: Image.asset(
                            //                 "assets/images/profile.png"));
                            //         ;
                            //       }), "${Provider.of<YoutubePlayerProvider>(context, listen: false).getThumbnail()}"),
                            //     ),
                            //   )
                          ])),
                    Expanded(
                      child: Container(
                        height: defaultSize * 6,
                        decoration: BoxDecoration(color: kPrimaryBlackColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (Provider.of<YoutubePlayerProvider>(context,
                                    listen: true)
                                .isMini) ...[
                              SizedBox(width: defaultSize),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${title}",
                                        style: TextStyle(
                                            fontSize: defaultSize,
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
                                        if (Provider.of<YoutubePlayerProvider>(
                                                context,
                                                listen: false)
                                            .videoList
                                            .isEmpty) {
                                          EasyLoading.showToast(
                                              '재생 가능한 곡이 없습니다.');
                                        }
                                        if (Provider.of<YoutubePlayerProvider>(
                                                context,
                                                listen: false)
                                            .videoList
                                            .isNotEmpty)
                                          Provider.of<YoutubePlayerProvider>(
                                                  context,
                                                  listen: false)
                                              .stopVideo();
                                      },
                                      child: Icon(Icons.pause,
                                          color: kPrimaryWhiteColor))
                                  : GestureDetector(
                                      onTap: () async {
                                        if (Provider.of<YoutubePlayerProvider>(
                                                context,
                                                listen: false)
                                            .videoList
                                            .isEmpty) {
                                          EasyLoading.showToast(
                                              '재생 가능한 곡이 없습니다.');
                                        }
                                        if (Provider.of<YoutubePlayerProvider>(
                                                context,
                                                listen: false)
                                            .videoList
                                            .isNotEmpty)
                                          Provider.of<YoutubePlayerProvider>(
                                                  context,
                                                  listen: false)
                                              .playVideo();
                                      },
                                      child: Icon(Icons.play_arrow,
                                          color: kPrimaryWhiteColor)),
                              SizedBox(width: defaultSize),
                              GestureDetector(
                                  onTap: () {
                                    if (Provider.of<YoutubePlayerProvider>(
                                            context,
                                            listen: false)
                                        .videoList
                                        .isEmpty) {
                                      EasyLoading.showToast('재생 가능한 곡이 없습니다.');
                                    }
                                    Provider.of<YoutubePlayerProvider>(context,
                                            listen: false)
                                        .nextVideo();
                                  },
                                  child: Icon(
                                    Icons.skip_next,
                                    color: kPrimaryWhiteColor,
                                  )),
                              SizedBox(width: defaultSize),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
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
    setState(() {
      _controller =
          Provider.of<YoutubePlayerProvider>(context, listen: false).controller;
    });
  }
}
