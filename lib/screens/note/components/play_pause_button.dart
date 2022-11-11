import 'package:conopot/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

///
class PlayPauseButtonBar extends StatefulWidget {
  YoutubePlayerController controller;
  PlayPauseButtonBar({required this.controller});
  @override
  State<PlayPauseButtonBar> createState() => _PlayPauseButtonBarState();
}

class _PlayPauseButtonBarState extends State<PlayPauseButtonBar> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: kPrimaryWhiteColor,),
          onPressed: widget.controller.previousVideo,
        ),
        YoutubeValueBuilder(
          builder: (context, value) {
            return IconButton(
              icon: Icon(
                value.playerState == PlayerState.playing
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                value.playerState == PlayerState.playing
                    ? widget.controller.pauseVideo()
                    : widget.controller.playVideo();
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: kPrimaryWhiteColor,),
          onPressed: widget.controller.nextVideo,
        ),
      ],
    );
  }
}