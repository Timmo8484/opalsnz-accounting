import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/expense_category.dart';
import '../../services/expense_category_service.dart';

enum ExpenseCategoryStatus { initial, loading, loaded, error }

class ExpenseCategoryState {
  const ExpenseCategoryState({
    this.status = ExpenseCategoryStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final ExpenseCategoryStatus status;
  final List<ExpenseCategory> items;
  final String? errorMessage;

  ExpenseCategoryState copyWith({
    ExpenseCategoryStatus? status,
    List<ExpenseCategory>? items,
    String? errorMessage,
  }) => ExpenseCategoryState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

abstract class ExpenseCategoryEvent {}

class ExpenseCategoryStarted extends ExpenseCategoryEvent {}

class ExpenseCategoryAdded extends ExpenseCategoryEvent {
  ExpenseCategoryAdded(this.category);
  final ExpenseCategory category;
}

class ExpenseCategoryUpdated extends ExpenseCategoryEvent {
  ExpenseCategoryUpdated(this.id, this.category);
  final int id;
  final ExpenseCategory category;
}

class ExpenseCategoryBloc
    extends Bloc<ExpenseCategoryEvent, ExpenseCategoryState> {
  ExpenseCategoryBloc(this._service) : super(const ExpenseCategoryState()) {
    on<ExpenseCategoryStarted>(_onStarted);
    on<ExpenseCategoryAdded>(_onAdded);
    on<ExpenseCategoryUpdated>(_onUpdated);
  }

  final ExpenseCategoryService _service;

  Future<void> _onStarted(
    ExpenseCategoryStarted event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseCategoryStatus.loading));
    try {
      final items = await _service.getAll(includeInactive: true);
      emit(state.copyWith(status: ExpenseCategoryStatus.loaded, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: ExpenseCategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAdded(
    ExpenseCategoryAdded event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    try {
      await _service.create(event.category);
      add(ExpenseCategoryStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: ExpenseCategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdated(
    ExpenseCategoryUpdated event,
    Emitter<ExpenseCategoryState> emit,
  ) async {
    try {
      await _service.update(event.id, event.category);
      add(ExpenseCategoryStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: ExpenseCategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
