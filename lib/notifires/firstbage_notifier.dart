import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Firstbage extends AsyncNotifier {
  @override
  FutureOr<dynamic> build() async {
    return await getMonthlyBudget();
  }

  Future<void> savedMonthlyBudget(double monthlyBudget) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble("monthlyBudget", monthlyBudget);
    state = AsyncData(monthlyBudget);
  }

  Future<double?> getMonthlyBudget() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble("monthlyBudget");
  }
}
