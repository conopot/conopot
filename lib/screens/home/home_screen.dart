import 'package:conopot/components/bottom_nav_bar.dart';
import 'package:conopot/size_config.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text('HomeBody'),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
