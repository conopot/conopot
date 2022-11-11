import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'note.dart';

class YoutubePlayerProvider extends ChangeNotifier {
  bool isHome = false;
  bool isMini = true;
  bool isPlaying = false;
  int playingIndex = 0;
  Map<String, String> videoMap = {};
  List<String> videoList = [];
  late Function refresh;

  YoutubePlayerController controller = YoutubePlayerController();

  void youtubeInit(List<Note> notes, Map<String, String> youtubeURL) {
    for (var note in notes) {
      if (youtubeURL.isEmpty) continue;
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

  String getThumbnail() {
    if (videoList.isNotEmpty)
      return YoutubePlayerController.getThumbnail(
          videoId: videoList[playingIndex]);
    else
      return "";
  }

  void rebuild() {
    refresh();
  }

  void firstStart() {
    isHome = true;
  }

  void closePlayer() {
    isHome = false;
  }

  void stopVideo() async {
    await controller.stopVideo();
    isPlaying = false;
    notifyListeners();
  }

  void playVideo() async {
    await controller.playVideo();
    isPlaying = true;

    notifyListeners();
  }

  void previousVideo() {
    isPlaying = true;
    controller.previousVideo();
    if (playingIndex - 1 > 0) playingIndex -= 1;
    notifyListeners();
  }

  void nextVideo() {
    controller.nextVideo();
    isPlaying = true;
    if (videoList.length > playingIndex + 1) playingIndex += 1;
    notifyListeners();
  }

  void enterNoteDetailScreen() {
    isMini = false;
    notifyListeners();
  }

  void leaveNoteDetailScreen() async {
    isMini = true;
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

  void changePlayingIndex(int index) {
    if (playingIndex != index) {
      playingIndex = index;
      controller.playVideoAt(index);
      controller.stopVideo();
      notifyListeners();
    }
  }
}
