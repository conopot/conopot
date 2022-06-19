import 'package:conopot/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

List<BottomNavigationBarItem> navbarItems = [
  BottomNavigationBarItem(
    icon: SvgPicture.asset(
      'assets/icons/home.svg',
      color: kTextColor,
      height: 22,
    ),
    label: '홈',
    activeIcon: SvgPicture.asset(
      'assets/icons/home.svg',
      color: kPrimaryColor,
      height: 22,
    ),
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset(
      'assets/icons/chart.svg',
      color: kTextColor,
      height: 22,
    ),
    label: '옥타브 차트',
    activeIcon: SvgPicture.asset(
      'assets/icons/chart.svg',
      color: kPrimaryColor,
      height: 22,
    ),
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset(
      'assets/icons/book.svg',
      color: kTextColor,
      height: 22,
    ),
    label: '노래 검색',
    activeIcon: SvgPicture.asset(
      'assets/icons/book.svg',
      color: kPrimaryColor,
      height: 22,
    ),
  ),
];
