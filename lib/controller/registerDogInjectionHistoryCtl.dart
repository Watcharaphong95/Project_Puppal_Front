import 'package:get/get.dart';
import 'package:puppal_application/model/injectionHistoryPost.dart';

class RegisterDogInjectionCtl extends GetxController {
  var clinicName = ''.obs;
  var vaccineType = ''.obs;
  var date = ''.obs;

  void setClinicName(String value) {
    clinicName.value = value;
  }

  void setVaccineType(String value) {
    vaccineType.value = value;
  }

  void setDate(String value) {
    date.value = value;
  }
}

class injectionHistoryList extends GetxController {
  var doctorList = <InjectionRecordPost>[].obs;

  void addDoctor(InjectionRecordPost data) {
    doctorList.add(data);
  }

  void removeDoctor(InjectionRecordPost data) {
    doctorList.remove(data);
  }
}
