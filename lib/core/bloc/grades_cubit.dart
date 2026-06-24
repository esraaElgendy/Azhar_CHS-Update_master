import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/grades_model.dart';
import '../repositories/grades_repository.dart';

abstract class GradesState extends Equatable {
  const GradesState();

  @override
  List<Object?> get props => [];
}

class GradesInitial extends GradesState {}

class GradesLoading extends GradesState {}

class GradesLoaded extends GradesState {
  final GradesSummaryModel summary;

  const GradesLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class GradesError extends GradesState {
  final String message;

  const GradesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GradesCubit extends Cubit<GradesState> {
  final GradesRepository _repository;

  GradesCubit({required GradesRepository repository})
      : _repository = repository,
        super(GradesInitial());

  Future<void> fetchGrades({String lang = 'en'}) async {
    emit(GradesLoading());
    try {
      final summary = await _repository.getMyGrades(lang: lang);
      emit(GradesLoaded(summary));
    } catch (e) {
      emit(GradesError(e.toString()));
    }
  }
}
