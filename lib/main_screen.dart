import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/screens/note/note_screen.dart';
import 'package:conopot/screens/recommend/recommend_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[NoteScreen(), MusicBookScreen(), RecommendScreen()];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
            backgroundColor: kBackgroundColor,
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: kPrimaryWhiteColor,
                ),
                label: "home",
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
                label: "music_book",
                activeIcon: Icon(
                  Icons.search,
                  color: kMainColor,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.recommend,
                  color: kPrimaryWhiteColor,
                ),
                label: "recommend",
                activeIcon: Icon(
                  Icons.recommend,
                  color: kMainColor,
                ),
              ),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
