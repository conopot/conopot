// import 'dart:io';

// import 'package:conopot/config/constants.dart';
// import 'package:conopot/config/size_config.dart';
// import 'package:conopot/models/youtube_player_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// class MiniYoutubeVideoPlayer extends StatefulWidget {
//   late List<String> videoIdList;
//   final Function() notifyParent;
//   MiniYoutubeVideoPlayer({Key? key, required this.videoIdList, required this.notifyParent})
//       : super(key: key);

//   @override
//   State<MiniYoutubeVideoPlayer> createState() => _MiniYoutubeVideoPlayerState();
// }

// class _MiniYoutubeVideoPlayerState extends State<MiniYoutubeVideoPlayer> {
//   late YoutubePlayerController _controller = Provider.of<YoutubePlayerProvider>(context, listen: false).controller;
//   bool _isPlaying = true;
//   late var index;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double defaultSize = SizeConfig.defaultSize;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         SizedBox(
//             height: defaultSize * 10,
//             width: defaultSize * 15,
//             child:
//                 YoutubePlayer(aspectRatio: 16 / 8.5, controller: _controller)),
//         Spacer(),
//         SizedBox(width: defaultSize),
//         GestureDetector(
//             onTap: () {
//               _controller.previousVideo();
//             },
//             child: Icon(Icons.skip_previous, color: kPrimaryWhiteColor)),
//         SizedBox(width: defaultSize),
//         (_isPlaying)
//             ? GestureDetector(
//                 onTap: () async {
//                   _controller.stopVideo();
//                   setState(() {
//                     _isPlaying = false;
//                   });
//                 },
//                 child: Icon(Icons.pause, color: kPrimaryWhiteColor))
//             : GestureDetector(
//                 onTap: () {
//                   _controller.playVideo();
//                   setState(() {
//                     _isPlaying = true;
//                   });
//                 },
//                 child: Icon(Icons.play_arrow, color: kPrimaryWhiteColor)),
//         SizedBox(width: defaultSize),
//         GestureDetector(
//             onTap: () async  {
//               await _controller.nextVideo();
//             },
//             child: Icon(
//               Icons.skip_next,
//               color: kPrimaryWhiteColor,
//             )),
//         SizedBox(width: defaultSize),
//         GestureDetector(
//             onTap: () {
//               Provider.of<YoutubePlayerProvider>(context, listen: false).closePlayer();
//               widget.notifyParent();
//             },
//             child: Icon(
//               Icons.close,
//               color: kPrimaryWhiteColor,
//             )),
//         SizedBox(width: defaultSize),
//       ],
//     );
//   }
// }
