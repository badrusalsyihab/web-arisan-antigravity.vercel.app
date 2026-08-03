import 'package:cloud_firestore/cloud_firestore.dart';

class KasExpenseModel {
  final String id;
  final double amount;
  final String description;
  final DateTime date;

  KasExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory KasExpenseModel.fromMap(Map<String, dynamic> data) {
    return KasExpenseModel(
      id: data['id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      date: data['date'] != null 
          ? (data['date'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }
}
