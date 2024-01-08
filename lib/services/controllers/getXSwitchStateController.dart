import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class GetXSwitchState extends GetxController {
  static GetXSwitchState get instance => Get.find();

  RxBool isOnline = false.obs;
  RxBool isNotify = false.obs;
  RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  final switchDataController = GetStorage();

  changeSwitchState(bool val){
    isOnline.value = val;
    switchDataController.write('isSwitched', isOnline.value);
    update();
  }

  changeNotifyState(bool val){
    isNotify.value = val;
    switchDataController.write('notifyData', isNotify.value);
    update();
  }

  changeThemeMode(bool val){
    _isDarkMode.value = val;
    switchDataController.write('themeMode', _isDarkMode.value);
    update();
  }


  GetXSwitchState(){
    if(switchDataController.read('isSwitched') != null){
      isOnline.value = switchDataController.read('isSwitched');
      update();
    }

    if(switchDataController.read('notifyData') != null){
      isNotify.value = switchDataController.read('notifyData');
      update();
    }
  }

}