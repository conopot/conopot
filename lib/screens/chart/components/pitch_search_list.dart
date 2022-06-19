import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';

class PitchSearchList extends StatelessWidget {
  final MusicSearchItemLists musicList;

  const PitchSearchList({super.key, required this.musicList});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: musicList.highestFoundItems.isNotEmpty
          ? ListView.builder(
              itemCount: musicList.highestFoundItems.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                elevation: 1,
                child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pitchNumToString[
                              musicList.highestFoundItems[index].pitchNum],
                          style: TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    title: Text(musicList.highestFoundItems[index].tj_title),
                    subtitle:
                        Text(musicList.highestFoundItems[index].tj_singer),
                    trailing: Text(
                      (musicList.userPitch - 2 >
                              musicList.highestFoundItems[index].pitchNum)
                          ? '쉬움'
                          : (musicList.userPitch + 2 >
                                  musicList.highestFoundItems[index].pitchNum)
                              ? '적정'
                              : '어려움',
                      style: TextStyle(
                          color: (musicList.userPitch - 2 >
                                  musicList.highestFoundItems[index].pitchNum)
                              ? Colors.green
                              : (musicList.userPitch + 2 >
                                      musicList
                                          .highestFoundItems[index].pitchNum)
                                  ? Colors.blue
                                  : Colors.red),
                    )),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '검색 결과가 없습니다 ❗️',
                    style: TextStyle(fontSize: 21),
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize,
                  ),
                  Text(
                    '음을 너무 낮거나 높게 설정한 경우 \n노래가 나오지 않을 수 있습니다.\n 검색 결과가 없는 노래 중 옥타브가 궁금한 노래는\n 아래 메일로 문의주세요!\n',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'conopots@gmail.com',
                    style: TextStyle(
                      color: Color.fromARGB(255, 38, 181, 247),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
