class FitchMusic {
  final String tj_title;
  final String tj_singer;
  final String tj_songNumber;
  final String ky_title;
  final String ky_singer;
  final String ky_songNumber;
  final String gender;
  final int pitchNum;

  final String search_keyword_title_singer;
  final String search_keyword_singer_title;

  FitchMusic(
      this.tj_title,
      this.tj_singer,
      this.tj_songNumber,
      this.ky_title,
      this.ky_singer,
      this.ky_songNumber,
      this.gender,
      this.pitchNum,
      this.search_keyword_title_singer,
      this.search_keyword_singer_title);

  //object -> json 변환 장치 (local storage 사용 목적)
  Map toJson() => {
        'tj_title': tj_title,
        'tj_singer': tj_singer,
        'tj_songNumber': tj_songNumber,
        'ky_title': ky_title,
        'ky_singer': ky_singer,
        'ky_songNumber': ky_songNumber,
        'gender': gender,
        'pitchNum': pitchNum,
        'search_keyword_title_singer': tj_title + tj_singer,
        'search_keyword_singer_title': tj_singer + tj_title
      };

  //json -> object 변환 장치
  factory FitchMusic.fromJson(dynamic json) {
    return FitchMusic(
        json['tj_title'] as String,
        json['tj_singer'] as String,
        json['tj_songNumber'] as String,
        json['ky_title'] as String,
        json['ky_singer'] as String,
        json['ky_songNumber'] as String,
        json['gender'] as String,
        json['pitchNum'] as int,
        json['search_keyword_title_singer'] as String,
        json['search_keyword_singer_title'] as String);
  }
}
