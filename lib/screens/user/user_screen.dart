import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:conopot/config/analytics_config.dart';
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:conopot/models/music_search_item_list.dart';
import 'package:conopot/screens/user/components/channel_talk.dart';
import 'package:conopot/screens/user/user_note_setting_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:http/http.dart' as http;

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  double defaultSize = SizeConfig.defaultSize;

  @override
  void initState() {
    Analytics_config.analytics.logEvent("내 정보 뷰 - 페이지뷰");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Analytics_config().settingPageView();
    return Consumer<MusicSearchItemLists>(
        builder: (
      context,
      musicList,
      child,
    ) =>
            Scaffold(
              appBar: AppBar(
                title: Text(
                  "설정",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(children: [
                  SizedBox(height: defaultSize),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoteSettingScreen()));
                    },
                    splashColor: Colors.transparent,
                    child: Container(
                      height: defaultSize * 4,
                      padding:
                          EdgeInsets.symmetric(horizontal: defaultSize * 2),
                      child: Row(children: [
                        Text("애창곡 노트 설정",
                            style: TextStyle(
                              color: kPrimaryWhiteColor,
                              fontSize: defaultSize * 1.8,
                              fontWeight: FontWeight.w500,
                            )),
                        Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: kPrimaryWhiteColor,
                        ),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      "카카오 로그인",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      //테스트를 위해 일단 무조건 로그인하는 로직
                      loginTry();
                      // if (await AuthApi.instance.hasToken()) {
                      //   try {
                      //     AccessTokenInfo tokenInfo =
                      //         await UserApi.instance.accessTokenInfo();
                      //     print(
                      //         '토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
                      //   } catch (error) {
                      //     if (error is KakaoException &&
                      //         error.isInvalidTokenError()) {
                      //       print('토큰 만료 $error');
                      //     } else {
                      //       print('토큰 정보 조회 실패 $error');
                      //     }

                      //     loginTry();
                      //   }
                      // } else {
                      //   print('발급된 토큰 없음');
                      //   loginTry();
                      // }
                    },
                  ),
                  Platform.isIOS
                      ? SignInWithAppleButton(onPressed: () async {
                          final credential =
                              await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                AppleIDAuthorizationScopes.email,
                                AppleIDAuthorizationScopes.fullName,
                              ]);
                          // credential 발급 후 backend쪽으로 firstname, lastname, authorizationcode를 넘겨줘야 한다고함
                          // backend에서 아래 넘겨준 정보로 validate하고 jwt반환
                          print(
                              "authorizationCode: ${credential.authorizationCode}");
                          print("firstName: ${credential.givenName}");
                          print("lastName: ${credential.familyName}");
                        })
                      : SizedBox.shrink()
                ]),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
                width: defaultSize * 7.2,
                height: defaultSize * 7.2,
                child: FittedBox(
                  child: FloatingActionButton(
                    elevation: 5.0,
                    onPressed: () {
                      Analytics_config().settingChannelTalk();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChannelTalkScreen()),
                      );
                    },
                    child: Image.asset(
                      "assets/images/channeltalk.png",
                    ),
                  ),
                ),
              ),
            ));
  }

  void loginTry() async {
    if (await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공 ${token.accessToken}');
        register(token);
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공 ${token.accessToken}');
          register(token);
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공 ${token.accessToken}');
        register(token);
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }
}

void register(OAuthToken token) async {
  String url = 'http://10.0.2.2:3000/auth/signin';

  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'accessToken': token.accessToken,
      }));

  //print(response.body);
  print(response.headers);
}
