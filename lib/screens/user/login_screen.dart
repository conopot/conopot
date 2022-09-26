import 'dart:convert';
import 'dart:io';

import 'package:conopot/models/note_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:conopot/config/constants.dart';
import 'package:conopot/config/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.close, color: kPrimaryWhiteColor)),
        ),
        body: Container(
          padding: EdgeInsets.only(left: defaultSize * 4),
          color: kBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "나만의 노래방 동반자",
                style: TextStyle(
                    color: kPrimaryWhiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: defaultSize * 2),
              ),
              Text(
                "애창곡 노트",
                style: TextStyle(
                    color: kMainColor,
                    fontWeight: FontWeight.w700,
                    fontSize: defaultSize * 3.5),
              ),
              SizedBox(height: defaultSize * 8),
              GestureDetector(
                onTap: () {
                  kakaoLogin(context);
                },
                child: Container(
                    margin: EdgeInsets.only(right: defaultSize * 4),
                    child: Image.asset(
                        "assets/images/kakao_login_large_wide.png")),
              ),
              SizedBox(height: defaultSize),
              Platform.isIOS
                  ? GestureDetector(
                      onTap: () async {
                        final credential =
                            await SignInWithApple.getAppleIDCredential(scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ]);
                        // credential 발급 후 backend쪽으로 firstname, lastname, authorizationcode를 넘겨줘야 한다고함
                        // backend에서 아래 넘겨준 정보로 validate하고 jwt반환
                        appleRegister(context, credential);
                      },
                      child: Container(
                          margin: EdgeInsets.only(right: defaultSize * 4),
                          child:
                              Image.asset("assets/images/sign_in_apple.png")))
                  : SizedBox.shrink(),
            ],
          ),
        ));
  }

  void kakaoLogin(BuildContext context) async {
    // 카카오톡이 설치되어있는 경우
    if (await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        // print('카카오톡으로 로그인 성공');
        kakaoRegister(context, token);
      } catch (error) {
        //print('카카오톡으로 로그인 실패 $error');

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
    //print('카카오계정으로 로그인 성공 ${token.accessToken}');
    kakaoRegister(context, token);
  } catch (error) {
    //print('카카오계정으로 로그인 실패 $error');
  }
}

// 토큰을 이용해 kakao 정보를 백엔드로 넘겨준다(등록)
void kakaoRegister(BuildContext context, OAuthToken token) async {
  String? serverURL = dotenv.env['USER_SERVER_URL'];

  String url = '$serverURL/auth/kakao/signin';

  try {
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'accessToken': token.accessToken,
        }));

    //print("응답 헤더 : ${response.headers}");
    //print("응답 바디 : ${response.body}");

    //jwt 토큰 반환
    String? jwtToken = response.headers['authorization'];
    //print("jwt 토큰 : ${jwtToken}");

    //로그인 성공 시 처리
    loginSuccess(jwtToken, context);

    Navigator.of(context).pop();
  } catch (err) {
    //print("카카오 로그인 백엔드 연결 실패 : ${err}");
  }
}

// 토큰을 이용해 kakao 정보를 백엔드로 넘겨준다(등록)
void appleRegister(
    BuildContext context, AuthorizationCredentialAppleID credential) async {
  String? serverURL = dotenv.env['USER_SERVER_URL'];
  String url = '$serverURL/auth/apple/signin';
  //print("애플 로그인 시도");

  try {
    String? username = '${credential.familyName}${credential.givenName}';
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'appleIdToken': credential.identityToken,
          'username': username,
          'userId': credential.userIdentifier,
        }));

    //서버측에서 토큰 검증을 성공한 경우 (서버에 사용자 정보 저장)
    if (response.statusCode == 200) {
      //print("애플 로그인 성공");
      //print("응답 헤더 : ${response.headers}");
      //print("응답 바디 : ${response.body}");

      //jwt 토큰 반환
      String? jwtToken = response.headers['authorization'];
      //print("jwt 토큰 : ${jwtToken}");

      //로그인 성공 시 처리
      loginSuccess(jwtToken, context);

      Navigator.of(context).pop();
    } else {
      //토큰 검증에 실패한 경우
      //print("애플 로그인 토큰 검증 실패");
    }
  } catch (err) {
    //print("애플 로그인 백엔드 연결 실패 : ${err}");
  }
}

void loginSuccess(String? jwtToken, BuildContext context) {
  //로컬 스토리지에 jwt 토큰 저장
  Provider.of<NoteData>(context, listen: false).writeJWT(jwtToken);

  Provider.of<NoteData>(context, listen: false).initAccountInfo();
}
