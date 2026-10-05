import 'package:equatable/equatable.dart';

enum DosageUnit { mg, ml, tablet }

class Dosage extends Equatable {
  const Dosage({required this.amount, required this.unit});

  final double amount;
  final DosageUnit unit;

  @override
  List<Object> get props => [amount, unit];
}
