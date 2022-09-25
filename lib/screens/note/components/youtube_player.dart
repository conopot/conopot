import 'dart:io';

import 'package:conopot/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  late String videoId;
  YoutubeVideoPlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late final _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(videoId: widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(aspectRatio: 16 / 8.5,controller: _controller);
  }
}
