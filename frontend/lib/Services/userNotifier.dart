import 'package:flutter/material.dart';

import '../Models/EmployeeModel.dart';

class User with ChangeNotifier {
  EmployeeModel? _user;
  EmployeeModel? get user => _user;
  set user(EmployeeModel? user) {
    _user = user;
    notifyListeners();
  }
}
