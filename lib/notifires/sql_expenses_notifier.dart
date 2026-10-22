
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:home_expenses_tracker/models/categories_model.dart';

import 'package:to_do_sql/models/expenseCard_model.dart';
import 'package:to_do_sql/providers/firstbage_provider.dart';
import 'package:to_do_sql/providers/sql_provider.dart';

class SqlExpensesNotifier extends AsyncNotifier<List<ExpenseCardModel>> {
  @override
  FutureOr<List<ExpenseCardModel>> build() async {
    return await showAllCategories();
  }

  // عرض كل الأقسام من قاعدة البيانات
  Future<List<ExpenseCardModel>> showAllCategories() async {
    final data = await ref
        .read(sqlProvider)
        .selectData('SELECT * FROM categories');

    return ExpenseCardModel.fromMapList(data);
  }

  // إضافة قسم جديد
  Future<void> addCategory(String title) async {
    final categoryName = title.trim();

    if (categoryName.isEmpty) return;

    await ref.read(sqlProvider).insertData(
      "INSERT INTO categories (title) VALUES ('$categoryName')",
    );

    state = AsyncData(await showAllCategories());
  }

  // حذف كل الأقسام
  Future<void> deleteAllCategories() async {
    await ref.read(sqlProvider).deleteData(
      'DELETE FROM categories',
    );

    state = AsyncData(await showAllCategories());
  }

  Future<void> deleteSelectedCategory(int id,String title)async{
    await ref.read(sqlProvider).deleteData("DELETE FROM homeexpenses   where category = '$title'");

    await ref.read(sqlProvider).deleteData("DELETE FROM categories  where id = $id");
    state=AsyncData(await showAllCategories());

     ref.invalidate(expensesNotofierProvider);
  }
}


