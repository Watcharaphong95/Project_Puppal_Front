import 'package:get/get.dart';

class registerDogCtl extends GetxController {
  var name = ''.obs;
  var breed = ''.obs;
  var gender = ''.obs;
  var color = ''.obs;
  var defect = ''.obs;
  var birthday = ''.obs;
  var disease = ''.obs;
  var sterilization = ''.obs;
  var hair = ''.obs;
  var image = ''.obs;

  void setName(String value) {
    name.value = value;
  }

  void setBreed(String value) {
    breed.value = value;
  }

  void setGender(String value) {
    gender.value = value;
  }

  void setColor(String value) {
    color.value = value;
  }

  void setDefect(String value) {
    defect.value = value;
  }

  void setBirthday(String value) {
    birthday.value = value;
  }

  void setDisease(String value) {
    disease.value = value;
  }

  void setSterilization(String value) {
    sterilization.value = value;
  }

  void setHair(String value) {
    hair.value = value;
  }

  void setImage(String value) {
    image.value = value;
  }
}
