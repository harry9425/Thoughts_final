class ThoughtModel {
  late String _thought;
  late String _key;
  late String _coor;
  late String _time;
  late String _userid;
  late String _locks;
  late String _agree;
  late String _sentiment;
  late String _username;
  late String _userdp;

  String get thought => _thought;
  set thought(String thought) => _thought = thought;

  String get sentiment => _sentiment;
  set sentiment(String sentiment) => _sentiment = sentiment;

  String get key => _key;
  set key(String key) => _key = key;

  String get lock => _locks;
  set lock(String lock) => _locks = lock;

  String get agree => _agree;
  set agree(String agree) => _agree = agree;

  String get coor => _coor;
  set coor(String coor) => _coor = coor;

  String get time => _time;
  set time(String time) => _time = time;

  String get userid => _userid;
  set userid(String userid) => _userid = userid;

  String get username => _username;
  set username(String username) => _username = username;

  String get userdp => _userdp;
  set userdp(String userdp) => _userdp = userdp;

  ThoughtModel.empty();

  ThoughtModel(this._thought, this._key, this._coor, this._time, this._userid, this._username, this._userdp);

  Map<String, dynamic> toMap() {
    return {
      'thought': thought,
      'sentiment': sentiment,
      'key': key,
      'coor': coor,
      'time': time,
      'userid': userid,
      'agree': agree,
      'lock': lock,
      'username': username,
      'userdp': userdp,
    };
  }
}
