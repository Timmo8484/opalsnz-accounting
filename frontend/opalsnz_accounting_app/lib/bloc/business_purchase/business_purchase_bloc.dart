import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/business_purchase.dart';
import '../../services/business_purchase_service.dart';

enum BusinessPurchaseStatus { initial, loading, loaded, error }

class BusinessPurchaseState {
  const BusinessPurchaseState({
    this.status = BusinessPurchaseStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final BusinessPurchaseStatus status;
  final List<BusinessPurchase> items;
  final String? errorMessage;

  BusinessPurchaseState copyWith({
    BusinessPurchaseStatus? status,
    List<BusinessPurchase>? items,
    String? errorMessage,
  }) => BusinessPurchaseState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

abstract class BusinessPurchaseEvent {}

class BusinessPurchaseStarted extends BusinessPurchaseEvent {}

class BusinessPurchaseAdded extends BusinessPurchaseEvent {
  BusinessPurchaseAdded(this.purchase);
  final BusinessPurchase purchase;
}

class BusinessPurchaseDeleted extends BusinessPurchaseEvent {
  BusinessPurchaseDeleted(this.id);
  final int id;
}

class BusinessPurchaseBloc
    extends Bloc<BusinessPurchaseEvent, BusinessPurchaseState> {
  BusinessPurchaseBloc(this._service) : super(const BusinessPurchaseState()) {
    on<BusinessPurchaseStarted>(_onStarted);
    on<BusinessPurchaseAdded>(_onAdded);
    on<BusinessPurchaseDeleted>(_onDeleted);
  }

  final BusinessPurchaseService _service;

  Future<void> _onStarted(
    BusinessPurchaseStarted event,
    Emitter<BusinessPurchaseState> emit,
  ) async {
    emit(state.copyWith(status: BusinessPurchaseStatus.loading));
    try {
      final items = await _service.getAll();
      emit(state.copyWith(status: BusinessPurchaseStatus.loaded, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: BusinessPurchaseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAdded(
    BusinessPurchaseAdded event,
    Emitter<BusinessPurchaseState> emit,
  ) async {
    try {
      await _service.create(event.purchase);
      add(BusinessPurchaseStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: BusinessPurchaseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    BusinessPurchaseDeleted event,
    Emitter<BusinessPurchaseState> emit,
  ) async {
    try {
      await _service.delete(event.id);
      add(BusinessPurchaseStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: BusinessPurchaseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
