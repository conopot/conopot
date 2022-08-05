import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/models/pitch_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomizeRecommendation extends StatefulWidget {
  late MusicSearchItemLists musicList;
  CustomizeRecommendation({Key? key, required this.musicList})
      : super(key: key);

  @override
  State<CustomizeRecommendation> createState() =>
      _CustomizeRecommendationState();
}

// 맞춤 추천
class _CustomizeRecommendationState extends State<CustomizeRecommendation> {
  double defaultSize = SizeConfig.defaultSize;

  // 노래 간단한 정보 + 유튜브 + 애창곡노트에 추가버튼 다이어로그 팝업 함수
  void showAddDialog(BuildContext context, FitchMusic item) {
    Widget okButton = ElevatedButton(
      onPressed: () {
        Provider.of<NoteData>(context, listen: false).addNoteBySongNumber(
            item.tj_songNumber,
            Provider.of<MusicSearchItemLists>(context, listen: false)
                .combinedSongList);
        Navigator.of(context).pop();
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
              Text("${item.tj_songNumber}",
                  style: TextStyle(color: kMainColor)),
              Spacer(),
              IconButton(
                onPressed: () async {
                  final url = Uri.parse(
                      'https://www.youtube.com/results?search_query= ${item.tj_title} ${item.tj_singer}');
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
                icon: SvgPicture.asset("assets/icons/youtube.svg"),
              )
            ],
          ),
          SizedBox(height: defaultSize * 2),
          Text("${item.tj_title}",
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: defaultSize * 1.4)),
          SizedBox(height: defaultSize),
          Text("${item.tj_singer}",
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
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
          child: Row(
            children: [
              Text("맞춤 추천",
                  style: TextStyle(
                      color: kPrimaryWhiteColor,
                      fontSize: defaultSize * 2,
                      fontWeight: FontWeight.w600)),
              Spacer(),
              if (widget.musicList.userMaxPitch != -1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.musicList.userMaxPitch = -1;
                    });
                    // Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) =>
                    //                     PitchMainScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        defaultSize * 0.8,
                        defaultSize * 0.5,
                        defaultSize * 0.8,
                        defaultSize * 0.5),
                    decoration: BoxDecoration(
                        color: kMainColor,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text("더보기",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize,
                            fontWeight: FontWeight.w400)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: defaultSize * 2),
        widget.musicList.userMaxPitch == -1
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.25),
                padding: EdgeInsets.symmetric(vertical: defaultSize * 5),
                decoration: BoxDecoration(
                    color: kPrimaryLightBlackColor,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Center(
                    child: Text("음역대를 측정해 주세요 😸",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w400,
                            fontSize: defaultSize * 1.5))),
              )
            : widget.musicList.highestFoundItems.isEmpty
                ? Container(
                    width: double.infinity,
                    margin:
                        EdgeInsets.symmetric(horizontal: defaultSize * 1.25),
                    padding: EdgeInsets.symmetric(vertical: defaultSize * 5),
                    decoration: BoxDecoration(
                        color: kPrimaryLightBlackColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Center(
                        child: Text("비슷한 음역대의 노래가 없어요 😹",
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontWeight: FontWeight.w400,
                                fontSize: defaultSize * 1.5))),
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: defaultSize),
                    width: double.infinity,
                    height: 180,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.musicList.highestFoundItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 60,
                              childAspectRatio: 1 / 3.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 15),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showAddDialog(context,
                                widget.musicList.highestFoundItems[index]);
                          },
                          child: GridTile(
                            child: Container(
                              padding: EdgeInsets.all(defaultSize),
                              decoration: BoxDecoration(
                                  color: kPrimaryLightBlackColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Center(
                                      child: Text(
                                        "${widget.musicList.highestFoundItems[index].tj_songNumber}",
                                        style: TextStyle(
                                            color: kMainColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: defaultSize),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${widget.musicList.highestFoundItems[index].tj_title}",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: kPrimaryWhiteColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 11),
                                          ),
                                          Text(
                                            "${widget.musicList.highestFoundItems[index].tj_singer}",
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: kPrimaryLightWhiteColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 9),
                                          )
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
