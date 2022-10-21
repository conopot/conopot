import 'dart:io';

import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/note/components/banner.dart';
import 'package:conopot/screens/note/components/edit_note_list.dart';
import 'package:conopot/screens/note/components/empty_icon_note.dart';
import 'package:conopot/screens/note/components/empty_note_list.dart';
import 'package:conopot/screens/note/components/note_list.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:conopot/screens/user/user_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'add_note_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

// 메인화면 - 애창곡 노트
class _NoteScreenState extends State<NoteScreen> {
  double defaultSize = SizeConfig.defaultSize;
  int _listSate = 0;
  String abtest1021_modal = "";

  bool isLoaded = false;

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: defaultSize * 18,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "나만의 첫 ",
                          style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 2,
                          ),
                        ),
                        TextSpan(
                            text: '애창곡',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: kMainColor,
                              fontSize: defaultSize * 2,
                            )),
                        TextSpan(
                          text: "을",
                          style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.defaultSize * 0.5,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "애창곡 노트",
                          style: TextStyle(
                            color: kMainColor,
                            fontWeight: FontWeight.w500,
                            fontSize: defaultSize * 2,
                          ),
                        ),
                        TextSpan(
                            text: '에 저장해 보세요',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 2,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: defaultSize * 2.5,
              ),
              GestureDetector(
                onTap: () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initCombinedBook();
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNoteScreen(),
                    ),
                  );
                },
                child: Container(
                  width: defaultSize * 22.8,
                  height: defaultSize * 4,
                  decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                  child: Center(
                    child: Text(
                      "애창곡 추가하기",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.5,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              )
            ]),
          ),
          backgroundColor: kDialogColor,
        );
      },
    );
  }

  @override
  void initState() {
    //첫 세션인 사용자를 대상으로 한다.
    if (Provider.of<MusicSearchItemLists>(context, listen: false)
            .sessionCount ==
        0) {
      Analytics_config().emptyNoteUserEvent();
      //remote config 변수 가져오기
      abtest1021_modal =
          Firebase_Remote_Config().remoteConfig.getString('abtest1021_modal');
      //유저 프로퍼티 설정하기
      if (abtest1021_modal != "") {
        Identify identify = Identify()
          ..set('10/21 CTA 강조 및 이외 다른 버튼 모두 비활성화', abtest1021_modal);

        Analytics_config().userProps(identify);
      }

      //화면 빌드 후, 바로 모달 창 띄우는 부분
      if (abtest1021_modal != 'B') {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _dialogBuilder(context));
      }
      Provider.of<MusicSearchItemLists>(context, listen: false).sessionCount +=
          1;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Analytics_config().noteViewPageViewEvent();
    return Consumer<NoteData>(
      builder: (context, noteData, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "애창곡 노트",
            style: TextStyle(
              color: kMainColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // 저장한 노래가 있을 경우만 아이콘 표시
            if (noteData.notes.isNotEmpty && _listSate == 0) ...[
              IconButton(
                  onPressed: () {
                    showNoteListOption(context);
                  },
                  icon: Icon(Icons.more_horiz_outlined)),
            ] else ...[
              if (_listSate == 1) ...[
                TextButton(
                    onPressed: () {
                      noteData.initEditNote();
                      setState(() {
                        _listSate = 0;
                      });
                    },
                    child: Text("완료",
                        style: TextStyle(
                            color: kMainColor, fontSize: defaultSize * 1.6)))
              ]
            ]
          ],
        ),
        floatingActionButtonLocation:
            (_listSate == 1) ? FloatingActionButtonLocation.centerFloat : null,
        floatingActionButton: (noteData.notes.isEmpty && _listSate == 0)
            ? SizedBox.shrink()
            : (_listSate == 0)
                ? Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, defaultSize * 0.5, defaultSize * 0.5),
                    width: 72,
                    height: 72,
                    child: FittedBox(
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        child: SvgPicture.asset('assets/icons/addButton.svg'),
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            Provider.of<MusicSearchItemLists>(context,
                                    listen: false)
                                .initCombinedBook();
                          });
                          Analytics_config().noteViewEnterEvent();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddNoteScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(vertical: defaultSize),
                    decoration: BoxDecoration(
                        color: kPrimaryGreyColor,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: defaultSize * 3),
                              GestureDetector(
                                onTap: () {
                                  noteData.checkAllSongs();
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.format_list_bulleted_outlined,
                                      color: kMainColor,
                                    ),
                                    Text(
                                      "전체 선택",
                                      style: TextStyle(
                                          color: kMainColor,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: defaultSize * 3),
                              GestureDetector(
                                onTap: () {
                                  noteData.unCheckAllSongs();
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.clear_all_outlined,
                                      color: kMainColor,
                                    ),
                                    Text(
                                      "전체 해제",
                                      style: TextStyle(
                                          color: kMainColor,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: defaultSize * 3),
                              GestureDetector(
                                onTap: () async {
                                  if (noteData.deleteSet.isNotEmpty) {
                                    noteData
                                        .showDeleteMultipleNoteDialog(context);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.delete_forever_outlined,
                                      color: noteData.deleteSet.isNotEmpty
                                          ? kPrimaryRedColor
                                          : kPrimaryLightGreyColor,
                                    ),
                                    Text(
                                      "삭제",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: noteData.deleteSet.isNotEmpty
                                              ? kPrimaryRedColor
                                              : kPrimaryLightGreyColor),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: defaultSize * 3),
                            ]),
                      ),
                    ),
                  ),
        body: Column(
          children: [
            CarouselSliderBanner(),
            if (noteData.notes.isEmpty) ...[
              if (_listSate == 0) ...[
                EmptyNoteList(),
              ] else if (_listSate == 1) ...[
                Expanded(
                  child: Center(
                    child: Text(
                      "모든 노래가 삭제 되었습니다",
                      style: TextStyle(
                          color: kPrimaryLightWhiteColor,
                          fontSize: defaultSize * 1.5),
                    ),
                  ),
                )
              ]
            ] else ...[
              SizedBox(height: defaultSize),
              if (_listSate == 0) ...[
                NoteList()
              ] else if (_listSate == 1) ...[
                EditNoteList()
              ]
            ],
          ],
        ),
      ),
    );
  }

  // 애창곡 노트 목록 옵션 팝업 함수
  showNoteListOption(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        backgroundColor: kDialogColor,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
            child: IntrinsicHeight(
              child: Column(children: [
                SizedBox(height: defaultSize),
                Container(
                  height: 5,
                  width: 50,
                  color: kPrimaryLightWhiteColor,
                ),
                SizedBox(height: defaultSize),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "취소",
                      style: TextStyle(color: Colors.transparent),
                    ), // 가운데 정렬을 위해 추가
                    Spacer(),
                    Text(
                      "목록 옵션",
                      style: TextStyle(
                          color: kPrimaryWhiteColor,
                          fontSize: defaultSize * 1.5,
                          fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "취소",
                          style: TextStyle(
                              color: kMainColor, fontSize: defaultSize * 1.4),
                        ))
                  ],
                ),
                SizedBox(
                  height: defaultSize * 3,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Provider.of<NoteData>(context, listen: false)
                        .initEditNote();
                    Navigator.pop(context);
                    setState(() {
                      _listSate = 1;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: kPrimaryWhiteColor,
                      ),
                      SizedBox(width: defaultSize * 1.5),
                      Text(
                        "편집",
                        style: TextStyle(color: kPrimaryWhiteColor),
                      )
                    ],
                  ),
                ),
                SizedBox(height: defaultSize * 1.8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NoteSettingScreen();
                    }));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: kPrimaryWhiteColor,
                      ),
                      SizedBox(width: defaultSize * 1.5),
                      Text(
                        "설정",
                        style: TextStyle(color: kPrimaryWhiteColor),
                      ),
                      Spacer(),
                      Icon(
                        Icons.chevron_right_outlined,
                        color: kPrimaryWhiteColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: defaultSize * 8,
                ),
              ]),
            ),
          );
        });
  }
}
