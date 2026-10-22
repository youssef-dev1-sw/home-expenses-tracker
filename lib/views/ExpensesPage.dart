
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_sql/helper/customdalog.dart';
import 'package:to_do_sql/models/expenseCard_model.dart';
import 'package:to_do_sql/models/expenses_model.dart';
import 'package:to_do_sql/providers/firstbage_provider.dart';
import 'package:to_do_sql/views/CategoryDetailsPage.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedCategory;

  // الأقسام الثابتة
  final List<ExpenseCardModel> staticCategories = [
    ExpenseCardModel(
      title: "أكل",
      icon: Icons.restaurant,
      iconColor: Colors.orange,
      amount: "0.00 جنيه",
    ),
    ExpenseCardModel(
      title: "دروس",
      icon: Icons.menu_book,
      iconColor: Colors.blue,
      amount: "0.00 جنيه",
    ),
    ExpenseCardModel(
      title: "فواتير",
      icon: Icons.receipt_long,
      iconColor: Colors.red,
      amount: "0.00 جنيه",
    ),
    ExpenseCardModel(
      title: "مواصلات",
      icon: Icons.directions_bus,
      iconColor: Colors.green,
      amount: "0.00 جنيه",
    ),
    ExpenseCardModel(
      title: "مدرسة",
      icon: Icons.school,
      iconColor: Colors.purple,
      amount: "0.00 جنيه",
    ),
  ];

  static const Color primaryGreen = Color(0xff16A34A);
  static const Color darkGreen = Color(0xff15803D);
  static const Color backgroundColor = Color(0xffF7F8FA);

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesNotofierProvider);
    final categoriesState = ref.watch(SqlExpensesNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "المصاريف",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: expensesState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: primaryGreen),
          ),
          error: (error, stackTrace) => Center(
            child: Text("حصل خطأ: $error"),
          ),
          data: (expenses) {
            final double totalExpenses = expenses.fold<double>(
              0,
              (sum, expense) => sum + expense.amount,
            );

            return categoriesState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              ),
              error: (error, stackTrace) => Center(
                child: Text("حصل خطأ في الأقسام: $error"),
              ),
              data: (savedCategories) {
                // دمج الأقسام الثابتة مع الأقسام المحفوظة
                final List<ExpenseCardModel> allCategories = [
                  ...staticCategories,
                  ...savedCategories,
                ];

                final List<String> categoryNames = allCategories
                    .map((category) => category.title)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    // كارت إجمالي المصاريف
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
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
                            size: 34,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "إجمالي المصاريف",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${totalExpenses.toStringAsFixed(2)} جنيه",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "المصاريف حسب التصنيف",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // الجريد: الأقسام الثابتة + أقسام SQLite
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth =
                            (constraints.maxWidth - 12) / 2;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: cardWidth / 135,
                          children: [
                            ...allCategories.map((category) {
                              final bool isSavedCategory =
                                  category.id != null;

                              return ExpenseCategory(
                                title: category.title,
                                amount: _categoryTotal(
                                  expenses,
                                  category.title,
                                ),
                                icon: category.icon,
                                iconColor: category.iconColor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryDetailsPage(
                                        category: category.title,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: isSavedCategory
                                    ? () {
                                        _confirmDeleteCategory(category);
                                      }
                                    : null,
                              );
                            }),

                            // كارت إضافة قسم جديد
                            InkWell(
                              onTap: _showAddCategorySheet,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: primaryGreen.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle,
                                      color: primaryGreen,
                                      size: 48,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "إضافة قسم",
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // زر إضافة مصروف
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAddExpenseSheet(categoryNames);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text(
                          "إضافة مصروف",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // حساب إجمالي مصاريف كل قسم
  String _categoryTotal(
    List<Expensesmodel> expenses,
    String category,
  ) {
    final total = expenses
        .where((expense) => expense.category == category)
        .fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

    return "${total.toStringAsFixed(2)} جنيه";
  }

  // تأكيد حذف القسم
  void _confirmDeleteCategory(ExpenseCardModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CustomDialog(
          title: "حذف القسم",
          message: "هل أنت متأكد إنك عايز تحذف قسم ${category.title}؟",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () async {
            try {
              await ref
                  .read(SqlExpensesNotifierProvider.notifier)
                  .deleteSelectedCategory(category.id!,category.title);

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم حذف القسم بنجاح"),
                ),
              );
            } catch (error) {
              if (!dialogContext.mounted) return;

              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text("فشل حذف القسم: $error"),
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
  }

  // شيت إضافة قسم جديد
  void _showAddCategorySheet() {
    categoryController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "إضافة قسم جديد",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "اسم القسم",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: categoryController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "مثال: علاج، ملابس، صيانة",
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = categoryController.text.trim();

                      if (title.isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text("اكتب اسم القسم الأول"),
                          ),
                        );
                        return;
                      }

                      // منع تكرار أسماء الأقسام
                      final existingNames = [
                        ...staticCategories.map((e) => e.title),
                        ...?ref
                            .read(SqlExpensesNotifierProvider)
                            .value
                            ?.map((e) => e.title),
                      ];

                      if (existingNames.any(
                        (name) =>
                            name.toLowerCase() == title.toLowerCase(),
                      )) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text("القسم ده موجود بالفعل"),
                          ),
                        );
                        return;
                      }

                      try {
                        await ref
                            .read(SqlExpensesNotifierProvider.notifier)
                            .addCategory(title);

                        if (!sheetContext.mounted) return;

                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تمت إضافة القسم بنجاح"),
                          ),
                        );
                      } catch (error) {
                        if (!sheetContext.mounted) return;

                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text("فشل إضافة القسم: $error"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "إضافة القسم",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // شيت إضافة مصروف
  void _showAddExpenseSheet(List<String> categoryNames) {
    amountController.clear();
    noteController.clear();
    selectedCategory = null;
    selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "إضافة مصروف جديد",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "المبلغ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: "اكتب المبلغ",
                        suffixText: "جنيه",
                        prefixIcon: const Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "التصنيف",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        hintText: "اختار التصنيف",
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: categoryNames.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "ملاحظة",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                       onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "اكتب ملاحظة (اختياري)",
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "التاريخ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setSheetState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: primaryGreen,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(
                            amountController.text.trim(),
                          );

                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "اكتب مبلغ صحيح أكبر من صفر",
                                ),
                              ),
                            );
                            return;
                          }

                          if (selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("اختار تصنيف المصروف"),
                              ),
                            );
                            return;
                          }

                          final date =
                              "${selectedDate.year}-"
                              "${selectedDate.month.toString().padLeft(2, '0')}-"
                              "${selectedDate.day.toString().padLeft(2, '0')}";

                          try {
                            await ref
                                .read(expensesNotofierProvider.notifier)
                                .addExpense(
                                  selectedCategory!,
                                  date,
                                  noteController.text.trim(),
                                  amount,
                                );

                            if (!sheetContext.mounted) return;

                            Navigator.pop(sheetContext);
                          } catch (error) {
                            if (!sheetContext.mounted) return;

                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                content: Text("فشل حفظ المصروف: $error"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "حفظ المصروف",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// كارت التصنيف مع زر حذف دائري
class ExpenseCategory extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ExpenseCategory({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 23,
                  ),
                ),

                const Spacer(),

                if (onDelete != null)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      tooltip: "حذف القسم",
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Flexible(
              child: Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
