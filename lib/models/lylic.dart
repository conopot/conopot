class Lyric {
  final String lyric;

  const Lyric({required this.lyric});

  factory Lyric.fromJson(List<dynamic> json) {
    if (json.length == 0 || json[0].length == 0 || json[0][0].length == 0) {
      return Lyric(
          lyric:
              "해당 노래에 대한 가사 정보가 없습니다\n가사 요청은\n내 정보 페이지 하단의 문의하기를 이용해주세요 🙋‍♂️");
    } else {
      return Lyric(
        lyric: json[0][0]['lyrics'],
      );
    }
  }
}