import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/screens/note/add_note_screen.dart';
import 'package:flutter/material.dart';

class EmptyNoteList extends StatelessWidget {
  double defaultSize = SizeConfig.defaultSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        SizedBox(height: defaultSize * 180),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "나만의 첫 ",
                style: TextStyle(
                  color: kPrimaryBlackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: defaultSize * 15,
                ),
              ),
              TextSpan(
                  text: '애창곡',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kMainColor,
                    fontSize: defaultSize * 15,
                  )),
              TextSpan(
                text: "을",
                style: TextStyle(
                  color: kPrimaryBlackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: defaultSize * 15,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: SizeConfig.defaultSize * 5,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "애창곡 노트",
                style: TextStyle(
                  color: kMainColor,
                  fontWeight: FontWeight.w600,
                  fontSize: defaultSize * 15,
                ),
              ),
              TextSpan(
                  text: '에 저장해 보세요',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryBlackColor,
                    fontSize: defaultSize * 15,
                  )),
            ],
          ),
        ),
        SizedBox(
          height: defaultSize * 25,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNoteScreen(),
              ),
            );
          },
          child: Container(
            width: defaultSize * 228,
            height: defaultSize * 40,
            decoration: BoxDecoration(
                color: kMainColor,
                borderRadius: BorderRadius.all(Radius.circular(18))),
            child: Center(
              child: Text(
                "애창곡 추가하기",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
