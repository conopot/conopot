import 'package:conopot/config/constants.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/pitch/components/indicator.dart';
import 'package:conopot/screens/pitch/components/pitch_banner.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';

class PitchMeasure extends StatefulWidget {
  PitchMeasure({Key? key}) : super(key: key);

  @override
  State<PitchMeasure> createState() => _PitchMeasureState();
}

class _PitchMeasureState extends State<PitchMeasure> {
  var _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          title: Text(
            '음역대 측정',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(
              height: SizeConfig.screenHeight * 0.1,
            ),
            Text(
              '주의 사항',
              style: TextStyle(
                color: kTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: SizeConfig.defaultSize,
            ),
            Text(
              '혼자 있는 곳 또는 노래방에서 테스트하세요',
              style: TextStyle(
                color: kTextColor,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: SizeConfig.defaultSize * 0.5,
            ),
            Text(
              '가성이 아닌 진성으로 부르기!',
              style: TextStyle(
                color: kTextColor,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.1,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              height: SizeConfig.screenHeight / 3,
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                controller: PageController(viewportFraction: 0.7),
                itemCount: pitchItemList.length,
                itemBuilder: (context, index) {
                  var fitch = pitchItemList[index];
                  var _scale = _selectedIndex == index ? 1.0 : 0.8;

                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 350),
                    tween: Tween(begin: _scale, end: _scale),
                    curve: Curves.ease,
                    child: PitchBanner(
                      fitchItem: fitch,
                    ),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: _scale,
                        child: child,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}
