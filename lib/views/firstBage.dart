
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_sql/providers/firstbage_provider.dart';
import 'package:to_do_sql/views/ExpensesPage.dart';

class FirstPage extends ConsumerStatefulWidget {
  const FirstPage({super.key});

  @override
  ConsumerState<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends ConsumerState<FirstPage> {
  final TextEditingController allBudgetConto =
      TextEditingController();

  @override
  void dispose() {
    allBudgetConto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(firstbageNotifierProvider);
    final expensesState = ref.watch(expensesNotofierProvider);

    return budgetState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text("Error: $error")),
      ),
      data: (savedBudget) {
        final double monthlyBudget =
            (savedBudget as num?)?.toDouble() ?? 0.0;

        return expensesState.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text("Error: $error")),
          ),
          data: (expenses) {
            final double totalExpenses = expenses.fold<double>(
              0,
              (sum, expense) => sum + expense.amount,
            );

            final double remainingBudget =
                monthlyBudget - totalExpenses;

            return Scaffold(
              backgroundColor: const Color(0xffF7F8FA),
              appBar: AppBar(
                backgroundColor: const Color(0xffF7F8FA),
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  "مصاريف البيت",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ميزانية الشهر",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "تابع مصاريف بيتك بسهولة",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // كارت المتبقي
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xffDDF5E8),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "المتبقي",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${remainingBudget.toStringAsFixed(0)} جنيه",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff16804F),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // الميزانية الشهرية
                      const Text(
                        "الميزانية الشهرية",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: allBudgetConto,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: "مثال: 10000",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // زر حفظ الميزانية
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            final monthlyBudgetInput =
                                double.tryParse(
                              allBudgetConto.text.trim(),
                            );

                            if (monthlyBudgetInput == null ||
                                monthlyBudgetInput <= 0) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "اكتب ميزانية صحيحة أكبر من صفر",
                                  ),
                                ),
                              );
                              return;
                            }

                            await ref
                                .read(
                                  firstbageNotifierProvider.notifier,
                                )
                                .savedMonthlyBudget(
                                  monthlyBudgetInput,
                                );

                            if (!context.mounted) return;

                            allBudgetConto.clear();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text("تم حفظ الميزانية"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff35A66F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "حفظ الميزانية",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // الكروت الثلاثة
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.blue,
                              title: "الميزانية",
                              value: monthlyBudget.toStringAsFixed(0),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.shopping_cart,
                              iconColor: Colors.red,
                              title: "المصروف",
                              value: totalExpenses.toStringAsFixed(0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ExpensesPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.account_balance_wallet,
                              iconColor: Colors.green,
                              title: "المتبقي",
                              value: remainingBudget.toStringAsFixed(0),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // زر بدء شهر جديد
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(expensesNotofierProvider.notifier).deleteAllData();
                          },
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xffD9534F),
                            size: 22,
                          ),
                          label: const Text(
                            "بدء شهر جديد",
                            style: TextStyle(
                              color: Color(0xffD9534F),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xffFFF5F4),
                            side: const BorderSide(
                              color: Color(0xffF2D5D3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
