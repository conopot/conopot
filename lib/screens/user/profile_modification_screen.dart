import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/note_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProfileModificationScreen extends StatefulWidget {
  const ProfileModificationScreen({super.key});

  @override
  State<ProfileModificationScreen> createState() =>
      _ProfileModificationScreenState();
}

class _ProfileModificationScreenState extends State<ProfileModificationScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    this._controller = TextEditingController(
      text: Provider.of<NoteData>(context, listen: false).userNickname,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      appBar: AppBar(title: Text("프로필 수정"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: defaultSize * 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                      width: defaultSize * 10,
                      height: defaultSize * 10,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: FittedBox(
                        child: SvgPicture.asset("assets/icons/profile.svg"),
                      )),
                  SizedBox(height: defaultSize * 1.5),
                  GestureDetector(
                      onTap: () {
                        EasyLoading.showInfo("서비스 준비중입니다 😿");
                      },
                      child:
                          Text("프로필 아이콘 변경", style: TextStyle(color: kMainColor)))
                ],
              ),
            ],
          ),
          SizedBox(height: defaultSize * 8),
          Container(
            margin: EdgeInsets.symmetric(horizontal: defaultSize * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("닉네임",
                    style: TextStyle(
                        color: kPrimaryWhiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: defaultSize * 1.6)),
                TextField(
                  controller: _controller,
                  maxLength: 10,
                  cursorColor: kPrimaryWhiteColor,
                  style: TextStyle(
                      color: kPrimaryWhiteColor, fontSize: defaultSize * 1.4),
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryWhiteColor),
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryWhiteColor)),
                      border: UnderlineInputBorder(),
                      hintText: '닉네임을 입력해 주세요',
                      hintStyle: TextStyle(color: kPrimaryLightGreyColor),
                      counterStyle: TextStyle(color: kPrimaryLightWhiteColor)),
                ),
              ],
            ),
          ),
          SizedBox(height: defaultSize * 5),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: defaultSize * 1.5),
              padding: EdgeInsets.fromLTRB(defaultSize * 1.5, defaultSize,
                  defaultSize * 1.5, defaultSize),
              decoration: BoxDecoration(
                  color: (_controller.text.length == 0)
                      ? kPrimaryLightBlackColor
                      : kMainColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Text(
                "변경사항 저장",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontSize: defaultSize * 1.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
