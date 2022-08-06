import 'dart:convert';

import 'package:conopot/models/music_search_item.dart';
import 'package:flutter/services.dart';

class RecommendationItemList {
  //gender
  static List<MusicSearchItem> femaleHighList = [];
  static List<MusicSearchItem> femaleLowList = [];
  static List<MusicSearchItem> maleHighList = [];
  static List<MusicSearchItem> maleLowList = [];
  //genre
  static List<MusicSearchItem> balladeList = [];
  static List<MusicSearchItem> cartoonList = [];
  static List<MusicSearchItem> hiphopList = [];
  static List<MusicSearchItem> jpopList = [];
  static List<MusicSearchItem> popList = [];
  static List<MusicSearchItem> rnbList = [];
  //popular
  static List<MusicSearchItem> allTimeLegendList = [];
  //season
  static List<MusicSearchItem> springList = [];
  static List<MusicSearchItem> summerList = [];
  static List<MusicSearchItem> fallList = [];
  static List<MusicSearchItem> winterList = [];
  //tema
  static List<MusicSearchItem> duetList = [];
  static List<MusicSearchItem> excitedList = [];
  static List<MusicSearchItem> loveList = [];
  static List<MusicSearchItem> rainList = [];
  static List<MusicSearchItem> tiredList = [];

  // 추천곡 리스트 초기화
  void initRecommendationList() async {
    LineSplitter ls = new LineSplitter();
    List<String> textTitle = [
      'gender/female_high',
      'gender/female_low',
      'gender/male_high',
      'gender/male_low',
      'genre/ballade',
      'genre/cartoon',
      'genre/hiphop',
      'genre/jpop',
      'genre/pop',
      'genre/rnb',
      'popular/all_time_legend',
      'season/spring',
      'season/summer',
      'season/fall',
      'season/winter',
      'tema/duet',
      'tema/excited',
      'tema/love',
      'tema/rain',
      'tema/tired'
    ];

    List<String> context = await Future.wait((textTitle.map((e) async =>
        await rootBundle.loadString('assets/musics/recommendation/${e}.txt'))));

    List<List<String>> contextList = context.map((e) => ls.convert(e)).toList();

    parseMusics(contextList[0], femaleHighList);
    parseMusics(contextList[1], femaleLowList);
    parseMusics(contextList[2], maleHighList);
    parseMusics(contextList[3], maleLowList);
    parseMusics(contextList[4], balladeList);
    parseMusics(contextList[5], cartoonList);
    parseMusics(contextList[6], hiphopList);
    parseMusics(contextList[7], jpopList);
    parseMusics(contextList[8], popList);
    parseMusics(contextList[9], rnbList);
    parseMusics(contextList[10], allTimeLegendList);
    parseMusics(contextList[11], springList);
    parseMusics(contextList[12], summerList);
    parseMusics(contextList[13], fallList);
    parseMusics(contextList[14], winterList);
    parseMusics(contextList[15], duetList);
    parseMusics(contextList[16], excitedList);
    parseMusics(contextList[17], loveList);
    parseMusics(contextList[18], rainList);
    parseMusics(contextList[19], tiredList);
  }

  void parseMusics(List<String> contents, List<MusicSearchItem> musicList) {
    late String title, singer, songNumber;
    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;
      bool errFlag = false;

      for (int i = 0; i < 3; i++) {
        end = str.indexOf('^', start);
        if (end == -1) {
          errFlag = true;
          break;
        }
        if (start == end) continue;
        String tmp = str.substring(start, end);
        start = end + 1;

        if (i == 0)
          title = tmp;
        else if (i == 1)
          singer = tmp;
        else
          songNumber = tmp;
      }
      if (errFlag) continue;

      musicList.add(MusicSearchItem(
          title: title, singer: singer, songNumber: songNumber));
    }
  }
}
