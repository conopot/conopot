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
  static List<MusicSearchItem> oldList = [];
  static List<MusicSearchItem> popList = [];
  static List<MusicSearchItem> rnbList = [];
  static List<MusicSearchItem> jpopList = [];
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
  initRecommendationList() async {
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
      'genre/old',
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
    parseMusics(contextList[8], oldList);
    parseMusics(contextList[9], popList);
    parseMusics(contextList[10], rnbList);
    parseMusics(contextList[11], allTimeLegendList);
    parseMusics(contextList[12], springList);
    parseMusics(contextList[13], summerList);
    parseMusics(contextList[14], fallList);
    parseMusics(contextList[15], winterList);
    parseMusics(contextList[16], duetList);
    parseMusics(contextList[17], excitedList);
    parseMusics(contextList[18], loveList);
    parseMusics(contextList[19], rainList);
    parseMusics(contextList[20], tiredList);
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
          title: title,
          singer: singer,
          songNumber: songNumber,
          search_keyword_title_singer: title + singer,
          search_keyword_singer_title: singer + title));
    }
  }
}
