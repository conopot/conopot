import 'dart:convert';

import 'package:conopot/models/MusicSearchItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MusicSearchItemLists extends ChangeNotifier {
  List<MusicSearchItem> foundItems = [];
  List<MusicSearchItem> results = [];
  List<MusicSearchItem> tjSongList = [];
  List<MusicSearchItem> kySongList = [];

  int tabIndex = 1; // TJ or 금영

  int userFitch = 13;

  void changeUserFitch({required int pitch}) {
    userFitch = pitch;
    notifyListeners();
  }

  Future<String> getTJMusics() async {
    return await rootBundle.loadString('assets/musics/musicbook_TJ.txt');
  }

  Future<String> getKYMusics() async {
    return await rootBundle.loadString('assets/musics/musicbook_KY.txt');
  }

  // 프로그램 실행 시, 노래방 책 List 초기화 (TJ, KY txt -> List)
  void init() async {
    //사용자 음정 불러오기
    final storage = new FlutterSecureStorage();
    String? value = await storage.read(key: 'userPitch');
    userFitch = int.parse(value!);

    String TJMusics = await getTJMusics();
    String KYMusics = await getKYMusics();

    LineSplitter ls = new LineSplitter();
    List<String> contents = ls.convert(TJMusics);

    //문자열 파싱 -> MusicSearchItem
    late String title, singer, songNumber;
    for (String str in contents) {
      int start = 0, end = 0;

      for (int i = 0; i < 3; i++) {
        end = str.indexOf('^', start);
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
      tjSongList.add(MusicSearchItem(
          title: title, singer: singer, songNumber: songNumber));
    }
    foundItems = tjSongList;

    contents = ls.convert(KYMusics);

    //문자열 파싱 -> MusicSearchItem
    for (String str in contents) {
      int start = 0, end = 0;

      for (int i = 0; i < 3; i++) {
        end = str.indexOf('^', start);
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
      kySongList.add(MusicSearchItem(
          title: title, singer: singer, songNumber: songNumber));
    }

    notifyListeners();
  }

  void changeTabIndex({required int index}) {
    tabIndex = index;
    foundItems = (index == 1) ? tjSongList : kySongList;
    notifyListeners();
  }

  // 검색 필터링 기능(일반검색)
  void runFilter(String enteredKeyword, int _tabIndex) {
    if (_tabIndex == 1) {
      //TJ
      if (enteredKeyword.isEmpty) {
        results = tjSongList;
      } else {
        results = tjSongList
            .where((string) =>
                string.title.contains(enteredKeyword) ||
                string.singer.contains(enteredKeyword))
            .toList();
      }
    } else {
      //KY
      if (enteredKeyword.isEmpty) {
        results = kySongList;
      } else {
        results = kySongList
            .where((string) =>
                string.title.contains(enteredKeyword) ||
                string.singer.contains(enteredKeyword))
            .toList();
      }
    }
    foundItems = results;
    print(foundItems.length);

    notifyListeners();
  }
}
