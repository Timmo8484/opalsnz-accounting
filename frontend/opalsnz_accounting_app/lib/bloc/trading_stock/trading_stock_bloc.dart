import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/trading_stock_year.dart';
import '../../services/trading_stock_service.dart';

enum TradingStockStatus { initial, loading, loaded, error }

class TradingStockState {
  const TradingStockState({
    this.status = TradingStockStatus.initial,
    this.years = const [],
    this.historicalPurchases = const [],
    this.errorMessage,
  });

  final TradingStockStatus status;
  final List<TradingStockYear> years;
  final List<HistoricalStockPurchase> historicalPurchases;
  final String? errorMessage;

  TradingStockState copyWith({
    TradingStockStatus? status,
    List<TradingStockYear>? years,
    List<HistoricalStockPurchase>? historicalPurchases,
    String? errorMessage,
  }) => TradingStockState(
    status: status ?? this.status,
    years: years ?? this.years,
    historicalPurchases: historicalPurchases ?? this.historicalPurchases,
    errorMessage: errorMessage,
  );
}

abstract class TradingStockEvent {}

class TradingStockStarted extends TradingStockEvent {}

class TradingStockYearAdded extends TradingStockEvent {
  TradingStockYearAdded({
    required this.taxYearStart,
    required this.taxYearEnd,
    this.openingValue,
    required this.openingValueMethod,
    this.closingValue,
    this.closingValueMethod,
  });

  final DateTime taxYearStart;
  final DateTime taxYearEnd;
  final double? openingValue;
  final OpeningValueMethod openingValueMethod;
  final double? closingValue;
  final ClosingValueMethod? closingValueMethod;
}

class HistoricalStockPurchaseAdded extends TradingStockEvent {
  HistoricalStockPurchaseAdded(this.purchase);
  final HistoricalStockPurchase purchase;
}

class TradingStockBloc extends Bloc<TradingStockEvent, TradingStockState> {
  TradingStockBloc(this._tradingStockService, this._historyService)
    : super(const TradingStockState()) {
    on<TradingStockStarted>(_onStarted);
    on<TradingStockYearAdded>(_onYearAdded);
    on<HistoricalStockPurchaseAdded>(_onHistoricalAdded);
  }

  final TradingStockService _tradingStockService;
  final HistoricalStockPurchaseService _historyService;

  Future<void> _onStarted(
    TradingStockStarted event,
    Emitter<TradingStockState> emit,
  ) async {
    emit(state.copyWith(status: TradingStockStatus.loading));
    try {
      final years = await _tradingStockService.getAll();
      final history = await _historyService.getAll();
      emit(
        state.copyWith(
          status: TradingStockStatus.loaded,
          years: years,
          historicalPurchases: history,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TradingStockStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onYearAdded(
    TradingStockYearAdded event,
    Emitter<TradingStockState> emit,
  ) async {
    try {
      await _tradingStockService.create(
        taxYearStart: event.taxYearStart,
        taxYearEnd: event.taxYearEnd,
        openingValue: event.openingValue,
        openingValueMethod: event.openingValueMethod,
        closingValue: event.closingValue,
        closingValueMethod: event.closingValueMethod,
      );
      add(TradingStockStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: TradingStockStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onHistoricalAdded(
    HistoricalStockPurchaseAdded event,
    Emitter<TradingStockState> emit,
  ) async {
    try {
      await _historyService.create(event.purchase);
      add(TradingStockStarted());
    } catch (e) {
      emit(
        state.copyWith(
          status: TradingStockStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
