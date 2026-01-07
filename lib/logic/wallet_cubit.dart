import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models.dart';
import '../data/enums.dart';

class WalletCubit extends Cubit<WalletStateData> {
  WalletCubit() : super(const WalletStateData(entries: [], expenses: []));

  void addEntry(WalletEntry entry) {
    final updatedEntries = [...state.entries, entry];
    emit(state.copyWith(entries: updatedEntries));
  }

  void addExpense(WalletExpense expense) {
    final updatedExpenses = [...state.expenses, expense];
    emit(state.copyWith(expenses: updatedExpenses));
  }

  List<WalletEntry> entriesByProperty(ImmoProperty property) {
    final list = state.entries
        .where((entry) =>
            entry.source == EntrySource.immo &&
            entry.property == property)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<WalletExpense> expensesByProperty(ImmoProperty property) {
    final list = state.expenses
        .where((expense) =>
            expense.type == ExpenseType.chargesImmo &&
            expense.property == property)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}

