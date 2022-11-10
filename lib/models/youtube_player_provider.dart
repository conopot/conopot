import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'note.dart';

class YoutubePlayerProvider extends ChangeNotifier {
  bool isHome = true;
  bool isPlaying = false;
  Map<String, String> videoMap = {};
  List<String> videoList = [];

  YoutubePlayerController controller =  YoutubePlayerController();

  void youtubeInit(List<Note> notes, Map<String, String> youtubeURL) {
    for (var note in notes) {
      videoList.add(youtubeURL[note.tj_songNumber]!);
      videoMap[note.tj_songNumber] = youtubeURL[note.tj_songNumber]!;
    }
    if (videoList.length == 1) {
      controller = YoutubePlayerController.fromVideoId(videoId: videoList[0]);
    }
    if (videoList.length >= 2) {
      controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: false,
          loop: true,
        ),
      )..onInit = () {
          controller.cuePlaylist(list: videoList, listType: ListType.playlist);
        };
    }
  }

  void closePlayer() {
    isPlaying = false;
    notifyListeners();
  }

  void enterNoteDetailScreen() {
    isHome = false;
    notifyListeners();
  }

  void leaveNoteDetailScreen() async {
    isHome = true;
    var state = await controller.playerState;
    if (state == PlayerState.playing) {
      isPlaying = true;
    }
    notifyListeners();
  }

  void playMiniPlayer() {
    isPlaying = true;
    notifyListeners();
  }
}
