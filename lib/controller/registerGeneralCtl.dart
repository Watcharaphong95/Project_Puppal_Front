import 'package:get/get.dart';

class RegisterGeneralCtl extends GetxController {
  var username = ''.obs;
  var name = ''.obs;
  var surname = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var phone = ''.obs;
  var address = ''.obs;
  var lat = ''.obs;
  var lng = ''.obs;
  var imageUrl = ''.obs;

  void setUsername(String value) {
    username.value = value;
  }

  void setName(String value) {
    name.value = value;
  }

  void setSurname(String value) {
    surname.value = value;
  }

  void setEmail(String value) {
    email.value = value;
  }

  void setPassword(String value) {
    password.value = value;
  }

  void setPhone(String value) {
    phone.value = value;
  }

  void setAddress(String value) {
    address.value = value;
  }

  void setLat(String value) {
    lat.value = value;
  }

  void setLng(String value) {
    lng.value = value;
  }

  void setImageUrl(String value) {
    imageUrl.value = value;
  }
}
