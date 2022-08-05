import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchList extends StatefulWidget {
  final MusicSearchItemLists musicList;
  const SearchList({super.key, required this.musicList});

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  double defaultSize = SizeConfig.defaultSize;
  double screenHeight = SizeConfig.screenHeight;
  // 곡 추가 다이어로그 팝업 함수
  void showAddDialog(BuildContext context, MusicSearchItem item) {
    Widget okButton = ElevatedButton(
      onPressed: () {
        // !event : 노래번호검색 뷰 - 노트 추가
        Analytics_config.analytics.logEvent('노래번호 검색 뷰 - 노트추가');
        Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
            item.songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        if (Provider.of<NoteData>(context, listen: false).emptyCheck == true) {
          Fluttertoast.showToast(
              msg: "이미 등록된 곡입니다 😢",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xFFFF7878),
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
          Provider.of<NoteData>(context, listen: false).initEmptyCheck();
        } else {
          Fluttertoast.showToast(
              msg: "노래가 추가 되었습니다 🎉",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: kMainColor,
              textColor: kPrimaryWhiteColor,
              fontSize: defaultSize * 1.6);
        }
      },
      child: Text("애창곡 노트에 추가",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          )),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kMainColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ))),
    );

    AlertDialog alert = AlertDialog(
      content: IntrinsicHeight(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text("${item.songNumber}", style: TextStyle(color: kMainColor)),
              Spacer(),
              IconButton(
                onPressed: () async {
                  final url = Uri.parse(
                      'https://www.youtube.com/results?search_query= ${item.title} ${item.singer}');
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
                icon: SvgPicture.asset("assets/icons/youtube.svg"),
              )
            ],
          ),
          SizedBox(height: defaultSize * 2),
          Text("${item.title}",
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: defaultSize * 1.4)),
          SizedBox(height: defaultSize),
          Text("${item.singer}",
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontWeight: FontWeight.w300,
                  fontSize: defaultSize * 1.2)),
        ]),
      ),
      actions: [
        Center(child: okButton),
      ],
      backgroundColor: kDialogColor,
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.musicList.foundItems.isNotEmpty
        ? ListView.builder(
            itemCount: widget.musicList.foundItems.length,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    showAddDialog(context, widget.musicList.foundItems[index]);
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        defaultSize, 0, defaultSize, defaultSize),
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Row(children: [
                      SizedBox(
                        width: defaultSize * 6,
                        child: Center(
                            child: Text(
                                "${widget.musicList.foundItems[index].songNumber}",
                                style: TextStyle(
                                    color: kMainColor,
                                    fontSize: defaultSize * 1.4,
                                    fontWeight: FontWeight.w500))),
                      ),
                      SizedBox(width: defaultSize),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.musicList.foundItems[index].title}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 1.4,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: defaultSize * 0.5),
                            Text(
                              "${widget.musicList.foundItems[index].singer}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: kPrimaryLightWhiteColor,
                                  fontSize: defaultSize * 1.2,
                                  fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                ))
        : Center(
            child: Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: defaultSize * 1.8,
                color: kPrimaryWhiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
  }
}
