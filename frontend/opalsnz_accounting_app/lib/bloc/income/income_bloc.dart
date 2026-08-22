import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/income_entry.dart';
import '../../services/income_service.dart';

enum IncomeStatus { initial, loading, loaded, error }

class IncomeState {
  const IncomeState({
    this.status = IncomeStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final IncomeStatus status;
  final List<IncomeEntry> items;
  final String? errorMessage;

  IncomeState copyWith({
    IncomeStatus? status,
    List<IncomeEntry>? items,
    String? errorMessage,
  }) => IncomeState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

abstract class IncomeEvent {}

class IncomeStarted extends IncomeEvent {}

class IncomeEntryAdded extends IncomeEvent {
  IncomeEntryAdded(this.entry);
  final IncomeEntry entry;
}

class IncomeEntryDeleted extends IncomeEvent {
  IncomeEntryDeleted(this.id);
  final int id;
}

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  IncomeBloc(this._service) : super(const IncomeState()) {
    on<IncomeStarted>(_onStarted);
    on<IncomeEntryAdded>(_onAdded);
    on<IncomeEntryDeleted>(_onDeleted);
  }

  final IncomeService _service;

  Future<void> _onStarted(
    IncomeStarted event,
    Emitter<IncomeState> emit,
  ) async {
    emit(state.copyWith(status: IncomeStatus.loading));
    try {
      final items = await _service.getAll();
      emit(state.copyWith(status: IncomeStatus.loaded, items: items));
    } catch (e) {
      emit(
        state.copyWith(status: IncomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdded(
    IncomeEntryAdded event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      await _service.create(event.entry);
      add(IncomeStarted());
    } catch (e) {
      emit(
        state.copyWith(status: IncomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleted(
    IncomeEntryDeleted event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      await _service.delete(event.id);
      add(IncomeStarted());
    } catch (e) {
      emit(
        state.copyWith(status: IncomeStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
