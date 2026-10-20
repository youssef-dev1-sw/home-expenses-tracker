
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_sql/helper/customdalog.dart';
import 'package:to_do_sql/providers/firstbage_provider.dart';


class CategoryDetailsPage extends ConsumerWidget {
  final String category;

  const CategoryDetailsPage({
    super.key,
    required this.category,
  });

  static const Color primaryGreen = Color(0xff16A34A);
  static const Color darkGreen = Color(0xff15803D);
  static const Color backgroundColor = Color(0xffF7F8FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expensesNotofierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: expensesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
        error: (error, stack) => Center(
          child: Text('حصل خطأ: $error'),
        ),
        data: (expenses) {
          final categoryExpenses = expenses
              .where((expense) => expense.category == category)
              .toList();

          final totalExpenses = categoryExpenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          return Column(
            children: [
              // كارت إجمالي المصاريف
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryGreen, darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'إجمالي المصاريف',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalExpenses.toStringAsFixed(2)} جنيه',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'عدد المصاريف: ${categoryExpenses.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // عنوان قائمة المصاريف
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'تفاصيل المصاريف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${categoryExpenses.length} مصروف',
                      style: const TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // لو القسم فاضي
              if (categoryExpenses.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 65,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'مفيش مصاريف في القسم ده لسه',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: categoryExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = categoryExpenses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xffDDF5E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: darkGreen,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            expense.note.trim().isEmpty
                                ? 'بدون ملاحظة'
                                : expense.note,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(expense.date),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${expense.amount.toStringAsFixed(0)} جنيه',
                                style: const TextStyle(
                                  color: darkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // زر حذف دائري وأكبر
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE5E5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  tooltip: 'حذف المصروف',
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return CustomDialog(
                                          title: 'حذف المصروف',
                                          message:
                                              'هل أنت متأكد إنك عايز تحذف المصروف ده؟',
                                          confirmText: 'حذف',
                                          cancelText: 'إلغاء',
                                          onConfirm: () async {
                                            try {
                                              await ref
                                                  .read(
                                                    expensesNotofierProvider
                                                        .notifier,
                                                  )
                                                  .deleteSelectedData(
                                                    expense.id!,
                                                  );

                                              if (!dialogContext.mounted) {
                                                return;
                                              }

                                              Navigator.pop(dialogContext);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'تم حذف المصروف بنجاح',
                                                  ),
                                                ),
                                              );
                                            } catch (error) {
                                              if (!dialogContext.mounted) {
                                                return;
                                              }

                                              ScaffoldMessenger.of(
                                                dialogContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'فشل حذف المصروف: $error',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          onCancel: () {
                                            Navigator.pop(dialogContext);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
