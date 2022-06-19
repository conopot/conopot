import 'package:conopot/screens/chart/pitch_screen.dart';
import 'package:conopot/screens/home/home_screen.dart';
import 'package:conopot/screens/musicBook/music_screen.dart';
import 'package:flutter/material.dart';

enum TabItem { home, pitch, music }

const Map<TabItem, String> tabName = {
  TabItem.home: 'home',
  TabItem.pitch: 'pitch',
  TabItem.music: 'music',
};

Map<TabItem, Widget> tabScreen = {
  TabItem.home: HomeScreen(),
  TabItem.pitch: PitchScreen(),
  TabItem.music: const MusicScreen(),
};

const Map<TabItem, int> tabIdx = {
  TabItem.home: 0,
  TabItem.pitch: 1,
  TabItem.music: 2,
};

const Map<int, TabItem> idxTab = {
  0: TabItem.home,
  1: TabItem.pitch,
  2: TabItem.music,
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.home: Colors.red,
  TabItem.pitch: Colors.green,
  TabItem.music: Colors.blue,
};
