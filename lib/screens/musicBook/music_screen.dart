import 'package:conopot/components/custom_page_route.dart';
import 'package:conopot/models/music_search_item_lists.dart';
import 'package:conopot/screens/musicBook/music_chart_screen.dart';
import 'package:conopot/screens/musicBook/music_book.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Future.delayed(Duration.zero, () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initChart();
                });
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: const ChartScreen(),
                  ),
                );
              },
              child: Center(
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 15.0),
                  child: SizedBox(
                    width: SizeConfig.screenWidth * 0.8,
                    height: SizeConfig.screenHeight * 0.15,
                    child: Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.bar_chart_rounded,
                          size: SizeConfig.screenHeight * 0.15 * 0.5,
                          color: Colors.black,
                        ),
                        title: Text(
                          '인기 차트',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('TJ, 금영의 최신 인기차트 목록입니다'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Future.delayed(Duration.zero, () {
                  Provider.of<MusicSearchItemLists>(context, listen: false)
                      .initBook();
                });
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: MusicBookScreen(),
                  ),
                );
              },
              child: Center(
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 15.0),
                  child: SizedBox(
                    width: SizeConfig.screenWidth * 0.8,
                    height: SizeConfig.screenHeight * 0.15,
                    child: Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.search,
                          size: SizeConfig.screenHeight * 0.15 * 0.5,
                          color: Colors.black,
                        ),
                        title: Text(
                          '노래 검색',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('TJ, 금영의 모든 노래들을 검색할 수 있습니다.'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
