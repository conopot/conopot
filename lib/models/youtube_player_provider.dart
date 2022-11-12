import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'note.dart';

class YoutubePlayerProvider extends ChangeNotifier {
  bool isHome = false;
  bool isMini = true;
  bool isPlaying = false;
  int playingIndex = 0;
  List<String> videoList = [];
  late Function reload;
  late Function refresh;

  YoutubePlayerController controller = YoutubePlayerController();

  void youtubeInit(List<Note> notes, Map<String, String> youtubeURL) {
    videoList = [];
    for (var note in notes) {
      videoList.add(youtubeURL[note.tj_songNumber]!);
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
      )..onInit = () async {
          await controller.loadPlaylist(list: videoList);
          if (videoList.isNotEmpty) {
            print("여기: ${videoList}");
            playingIndex = 0;
            firstStart();
            refresh();
          }
        };
    }
  }

  void load() {
    playingIndex = 0;
    notifyListeners();
  }

  void removeAllVideoList() {
    playingIndex = 0;
    videoList = [];
    notifyListeners();
  }

  void addVideoId(Note note, Map<String, String> youtubeURL) {
    videoList.add(youtubeURL[note.tj_songNumber]!);
    notifyListeners();
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
    if (playingIndex - 1 >= 0) playingIndex -= 1;
    notifyListeners();
  }

  void nextVideo() {
    controller.nextVideo();
    isPlaying = true;
    if (videoList.length > playingIndex + 1) playingIndex += 1;
    notifyListeners();
  }

  void enterNoteDetailScreen(int index) {
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

  void changePlayingIndex(int index) async {
    if (playingIndex != index) {
      print("여기 : ${index}");
      playingIndex = index;
      closePlayer();
      firstStart();
      controller.playVideoAt(index);
      var number = await controller.playlist;
      print("여기 : ${number.length}");
      notifyListeners();
    }
  }

  void downPlayingIndex() {
    if (playingIndex - 1 >= 0) {
      playingIndex -= 1;
    }
    notifyListeners();
  }
}
