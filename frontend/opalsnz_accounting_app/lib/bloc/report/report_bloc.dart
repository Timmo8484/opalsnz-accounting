import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/reports.dart';
import '../../services/report_service.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState {
  const ReportState({
    this.status = ReportStatus.initial,
    this.incomeSummary,
    this.homeOfficeSummary,
    this.gstPeriodSummary,
    this.depreciationSchedule,
    this.errorMessage,
  });

  final ReportStatus status;
  final IncomeSummary? incomeSummary;
  final HomeOfficeSummary? homeOfficeSummary;
  final GstPeriodSummary? gstPeriodSummary;
  final DepreciationSchedule? depreciationSchedule;
  final String? errorMessage;

  ReportState copyWith({
    ReportStatus? status,
    IncomeSummary? incomeSummary,
    HomeOfficeSummary? homeOfficeSummary,
    GstPeriodSummary? gstPeriodSummary,
    DepreciationSchedule? depreciationSchedule,
    String? errorMessage,
  }) =>
      ReportState(
        status: status ?? this.status,
        incomeSummary: incomeSummary ?? this.incomeSummary,
        homeOfficeSummary: homeOfficeSummary ?? this.homeOfficeSummary,
        gstPeriodSummary: gstPeriodSummary ?? this.gstPeriodSummary,
        depreciationSchedule: depreciationSchedule ?? this.depreciationSchedule,
        errorMessage: errorMessage,
      );
}

abstract class ReportEvent {}

// A single tax-year report load, since income/home-office/GST/depreciation are all reported
// against the same 1 Apr - 31 Mar period in this app.
class ReportRequested extends ReportEvent {
  ReportRequested(this.fromDate, this.toDate);
  final DateTime fromDate;
  final DateTime toDate;
}

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc(this._service) : super(const ReportState()) {
    on<ReportRequested>(_onRequested);
  }

  final ReportService _service;

  Future<void> _onRequested(ReportRequested event, Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final income = await _service.getIncomeSummary(event.fromDate, event.toDate);
      final homeOffice = await _service.getHomeOfficeSummary(event.fromDate, event.toDate);
      final gst = await _service.getGstPeriodSummary(event.fromDate, event.toDate);
      final depreciation = await _service.getDepreciationSchedule(event.fromDate, event.toDate);
      emit(state.copyWith(
        status: ReportStatus.loaded,
        incomeSummary: income,
        homeOfficeSummary: homeOffice,
        gstPeriodSummary: gst,
        depreciationSchedule: depreciation,
      ));
    } catch (e) {
      emit(state.copyWith(status: ReportStatus.error, errorMessage: e.toString()));
    }
  }
}
