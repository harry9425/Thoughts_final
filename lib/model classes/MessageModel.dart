class MessageModel {
  late String _type;
  late String _id;
  late String _message;
  late String _userid;
  late String _time;
  late String _imageurl;
  late String _dpurl;
  late String _username;
  late String _messageby;

  String get type => _type;
  set type(String type) => _type = type;

  String get messageby => _messageby;
  set messageby(String messageby) => _messageby = messageby;

  String get time => _time;
  set time(String time) => _time = time;

  String get id => _id;
  set id(String id) => _id = id;

  String get userid => _userid;
  set userid(String userid) => _userid = userid;

  String get imageurl => _imageurl;
  set imageurl(String imageurl) => _imageurl = imageurl;

  String get message => _message;
  set message(String message) => _message = message;

  String get dpurl => _dpurl;
  set dpurl(String dpurl) => _dpurl = dpurl;

  String get username => _username;
  set username(String username) => _username = username;

  MessageModel.empty();

  MessageModel(this._type, this._id, this._userid, this._imageurl, this._message, this._dpurl, this._username, {required String time}) {
    _time = time;
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'time': time,
      'id': id,
      'userid': userid,
      'imageurl': imageurl,
      'message': message,
      'dpurl': dpurl,
      'username': username,
    };
  }
}
