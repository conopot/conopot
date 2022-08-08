import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/note/note_screen.dart';
import 'package:conopot/screens/recommend/recommend_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[NoteScreen(), MusicBookScreen(), RecommendScreen()];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double defaultSize = SizeConfig.defaultSize;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: kPrimaryWhiteColor, width: 0.1))),
          child: BottomNavigationBar(
            key: Provider.of<NoteData>(context, listen: false).globalKey,
            selectedFontSize: defaultSize * 1.2,
            unselectedFontSize: defaultSize * 1.2,
            backgroundColor: kBackgroundColor,
            currentIndex: _selectedIndex,
            selectedItemColor: kMainColor,
            unselectedItemColor: kPrimaryWhiteColor,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: kPrimaryWhiteColor,
                ),
                label: "홈",
                activeIcon: Icon(
                  Icons.home,
                  color: kMainColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: kPrimaryWhiteColor,
                ),
                label: "검색",
                activeIcon: Icon(
                  Icons.search,
                  color: kMainColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: defaultSize * 0.2),child: SvgPicture.asset("assets/icons/recommend.svg", height: defaultSize * 1.7, width: defaultSize * 1.7)),
                label: "추천",
                activeIcon: Padding(padding: EdgeInsets.only(bottom: defaultSize * 0.2),child: SvgPicture.asset("assets/icons/recommend_click.svg",height: defaultSize * 1.7, width: defaultSize * 1.7)),
              ),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 1) {
                  //!event: 네비게이션__검색탭
                  Analytics_config().clicksearchTapEvent();
                } else if (index == 2) {
                  //!event: 네비게이션__추천탭
                  Analytics_config().clickRecommendationTapEvent();
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
