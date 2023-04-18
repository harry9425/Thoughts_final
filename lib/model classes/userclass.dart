class UserModel {
  late String _name;
  late String _id;
  late String _email;
  late String _phone;
  late String _password;
  late String _userdp;

  String get name => _name;
  set name(String name) => _name = name;

  String get userdp => _userdp;
  set uderdp(String dp) => _userdp = dp;

  String get id => _id;
  set id(String id) => _id = id;

  String get email => _email;
  set email(String email) => _email = email;

  String get phone => _phone;
  set phone(String phone) => _phone = phone;

  String get password => _password;
  set password(String password) => _password = password;

  UserModel.empty();

  UserModel(this._name, this._id, this._email, this._phone, this._password);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userdp': userdp,
      'id': id,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

}
