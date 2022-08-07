import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/screens/user/components/channel_talk.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  void initState() {
    Analytics_config.analytics.logEvent("내 정보 뷰 - 페이지뷰");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicSearchItemLists>(
        builder: (
      context,
      musicList,
      child,
    ) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                  "설정",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(children: [
                  SizedBox(height: defaultSize),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NoteSettingScreen()));
                    },
                    splashColor: Colors.transparent,
                    child: Container(
                      height: defaultSize * 4,
                      padding: EdgeInsets.symmetric(horizontal: defaultSize * 2),
                      child: Row(children: [
                        Text("애창곡 노트 설정",
                            style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.8,
                              fontWeight: FontWeight.w500,
                            )),
                        Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: kPrimaryWhiteColor,
                        ),
                      ]),
                    ),
                  )
                ]),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                width: defaultSize * 7.2,
                height: defaultSize * 7.2,
                child: FittedBox(
                  child: FloatingActionButton(
                    elevation: 5.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChannelTalkScreen()),
                      );
                    },
                    child: Image.asset(
                      "assets/images/channeltalk.png",
                    ),
                  ),
                ),
              ),
            ));
  }
}
