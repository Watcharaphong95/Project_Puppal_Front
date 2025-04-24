import 'package:flutter/material.dart';

class registerUserModel extends ChangeNotifier {
  String username = '';
  String name = '';
  String surname = '';
  String email = '';
  String password = '';
  String phone = '';
  String address = '';
  String imageUrl = '';

  String get _username => username;
  String get _name => name;
  String get _surname => surname;
  String get _email => email;
  String get _password => password;
  String get _phone => phone;
  String get _address => address;
  String get _imageUrl => imageUrl;

  void setUsername(String value) {
    username = value;
    notifyListeners();
  }

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setSurname(String value) {
    surname = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setAddress(String value) {
    address = value;
    notifyListeners();
  }

  void setImageUrl(String value) {
    imageUrl = value;
    notifyListeners();
  }
}
