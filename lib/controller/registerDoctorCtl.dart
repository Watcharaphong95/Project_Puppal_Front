import 'package:get/get.dart';
import 'package:puppal_application/model/doctorPost.dart';

class registerDoctorCtl extends GetxController {
  var name = ''.obs;
  var surname = ''.obs;
  var careerNo = ''.obs;
  var image = ''.obs;
  var special = ''.obs;

  void setName(String value) {
    name.value = value;
  }

  void setSurname(String value) {
    surname.value = value;
  }

  void setCareerNo(String value) {
    careerNo.value = value;
  }

  void setImage(String value) {
    image.value = value;
  }

  void setSpecial(String value) {
    special.value = value;
  }
}

class doctorDataList extends GetxController {
  var doctorList = <DoctorPost>[].obs;

  void addDoctor(DoctorPost doctor) {
    doctorList.add(doctor);
  }

  void removeDoctor(DoctorPost doctor) {
    doctorList.remove(doctor);
  }
}
