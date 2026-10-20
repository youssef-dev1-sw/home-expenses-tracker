
import 'package:flutter/material.dart';

class ExpenseCardModel {
  final int? id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;

  const ExpenseCardModel({
    this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
  });

  factory ExpenseCardModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCardModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'].toString(),
      icon: Icons.category,
      iconColor: Colors.green,
    );
  }

  static List<ExpenseCardModel> fromMapList(
    List<Map<String, dynamic>> mapList,
  ) {
    return mapList
        .map((map) => ExpenseCardModel.fromMap(map))
        .toList();
  }
}
