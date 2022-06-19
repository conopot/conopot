import 'package:conopot/config/constants.dart';
import 'package:conopot/models/navbar_items.dart';
import 'package:conopot/navigator/tab_item.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({required this.currentTab, required this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(TabItem.home),
        _buildItem(TabItem.pitch),
        _buildItem(TabItem.music),
      ],
      onTap: (index) => onSelectTab(
        TabItem.values[index],
      ),
      currentIndex: currentTab.index,
      selectedItemColor: kPrimaryColor,
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    return navbarItems[tabIdx[tabItem]!];
  }
}
