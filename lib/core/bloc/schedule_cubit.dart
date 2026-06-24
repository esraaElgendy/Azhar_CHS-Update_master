import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/schedule_model.dart';
import '../repositories/course_repository.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleModel> schedule;

  const ScheduleLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];

  List<ScheduleModel> filterByCourseId(String courseId) {
    return schedule.where((s) => s.courseID == courseId).toList();
  }
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScheduleCubit extends Cubit<ScheduleState> {
  final CourseRepository _repository;

  ScheduleCubit({required CourseRepository repository})
      : _repository = repository,
        super(ScheduleInitial());

  Future<void> loadSchedule({String lang = 'en'}) async {
    emit(ScheduleLoading());
    try {
      final schedule = await _repository.getMySchedule(lang: lang);
      emit(ScheduleLoaded(schedule));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
