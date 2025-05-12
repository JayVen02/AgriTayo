import 'package:cloud_firestore/cloud_firestore.dart';

class DemandDataPoint {
  final String product; 
  final double demandValue;
  final DateTime date; 
  final String? periodLabel;

  DemandDataPoint({
    required this.product,
    required this.demandValue,
    required this.date,
    this.periodLabel,
  });

  factory DemandDataPoint.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DemandDataPoint(
      product: data['product'] ?? 'Unknown',
      demandValue: (data['demandValue'] as num?)?.toDouble() ?? 0.0, 
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodLabel: data['periodLabel'],
    );
  }
}