import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/home_office_expense_entry.dart';
import '../../services/home_office_expense_service.dart';

enum HomeOfficeExpenseStatus { initial, loading, loaded, error }

class HomeOfficeExpenseState {
  const HomeOfficeExpenseState({
    this.status = HomeOfficeExpenseStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final HomeOfficeExpenseStatus status;
  final List<HomeOfficeExpenseEntry> items;
  final String? errorMessage;

  HomeOfficeExpenseState copyWith({
    HomeOfficeExpenseStatus? status,
    List<HomeOfficeExpenseEntry>? items,
    String? errorMessage,
  }) => HomeOfficeExpenseState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

abstract class HomeOfficeExpenseEvent {}

class HomeOfficeExpenseStarted extends HomeOfficeExpenseEvent {}

class HomeOfficeExpenseAdded extends HomeOfficeExpenseEvent {
  HomeOfficeExpenseAdded(this.request);
  final HomeOfficeExpenseUpsertRequest request;
}

class HomeOfficeExpenseDeleted extends HomeOfficeExpenseEvent {
  HomeOfficeExpenseDeleted(this.id);
  final int id;
}

class HomeOfficeExpenseBloc
    extends Bloc<HomeOfficeExpenseEvent, HomeOfficeExpenseState> {
  HomeOfficeExpenseBloc(this._service) : super(const HomeOfficeExpenseState()) {
    on<HomeOfficeExpenseStarted>(_onStarted);
    on<HomeOfficeExpenseAdded>(_onAdded);
    on<HomeOfficeExpenseDeleted>(_onDeleted);
  }

  final HomeOfficeExpenseService _service;

  Future<void> _onStarted(
    HomeOfficeExpenseStarted event,
    Emitter<HomeOfficeExpenseState> emit,
  ) async {
    emit(state.copyWith(status: HomeOfficeExpenseStatus.loading));
    try {
      final items = await _service.getAll();
      emit(
        state.copyWith(status: HomeOfficeExpenseStatus.loaded, items: items),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeOfficeExpenseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAdded(
    HomeOfficeExpenseAdded event,
    Emitter<HomeOfficeExpenseState> emit,
  ) async {
    try {
      await _service.create(event.request);
      add(HomeOfficeExpenseStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeOfficeExpenseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    HomeOfficeExpenseDeleted event,
    Emitter<HomeOfficeExpenseState> emit,
  ) async {
    try {
      await _service.delete(event.id);
      add(HomeOfficeExpenseStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeOfficeExpenseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
