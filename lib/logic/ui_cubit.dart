import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/enums.dart';

class UiState extends Equatable {
  final Map<ImmoProperty, bool> expanded;

  const UiState({required this.expanded});

  UiState copyWith({Map<ImmoProperty, bool>? expanded}) {
    return UiState(expanded: expanded ?? this.expanded);
  }

  @override
  List<Object?> get props => [expanded];
}

class UiCubit extends Cubit<UiState> {
  UiCubit()
      : super(UiState(expanded: {
          ImmoProperty.bergere: false,
          ImmoProperty.commentry: false,
          ImmoProperty.chayet: false,
        }));

  void toggle(ImmoProperty property) {
    final currentExpanded = Map<ImmoProperty, bool>.from(state.expanded);
    currentExpanded[property] = !(currentExpanded[property] ?? false);
    emit(state.copyWith(expanded: currentExpanded));
  }
}

