import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';

class PopularSongRecommendation extends StatelessWidget {
  double defaultSize = SizeConfig.defaultSize;
  List<String> _list = ['tj 인기차트', '금영 인기차트', '올타임 레전드'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('인기',
              style: TextStyle(
                  color: kPrimaryWhiteColor,
                  fontSize: defaultSize * 2,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: defaultSize * 2),
          Container(
            height: defaultSize * 11,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: (){

                  },
                  child: Container(
                    margin: EdgeInsets.only(right: defaultSize * 2),
                    width: defaultSize * 11,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.asset(
                                "assets/images/recommend1.png",
                                width: defaultSize * 11,
                                height: defaultSize * 11,
                              )),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              _list[index],
                              style: TextStyle(color: kPrimaryWhiteColor, fontWeight: FontWeight.w600, fontSize: defaultSize * 1.5),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
