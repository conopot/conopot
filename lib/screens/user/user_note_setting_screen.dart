import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteSettingScreen extends StatefulWidget {
  NoteSettingScreen({Key? key}) : super(key: key);

  @override
  State<NoteSettingScreen> createState() => _NoteSettingScreenState();
}

class _NoteSettingScreenState extends State<NoteSettingScreen> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    int choice = Provider.of<MusicSearchItemLists>(context, listen: true)
        .userNoteSetting;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "애창곡 노트 설정",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      fillColor: MaterialStateProperty.all(kMainColor),
                      groupValue: choice,
                      onChanged: (int? value) {
                        setState(() {
                          choice = 0;
                          Provider.of<MusicSearchItemLists>(context,
                                  listen: false)
                              .changeUserNoteSetting(0);
                        });
                      },
                    ),
                    SizedBox(width: defaultSize * 0.5),
                    Text(
                      'TJ 반주기 번호 표시',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: kPrimaryLightWhiteColor,
                          fontSize: defaultSize * 1.5),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                    defaultSize, 0, defaultSize * 0.5, defaultSize * 0.5),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      defaultSize, defaultSize, 0, defaultSize),
                  margin: EdgeInsets.fromLTRB(0, 0, defaultSize * 0.5, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: kPrimaryLightBlackColor,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '취중고백',
                            style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '김민석',
                            style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: defaultSize),
                          Container(
                            padding: EdgeInsets.all(defaultSize * 0.5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kPrimaryGreyColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '요즘 유명한 노래',
                              style: TextStyle(
                                  color: kPrimaryLightWhiteColor,
                                  fontSize: defaultSize * 1.2,
                                  fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: defaultSize),
                        child: SizedBox(
                            width: defaultSize * 5,
                            child: Center(
                              child: Text(
                                "80906",
                                style: TextStyle(
                                    color: kMainColor,
                                    fontSize: defaultSize * 1.2,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      fillColor: MaterialStateProperty.all(kMainColor),
                      groupValue: choice,
                      onChanged: (int? value) {
                        setState(() {
                          choice = 1;
                          Provider.of<MusicSearchItemLists>(context,
                                  listen: false)
                              .changeUserNoteSetting(1);
                        });
                      },
                    ),
                    SizedBox(width: defaultSize * 0.5),
                    Text(
                      '노래 최고음 표시',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: kPrimaryLightWhiteColor,
                          fontSize: defaultSize * 1.5),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                    defaultSize, 0, defaultSize * 0.5, defaultSize * 0.5),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      defaultSize, defaultSize, 0, defaultSize),
                  height: defaultSize * 9.5,
                  margin: EdgeInsets.fromLTRB(0, 0, defaultSize * 0.5, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: kPrimaryLightBlackColor,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '취중고백',
                            style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '김민석',
                            style: TextStyle(
                              color: kPrimaryLightWhiteColor,
                              fontSize: defaultSize * 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: defaultSize),
                          Container(
                            padding: EdgeInsets.all(defaultSize * 0.5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kPrimaryGreyColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '요즘 유명한 노래',
                              style: TextStyle(
                                  color: kPrimaryLightWhiteColor,
                                  fontSize: defaultSize * 1.2,
                                  fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: defaultSize),
                        child: SizedBox(
                            width: defaultSize * 5,
                            child: Center(
                              child: Text(
                                "2옥타브 라#",
                                style: TextStyle(
                                    color: kMainColor,
                                    fontSize: defaultSize * 0.9,
                                    fontWeight: FontWeight.w600),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
