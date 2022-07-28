class Note {
  final String tj_title;
  final String tj_singer;
  final String tj_songNumber;
  final String ky_title;
  final String ky_singer;
  String ky_songNumber;
  final String gender;
  final int pitchNum;
  String memo;
  int keyAdjustment;

  Note(
      this.tj_title,
      this.tj_singer,
      this.tj_songNumber,
      this.ky_title,
      this.ky_singer,
      this.ky_songNumber,
      this.gender,
      this.pitchNum,
      this.memo,
      this.keyAdjustment);

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
        'memo': memo,
        'keyAdjustment': keyAdjustment
      };

  //json -> object 변환 장치
  factory Note.fromJson(dynamic json) {
    return Note(
      json['tj_title'] as String,
      json['tj_singer'] as String,
      json['tj_songNumber'] as String,
      json['ky_title'] as String,
      json['ky_singer'] as String,
      json['ky_songNumber'] as String,
      json['gender'] as String,
      json['pitchNum'] as int,
      json['memo'] as String,
      json['keyAdjustment'] as int,
    );
  }

  @override
  String toString() {
    return '{ ${this.tj_title}, ${this.tj_singer}, ${this.tj_songNumber}, ${this.ky_title}, ${this.ky_singer}, ${this.ky_songNumber}, ${this.gender}, ${this.pitchNum}, ${this.memo}, ${this.keyAdjustment}}';
  }
}
