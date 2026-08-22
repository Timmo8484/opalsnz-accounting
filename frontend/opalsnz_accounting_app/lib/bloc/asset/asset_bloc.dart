import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/asset.dart';
import '../../services/asset_service.dart';

enum AssetStatus { initial, loading, loaded, error }

class AssetState {
  const AssetState({
    this.status = AssetStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final AssetStatus status;
  final List<Asset> items;
  final String? errorMessage;

  AssetState copyWith({
    AssetStatus? status,
    List<Asset>? items,
    String? errorMessage,
  }) => AssetState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage,
  );
}

abstract class AssetEvent {}

class AssetStarted extends AssetEvent {}

class AssetAdded extends AssetEvent {
  AssetAdded(this.asset);
  final Asset asset;
}

class AssetDeleted extends AssetEvent {
  AssetDeleted(this.id);
  final int id;
}

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetBloc(this._service) : super(const AssetState()) {
    on<AssetStarted>(_onStarted);
    on<AssetAdded>(_onAdded);
    on<AssetDeleted>(_onDeleted);
  }

  final AssetService _service;

  Future<void> _onStarted(AssetStarted event, Emitter<AssetState> emit) async {
    emit(state.copyWith(status: AssetStatus.loading));
    try {
      final items = await _service.getAll();
      emit(state.copyWith(status: AssetStatus.loaded, items: items));
    } catch (e) {
      emit(
        state.copyWith(status: AssetStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAdded(AssetAdded event, Emitter<AssetState> emit) async {
    try {
      await _service.create(event.asset);
      add(AssetStarted());
    } catch (e) {
      emit(
        state.copyWith(status: AssetStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleted(AssetDeleted event, Emitter<AssetState> emit) async {
    try {
      await _service.delete(event.id);
      add(AssetStarted());
    } catch (e) {
      emit(
        state.copyWith(status: AssetStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
