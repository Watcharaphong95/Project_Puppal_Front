import 'package:get/get.dart';

class registerClinicCtl extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var phone = ''.obs;
  var address = ''.obs;
  var open = ''.obs;
  var close = ''.obs;
  var weekdays = ''.obs;
  var numPerTime = 0.obs;
  var lat = ''.obs;
  var lng = ''.obs;
  var imageUrl = ''.obs;

  void setName(String value) {
    name.value = value;
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

  void setOpen(String value) {
    open.value = value;
  }

  void setClose(String value) {
    close.value = value;
  }

  void setweekdays(String value) {
    weekdays.value = value;
  }

  void setNumPerTime(int value) {
    numPerTime.value = value;
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
