import 'package:get/get.dart';
import 'package:puppal_application/model/injectionRecordPost.dart';

class RegisterDogInjectionCtl extends GetxController {
  var clinicName = ''.obs;
  var vaccineType = ''.obs;
  var date = ''.obs;
  var status = ''.obs;

  void setClinicName(String value) {
    clinicName.value = value;
  }

  void setVaccineType(String value) {
    vaccineType.value = value;
  }

  void setDate(String value) {
    date.value = value;
  }

  void setStatus(String value) {
    status.value = value;
  }
}

class injectionRecordList extends GetxController {
  var recordList = <InjectionRecordPost>[].obs;

  void addRecord(InjectionRecordPost data) {
    recordList.add(data);
  }

  void removeRecord(InjectionRecordPost data) {
    recordList.remove(data);
  }
}
