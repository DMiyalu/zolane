import 'package:equatable/equatable.dart';
import 'enums.dart';

class WalletEntry extends Equatable {
  final EntrySource source;
  final ImmoProperty? property;
  final double amount;
  final String? note;
  final DateTime date;

  const WalletEntry({
    required this.source,
    this.property,
    required this.amount,
    this.note,
    required this.date,
  });

  @override
  List<Object?> get props => [source, property, amount, note, date];
}

class WalletExpense extends Equatable {
  final ExpenseType type;
  final ImmoProperty? property;
  final ImmoChargeReason? immoReason;
  final PersonalReason? personalReason;
  final double amount;
  final String? note;
  final DateTime date;

  const WalletExpense({
    required this.type,
    this.property,
    this.immoReason,
    this.personalReason,
    required this.amount,
    this.note,
    required this.date,
  });

  @override
  List<Object?> get props => [
        type,
        property,
        immoReason,
        personalReason,
        amount,
        note,
        date,
      ];
}

class WalletStateData extends Equatable {
  final List<WalletEntry> entries;
  final List<WalletExpense> expenses;

  const WalletStateData({
    required this.entries,
    required this.expenses,
  });

  double get totalIn {
    return entries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  double get totalOut {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get balance {
    return totalIn - totalOut;
  }

  WalletStateData copyWith({
    List<WalletEntry>? entries,
    List<WalletExpense>? expenses,
  }) {
    return WalletStateData(
      entries: entries ?? this.entries,
      expenses: expenses ?? this.expenses,
    );
  }

  @override
  List<Object?> get props => [entries, expenses];
}

