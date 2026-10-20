import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_sql/models/expenseCard_model.dart';
import 'package:to_do_sql/models/expenses_model.dart';
import 'package:to_do_sql/notifires/expensesPage_notifier.dart';
import 'package:to_do_sql/notifires/firstbage_notifier.dart';
import 'package:to_do_sql/notifires/sql_expenses_notifier.dart';

final firstbageProvider = Provider<Firstbage>((ref) {
  return Firstbage();
});

final firstbageNotifierProvider = AsyncNotifierProvider<Firstbage, dynamic>(
  Firstbage.new,
);

final expensesNotofierProvider =
    AsyncNotifierProvider.autoDispose<
      ExpensespageNotifier,
      List<Expensesmodel>
    >(ExpensespageNotifier.new);
final SqlExpensesNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      SqlExpensesNotifier,
      List<ExpenseCardModel>
    >(SqlExpensesNotifier.new);
