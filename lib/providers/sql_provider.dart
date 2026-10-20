import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_sql/models/expenses_model.dart';

import 'package:to_do_sql/sql_helper/sql_dp.dart';

final sqlProvider = Provider<SqlDp>((ref) {
  return SqlDp();
});


