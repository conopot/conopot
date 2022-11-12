import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';

class NoteComment extends StatefulWidget {
  const NoteComment({super.key});

  @override
  State<NoteComment> createState() => _NoteCommentState();
}

class _NoteCommentState extends State<NoteComment> {
  bool isCheked = false;
  String comment = "";

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Column(
      children: [
        Expanded(child: ListView()),
        Container(
          height: defaultSize * 5,
          margin: EdgeInsets.symmetric(horizontal: defaultSize),
          padding: EdgeInsets.fromLTRB(
              defaultSize * 1.5, 0, defaultSize * 1.5, 0),
          decoration: BoxDecoration(
              color: kPrimaryGreyColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: kPrimaryLightGreyColor,
                ),
                child: SizedBox(
                  width: defaultSize * 2,
                  height: defaultSize * 2,
                  child: Checkbox(
                      checkColor: kPrimaryBlackColor,
                      activeColor: kMainColor,
                      value: isCheked,
                      onChanged: (bool? value) {
                        setState(() {
                          isCheked = value!;
                        });
                      }),
                ),
              ),
              SizedBox(width: defaultSize * 0.5),
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize * 0.3),
                child: Text(
                  "익명",
                  style: TextStyle(
                      color: (isCheked) ? kMainColor : kPrimaryLightGreyColor,
                      fontSize: defaultSize * 1.3,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: defaultSize),
              Expanded(
                child: TextFormField(
                      style: TextStyle(color: kPrimaryWhiteColor),
                      onChanged: (text) => {
                        setState(() {
                          comment = text;
                        })
                      },
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      cursorColor: kMainColor,
                      decoration: InputDecoration(
                        counter: SizedBox.shrink(),
                        hintText: '댓글을 입력하세요.',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: defaultSize * 1.3,
                          color: kPrimaryLightGreyColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
              ),
              SizedBox(width: defaultSize),
              Icon(Icons.send, color: kMainColor)
            ],
          ),
        ),
      ],
    );
  }
}
