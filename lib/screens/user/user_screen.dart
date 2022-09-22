import 'dart:io';
import 'package:conopot/models/note_data.dart';
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
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:http/http.dart' as http;

const String USER_SERVER_URL =
    'https://port-0-conopotuserserver-2qr6k24l7ya85sc.gksl1.cloudtype.app';

// const String USER_SERVER_URL =
//     'https://port-0-conopotuserserver-2qr6k24l7ya85sc.gksl1.cloudtype.app';

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
                      kakaologin(context);
                    },
                  ),
                  // IOS 유저인 경우만 버튼 표시
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
                          print("identityToken: ${credential.identityToken}");
                          print("email: ${credential.email}");
                          print("firstName: ${credential.givenName}");
                          print("lastName: ${credential.familyName}");
                          appleRegister(context, credential);
                        })
                      : SizedBox.shrink(),
                  GestureDetector(
                    child: Text(
                      "저장한 노트 백업하기",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      Provider.of<NoteData>(context, listen: false).saveNotes();
                    },
                  ),
                  GestureDetector(
                    child: Text(
                      "저장한 노트 불러오기",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      Provider.of<NoteData>(context, listen: false).loadNotes();
                      ;
                    },
                  ),
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

  void kakaologin(BuildContext context) async {
    // 카카오톡이 설치되어있는 경우
    if (await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        kakaoRegister(context, token);
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
      }
      // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
    } else {
      loginKakaoAccount(context);
    }
  }
}

Future<void> loginKakaoAccount(BuildContext context) async {
  try {
    OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
    print('카카오계정으로 로그인 성공 ${token.accessToken}');
    kakaoRegister(context, token);
  } catch (error) {
    print('카카오계정으로 로그인 실패 $error');
  }
}

// 토큰을 이용해 kakao 정보를 백엔드로 넘겨준다(등록)
void kakaoRegister(BuildContext context, OAuthToken token) async {
  String url = '$USER_SERVER_URL/auth/kakao/signin';

  try {
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'accessToken': token.accessToken,
        }));

    print("응답 헤더 : ${response.headers}");
    print("응답 바디 : ${response.body}");

    //jwt 토큰 반환
    String? jwtToken = response.headers['authorization'];
    print("jwt 토큰 : ${jwtToken}");

    //로컬 스토리지에 jwt 토큰 저장
    Provider.of<NoteData>(context, listen: false).writeJWT(jwtToken);

    Map<String, dynamic> payload = Jwt.parseJwt(jwtToken!);
    print("jwt 내부 회원정보(payload) : ${payload}");
  } catch (err) {
    print("카카오 로그인 백엔드 연결 실패 : ${err}");
  }
}

// 토큰을 이용해 kakao 정보를 백엔드로 넘겨준다(등록)
void appleRegister(
    BuildContext context, AuthorizationCredentialAppleID credential) async {
  String url = '$USER_SERVER_URL/auth/apple/signin';
  print("애플 로그인 시도");

  try {
    String? username = '${credential.familyName}${credential.givenName}';
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'appleIdToken': credential.identityToken,
          'username': username,
          'email': credential.email,
        }));

    //서버측에서 토큰 검증을 성공한 경우 (서버에 사용자 정보 저장)
    if (response.statusCode == 200) {
      print("애플 로그인 성공");
      print("응답 헤더 : ${response.headers}");
      print("응답 바디 : ${response.body}");

      //jwt 토큰 반환
      String? jwtToken = response.headers['authorization'];
      print("jwt 토큰 : ${jwtToken}");

      //로컬 스토리지에 jwt 토큰 저장
      Provider.of<NoteData>(context, listen: false).writeJWT(jwtToken);

      Map<String, dynamic> payload = Jwt.parseJwt(credential.identityToken!);
      print("jwt 내부 회원정보(payload) : ${payload}");
    } else {
      //토큰 검증에 실패한 경우
      print("애플 로그인 토큰 검증 실패");
    }
  } catch (err) {
    print("애플 로그인 백엔드 연결 실패 : ${err}");
  }
}
