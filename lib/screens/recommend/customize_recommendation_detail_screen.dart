import 'dart:convert';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// 맞춤 추천 상세페이지
class CustomizeRecommendationDetailScreen extends StatefulWidget {
  late String title;
  late List<FitchMusic> songList = [];
  late MusicSearchItemLists musicList;

  CustomizeRecommendationDetailScreen(
      {Key? key,
      required this.musicList,
      required this.title,
      required this.songList})
      : super(key: key);
  @override
  State<CustomizeRecommendationDetailScreen> createState() =>
      _CustomizeRecommendationDetailScreenState();
}

class _CustomizeRecommendationDetailScreenState
    extends State<CustomizeRecommendationDetailScreen> {
  final storage = new FlutterSecureStorage();

  void requestCFApi() async {
    widget.musicList.recommendRequest = true;
    storage.write(key: "recommendRequest", value: 'true');
    await EasyLoading.show(status: '분석중 입니다...');
    String url = 'https://recommendcf-pfenq2lbpq-du.a.run.app/recommendCF';
    List<String> musicArr =
        Provider.of<NoteData>(context, listen: false).userMusics;
    if (musicArr.length > 20) {
      // 저장한 노트수가 20개 보다 많은 경우 자르기
      musicArr = musicArr.sublist(0, 20);
    }
    Future<dynamic> myFuture = new Future(() async {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"musicArr": musicArr.toString()}),
      );
      return response;
    });
    myFuture.then((response) {
      if (response.statusCode == 200) {
        String? recommendList = response.body;
        if (recommendList != null) {
          widget.musicList.saveAiRecommendationList(recommendList);
          setState(() {});
          EasyLoading.showSuccess('분석에 성공했습니다!');
        } else {
          setState(() {});
          EasyLoading.showError('분석을 위한 데이터가 부족합니다😿\n노트를 좀더 추가해주세요');
        }
      } else {
        setState(() {});
        EasyLoading.showError('서버 문제가 발생했습니다😿\n채널톡에 문의해주세요');
      }
    }, onError: (e) {
      setState(() {});
      EasyLoading.showError('분석에 실패했습니다😿\n인터넷 연결을 확인해 주세요');
    });
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    double screenHeight = SizeConfig.screenHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              if (Provider.of<NoteData>(context, listen: false).userMusics.length < 5) {
                EasyLoading.showError('최소 5개 이상의 노트를 추가해 주세요 🙀');
              } else {
                requestCFApi();
              }
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("추천 다시 받기",
                    style: TextStyle(
                        color: kMainColor,
                        fontSize: defaultSize * 1.3,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: screenHeight * 0.3),
          itemCount: widget.songList.length,
          itemBuilder: (context, index) {
            String songNumber = widget.songList[index].tj_songNumber;
            String title = widget.songList[index].tj_title;
            String singer = widget.songList[index].tj_singer;
            int pitchNum = widget.songList[index].pitchNum;

            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Card(
                margin: EdgeInsets.fromLTRB(
                    defaultSize, 0, defaultSize, defaultSize * 0.5),
                color: kPrimaryLightBlackColor,
                elevation: 1,
                child: ListTile(
                    leading: SizedBox(
                      width: defaultSize * 6.5,
                      child: Center(
                        child: Text(
                          songNumber,
                          style: TextStyle(
                            color: kMainColor,
                            fontSize: defaultSize * 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: kPrimaryWhiteColor,
                        fontSize: defaultSize * 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      singer,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: kPrimaryLightWhiteColor,
                          fontWeight: FontWeight.w300,
                          fontSize: defaultSize * 1.2),
                    ),
                    onTap: () {
                      //!event: 추천_뷰__맞춤_추천_리스트_아이템_클릭
                      Analytics_config()
                          .clickCustomizeRecommendationListItemEvent();
                      Provider.of<NoteData>(context, listen: false)
                          .showAddNoteDialogWithInfo(context,
                              isTj: true,
                              songNumber: songNumber,
                              title: title,
                              singer: singer);
                    }),
              ),
            );
          },
        ),
      ),
    );
  }
}
