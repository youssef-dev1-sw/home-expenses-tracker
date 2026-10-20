import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_sql/models/expenses_model.dart';
import 'package:to_do_sql/providers/sql_provider.dart';

class ExpensespageNotifier extends AsyncNotifier<List<Expensesmodel>> {
  @override
  FutureOr<List<Expensesmodel>> build() async {
    return await showAllExpense();
  }

  Future<List<Expensesmodel>> showAllExpense() async {
    final data = await ref
        .read(sqlProvider)
        .selectData("SELECT * FROM homeexpenses");
    return Expensesmodel.fromMapList(data);
  }

  Future<void> addExpense(
    String category,
    String date,
    String note,
    double amount,
  ) async {
    await ref
        .read(sqlProvider)
        .insertData(
          "INSERT INTO homeexpenses(category, amount, note, date) "
          "VALUES('$category', $amount, '$note', '$date')",
        );

    state = AsyncData(await showAllExpense());
  }

  Future<void> deleteAllData() async {
    await ref.read(sqlProvider).deleteData("DELETE FROM homeexpenses");
    state = AsyncData(await showAllExpense());
  }
  
  Future<void> deleteSelectedData(int id)async{
    await ref.read(sqlProvider).deleteData("DELETE FROM homeexpenses where id = $id");
    state=AsyncData(await showAllExpense());
  }
}
