import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:conopot/components/custom_page_route.dart';
import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/screens/pitch/pitch_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';

class PitchMeasure extends StatefulWidget {
  PitchMeasure({Key? key}) : super(key: key);

  @override
  State<PitchMeasure> createState() => _PitchMeasureState();
}

class _PitchMeasureState extends State<PitchMeasure> {
  final _audioRecorder = FlutterAudioCapture();
  final pitchDetectorDartIos = PitchDetector(16000, 3000);
  final pitchDetectorDartAos = PitchDetector(44100, 2000);
  final pitchupDart = PitchHandler(InstrumentType.guitar);

  var note = ""; //음정 알파벳
  late double frequency; //진동수
  late double maxFrequency;
  late int flag; //음 측정 중인지 확인
  late String nowPitchName;
  late String selected1;
  late String selected2;
  bool initialSetting1 = false;
  bool initialSetting2 = false;
  bool playFlag = false;
  double defaultSize = SizeConfig.defaultSize;
  double screenHeight = SizeConfig.screenHeight;
  double screenWidth = SizeConfig.screenWidth;

  @override
  void initState() {
    super.initState();
    frequency = 0;
    maxFrequency = 0;
    flag = 0;
    nowPitchName = "";
    selected1 = "1옥타브";
    selected2 = "도";
  }

  Future<void> _startCapture() async {
    //마이크 사용 권한 확인 (android)
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses =
          await [Permission.microphone].request();
      //만약 있다면
      if (statuses[Permission.microphone]!.isGranted) {
        await _audioRecorder.start(listener, onError,
            sampleRate: 44100, bufferSize: 3000);
        setState(() {
          note = "";
        });
      } else {
        _showPermissionDialog();
      }
    } else {
      Map<Permission, PermissionStatus> statuses =
          await [Permission.microphone].request();
      if (statuses[Permission.microphone]!.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        await _audioRecorder.start(listener, onError,
            sampleRate: 16000, bufferSize: 3000);
        setState(() {
          note = "";
        });
      }
    }
  }

  void _showPermissionDialog() {
    Widget okButton = TextButton(
      child: Text("설정으로 이동",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      onPressed: () {
        openAppSettings();
      },
    );

    Widget cancelButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        "취소",
        style:
            TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlackColor),
      ),
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        "마이크 서비스를 사용할 수 없습니다. 기기의 '설정> 개인정보 보호'에서 마이크 서비스를 켜주세요.(필수권한)",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(child: alert);
        });
  }

  Future<void> _stopCapture() async {
    await _audioRecorder.stop();

    setState(() {
      note = "";
      frequency = 0;
    });
  }

  void onError(Object e) {
    print(e);
  }

  void listener(dynamic obj) {
    //Gets the audio sample
    var buffer = Float64List.fromList(obj.cast<double>());
    final List<double> audioSample = buffer.toList();

    //Uses pitch_detector_dart library to detect a pitch from the audio sample
    var result = pitchDetectorDartAos.getPitch(audioSample);
    if (Platform.isAndroid) {
      result = pitchDetectorDartAos.getPitch(audioSample);
    } else {
      result = pitchDetectorDartIos.getPitch(audioSample);
    }

    //If there is a pitch - evaluate it
    if (result.pitched) {
      //Uses the pitchupDart library to check a given pitch for a Guitar
      final handledPitchResult = pitchupDart.handlePitch(result.pitch);

      //Updates the state with the result
      setState(() {
        note = handledPitchResult.note;
        frequency = handledPitchResult.expectedFrequency;
        maxFrequency = max(maxFrequency, frequency);
      });
    }
  }

  void play(String fitch) async {
    _stopCapture();
    final player = AudioCache(prefix: 'assets/fitches/');

    Timer(Duration(milliseconds: 50), () async {
      await player.play('$fitch.mp3');
    });

    setState(() {
      flag = 1;
      playFlag = true;
    });

    Timer(Duration(milliseconds: 3000), () {
      //누르고 2.5초 후 음 측정 시작
      _startCapture();
    });
  }

  String frequencyToPitch(double frequency) {
    String ret = "";
    if (130 <= frequency && frequency <= 135)
      ret = "1옥타브 도";
    else if (138 <= frequency && frequency <= 141)
      ret = "1옥타브 도#";
    else if (145 <= frequency && frequency <= 150)
      ret = "1옥타브 레";
    else if (155 <= frequency && frequency <= 158)
      ret = "1옥타브 레#";
    else if (160 <= frequency && frequency <= 165)
      ret = "1옥타브 미";
    else if (173 <= frequency && frequency <= 178)
      ret = "1옥타브 파";
    else if (184 <= frequency && frequency <= 186)
      ret = "1옥타브 파#";
    else if (195 <= frequency && frequency <= 200)
      ret = "1옥타브 솔";
    else if (207 <= frequency && frequency <= 209)
      ret = "1옥타브 솔#";
    else if (218 <= frequency && frequency <= 223)
      ret = "1옥타브 라";
    else if (232 <= frequency && frequency <= 234)
      ret = "1옥타브 라#";
    else if (245 <= frequency && frequency <= 250)
      ret = "1옥타브 시";
    else if (260 <= frequency && frequency <= 265)
      ret = "2옥타브 도";
    else if (276 <= frequency && frequency <= 278)
      ret = "2옥타브 도#";
    else if (290 <= frequency && frequency <= 303)
      ret = "2옥타브 레";
    else if (310 <= frequency && frequency <= 312)
      ret = "2옥타브 레#";
    else if (325 <= frequency && frequency <= 330)
      ret = "2옥타브 미";
    else if (345 <= frequency && frequency <= 350)
      ret = "2옥타브 파";
    else if (369 <= frequency && frequency <= 371)
      ret = "2옥타브 파#";
    else if (390 <= frequency && frequency <= 395)
      ret = "2옥타브 솔";
    else if (414 <= frequency && frequency <= 416)
      ret = "2옥타브 솔#";
    else if (438 <= frequency && frequency <= 443)
      ret = "2옥타브 라";
    else if (465 <= frequency && frequency <= 467)
      ret = "2옥타브 라#";
    else if (492 <= frequency && frequency <= 497)
      ret = "2옥타브 시";
    else if (520 <= frequency && frequency <= 525)
      ret = "3옥타브 도";
    else if (553 <= frequency && frequency <= 555)
      ret = "3옥타브 도#";
    else if (585 <= frequency && frequency <= 590)
      ret = "3옥타브 레";
    else if (621 <= frequency && frequency <= 623)
      ret = "3옥타브 레#";
    else if (655 <= frequency && frequency <= 670)
      ret = "3옥타브 미";
    else if (695 <= frequency && frequency <= 700)
      ret = "3옥타브 파";
    else if (739 <= frequency && frequency <= 741)
      ret = "3옥타브 파#";
    else if (780 <= frequency && frequency <= 785)
      ret = "3옥타브 솔";
    else if (830 <= frequency && frequency <= 832)
      ret = "3옥타브 솔#";
    else if (880 <= frequency && frequency <= 885)
      ret = "3옥타브 라";
    else if (931 <= frequency && frequency <= 933)
      ret = "3옥타브 라#";
    else if (985 <= frequency && frequency <= 990) ret = "3옥타브 시";

    return ret;
  }

  List<String> octave1 = [
    '1옥타브',
    '2옥타브',
    '3옥타브',
  ];

  List<String> octave2 = [
    '도',
    '도#',
    '레',
    '레#',
    '미',
    '파',
    '파#',
    '솔',
    '솔#',
    '라',
    '라#',
    '시',
  ];

  var pitchIdx = 0;

  @override
  Widget build(BuildContext context) {
    //!event : 직접 음역대 측정 뷰  - 페이지뷰
    Analytics_config.analytics.logEvent('직접 음역대 측정 뷰 - 페이지뷰');
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '음역대 측정',
          ),
          centerTitle: true,
          leading: BackButton(
              color: kPrimaryWhiteColor,
              onPressed: () {
                _stopCapture();
                Navigator.pop(context); //뒤로가기
              },
            ),
        ),
        
        body: SafeArea(
            child: flag == 0 || flag == 1 ? _firstScreen() : _secondScreen()));
  }

  Widget _picker1() {
    int initialIndex = 0;
    if (maxFrequency >= 130 && initialSetting1 == false) {
      String highestPitch = frequencyToPitch(maxFrequency);
      selected1 = highestPitch == "" ? selected1 : highestPitch.substring(0, 4);
      for (var i = 0; i < octave1.length; i++) {
        if (selected1 == octave1[i]) initialIndex = i;
      }
      initialSetting1 = true;
    }
    return CupertinoPicker(
        itemExtent: 75,
        scrollController:
            FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: (i) {
          setState(() {
            selected1 = octave1[i];
          });
        },
        children: [
          ...octave1.map((e) => Center(
                child: Text(
                  e,
                ),
              ))
        ]);
  }

  Widget _picker2() {
    int initialIndex = 0;
    if (maxFrequency >= 130 && initialSetting2 == false) {
      String highestPitch = frequencyToPitch(maxFrequency);
      selected2 = highestPitch == ""
          ? selected2
          : highestPitch.substring(5, highestPitch.length);
      for (var i = 0; i < octave2.length; i++) {
        if (selected2 == octave2[i]) initialIndex = i;
      }
      initialSetting2 = true;
    }

    return CupertinoPicker(
        itemExtent: 75,
        scrollController:
            FixedExtentScrollController(initialItem: initialIndex),
        onSelectedItemChanged: (i) {
          setState(() {
            selected2 = octave2[i];
          });
        },
        children: [
          ...octave2.map((e) => Center(
                child: Text(
                  e,
                ),
              ))
        ]);
  }

  // 측정 시작, 측정 중지 화면
  Widget _firstScreen() {
    return Container(
      width: screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Container(
                  margin: EdgeInsets.only(left: defaultSize * 3),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '노래를 불러 보세요 🎤',
                          style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontSize: defaultSize * 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.defaultSize * 1.5,
                        ),
                        Row(
                          children: [
                            Text(
                              '최고',
                              style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.symmetric(horizontal: defaultSize),
                              padding: EdgeInsets.all(defaultSize),
                              decoration: BoxDecoration(
                                color: kPrimaryLightBlackColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                "${frequencyToPitch(maxFrequency)}",
                                style: TextStyle(
                                  color: kPrimaryWhiteColor,
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '까지 올라갔어요!',
                              style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontSize: defaultSize * 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(defaultSize * 3),
            padding: EdgeInsets.all(defaultSize * 3),
            decoration: BoxDecoration(
              color: kPrimaryLightBlackColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Text(
                    "현재 측정 음",
                    style: TextStyle(
                      fontSize: defaultSize * 1.8,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryWhiteColor,
                    ),
                  ),
                  flag == 0
                      ? Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: defaultSize * 5),
                                child: Icon(
                                  Icons.remove,
                                  color: kPrimaryWhiteColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  //!event : 직접 음역대 측정 뷰  - 측정 시작
                                  Analytics_config.analytics
                                      .logEvent('직접 음역대 측정 뷰 - 측정 시작');
                                  _startCapture();
                                  setState(() {
                                    flag = 1;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: defaultSize * 3.5),
                                  padding: EdgeInsets.all(defaultSize),
                                  child: Center(
                                      child: Text(
                                    "측정 시작",
                                    style: TextStyle(
                                        color: kPrimaryWhiteColor,
                                        fontSize: defaultSize * 1.6,
                                        fontWeight: FontWeight.w600),
                                  )),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: kMainColor),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: defaultSize * 5),
                                child: Text(
                                  frequencyToPitch(frequency),
                                  style: TextStyle(
                                      color: kPrimaryWhiteColor,
                                      fontSize: defaultSize * 3,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // !event : 직접 음역대 측정 뷰  - 측정 중지
                                  Analytics_config.analytics
                                      .logEvent('직접 음역대 측정 뷰 - 측정 중지');
                                  _stopCapture();
                                  setState(() {
                                    flag = 2;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: defaultSize * 3.5),
                                  padding: EdgeInsets.all(defaultSize),
                                  child: Center(
                                      child: Text(
                                    "측정 중지",
                                    style: TextStyle(
                                        color: kPrimaryWhiteColor,
                                        fontSize: defaultSize * 1.6,
                                        fontWeight: FontWeight.w600),
                                  )),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: kPrimaryGreyColor),
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 최고음 선택 화면
  Widget _secondScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '내 최고음 선택하기',
              style: TextStyle(
                color: kPrimaryWhiteColor,
                fontSize: defaultSize * 2.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(
          height: defaultSize * 5,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: defaultSize * 3),
          padding: EdgeInsets.all(defaultSize),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: kPrimaryLightBlackColor),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: defaultSize * 10,
                      height: defaultSize * 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _picker1()),
                  Container(
                      width: defaultSize * 10,
                      height: defaultSize * 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _picker2()),
                ],
              ),
              SizedBox(height: defaultSize),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      //!event : 직접 음역대 측정 뷰  - 다시 측정하기
                      Analytics_config.analytics
                          .logEvent('직접 음역대 측정 뷰 - 다시 측정하기');
                      setState(() {
                        flag = 0;
                        frequency = 0;
                        maxFrequency = 0;
                        nowPitchName = "";
                        selected1 = "1옥타브";
                        selected2 = "도";
                        initialSetting1 = false;
                        initialSetting2 = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(defaultSize),
                      child: Center(
                          child: Text(
                        "다시 측정",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w600),
                      )),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: kPrimaryGreyColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      //!event : 직접 음역대 측정 뷰  - 다시 측정하기
                      Analytics_config.analytics
                          .logEvent('직접 음역대 측정 뷰 - 다시 측정하기');
                      Navigator.push(
                          context,
                          CustomPageRoute(
                            child: PitchResult(
                                fitchLevel: StringToPitchNum[
                                    selected1 + ' ' + selected2]),
                          ));
                    },
                    child: Container(
                      padding: EdgeInsets.all(defaultSize),
                      child: Center(
                          child: Text(
                        "선택 완료",
                        style: TextStyle(
                            color: kPrimaryWhiteColor,
                            fontWeight: FontWeight.w600),
                      )),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: kMainColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: defaultSize * 2)
            ],
          ),
        ),
      ],
    );
  }
}
