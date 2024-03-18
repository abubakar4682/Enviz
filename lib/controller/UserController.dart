import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Model/user.dart';

class UserController extends GetxController {
  var user = Rxn<User>();

  void setUser(User newUser) {
    user.value = newUser;
  }
}