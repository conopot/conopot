import 'package:conopot/components/custom_page_route.dart';
import 'package:conopot/models/pitch_item.dart';
import 'package:conopot/screens/pitch/pitch_result.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PitchBanner extends StatelessWidget {
  final PitchItem fitchItem;
  const PitchBanner({
    Key? key,
    required this.fitchItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: DefaultTextStyle(
          style: TextStyle(color: Colors.black, fontSize: 20.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    )),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          fitchItem.pitchName,
                          style: TextStyle(
                            fontSize: 21.0,
                          ),
                        ),
                        Text(
                          fitchItem.pitchCode,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.defaultSize,
                        ),
                        Text(
                          fitchItem.pitchContext,
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            play(fitchItem.pitchCode);
                          },
                          child: Icon(
                            Icons.play_circle_outline_outlined,
                            color: Colors.black,
                            size: 40.0,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            //local storage? or 최종결과 page route
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                child: PitchResult(fitchLevel: fitchItem.id),
                              ),
                            );
                          },
                          child: Text(
                            '더 이상 안올라가요!',
                            style: TextStyle(
                              color: Color(0xFF7B61FF),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ]),
                ),
              )
            ],
          )),
    );
  }
}

void play(String fitch) async {
  final player = AudioCache(prefix: 'assets/fitches/');
  await player.play('$fitch.mp3');
}
