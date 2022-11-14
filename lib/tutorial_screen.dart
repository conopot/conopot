import 'package:amplitude_flutter/identify.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/firebase_remote_config.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/main_screen.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/tutorial_add_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  PageController controller =
      PageController(initialPage: 0, viewportFraction: 1.0);
  int selectedIndex = 0;
  double defaultSize = SizeConfig.defaultSize;
  final storage = new FlutterSecureStorage();
  String abtest1114_modal = "";

  @override
  void initState() {
    //remote config 변수 가져오기
    abtest1114_modal =
        Firebase_Remote_Config().remoteConfig.getString('abtest1114_modal');
    //유저 프로퍼티 설정하기
    if (abtest1114_modal != "" &&
        Provider.of<MusicSearchItemLists>(context, listen: false)
                .sessionCount ==
            0) {
      Identify identify = Identify()..set('11/14 튜토리얼', abtest1114_modal);
      Analytics_config().userProps(identify);
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          SizedBox(height: defaultSize * 2),
          Container(
              margin: EdgeInsets.only(right: defaultSize * 1.5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildPageIndicator())),
          SizedBox(height: defaultSize * 3),
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (int page) {
                setState(() {
                  selectedIndex = page;
                });
              },
              children: [
                Image.asset(
                  "assets/images/tutorial1.png",
                ),
                Image.asset(
                  "assets/images/tutorial2.png",
                ),
                Image.asset(
                  "assets/images/tutorial3.png",
                ),
                Image.asset(
                  "assets/images/tutorial4.png",
                ),
              ],
            ),
          ),
          (selectedIndex == 3)
              ? GestureDetector(
                  onTap: () async {
                    //"시작하기" 버튼 누를 시, 다음부터는 튜토리얼 화면이 뜨지 않는다.
                    await storage.write(key: 'tutorial', value: '1');
                    if (Provider.of<NoteData>(context, listen: false)
                        .notes
                        .isNotEmpty) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainScreen()));
                      return;
                    }
                    if (Provider.of<NoteData>(context, listen: false)
                            .notes
                            .isEmpty &&
                        abtest1114_modal == 'A') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainScreen()));
                      return;
                    }
                    if (Provider.of<NoteData>(context, listen: false)
                            .notes
                            .isEmpty &&
                        abtest1114_modal == 'B') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TutorialAddNoteScreen()));
                      return;
                    }
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TutorialAddNoteScreen()));
                  },
                  child: Container(
                    width: SizeConfig.screenWidth,
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    margin: EdgeInsets.symmetric(horizontal: defaultSize * 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: kMainColor),
                    child: Center(
                      child: Text(
                        '시작하기',
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: defaultSize * 1.5),
                      ),
                    ),
                  ))
              : GestureDetector(
                  onTap: () {
                    controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  child: Container(
                    width: SizeConfig.screenWidth,
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    margin: EdgeInsets.symmetric(horizontal: defaultSize * 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: kMainColor),
                    child: Center(
                      child: Text(
                        '다음',
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: defaultSize * 1.5),
                      ),
                    ),
                  )),
          SizedBox(height: defaultSize * 1.5)
        ],
      ),
    ));
  }

  changeScreen(int nextScreenNo) {
    controller.animateToPage(nextScreenNo,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  Widget _indicator(bool isActiveScreen) {
    return Container(
      height: defaultSize,
      child: AnimatedContainer(
        duration: Duration(microseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: defaultSize * 0.4),
        height: defaultSize * 0.8,
        width: defaultSize * 0.8,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kMainColor.withOpacity(isActiveScreen ? 1 : 0.4)),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 4; i++) {
      list.add(i == selectedIndex ? _indicator(true) : _indicator(false));
    }
    return list;
  }
}
