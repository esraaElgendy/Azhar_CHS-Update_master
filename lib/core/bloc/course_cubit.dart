import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

/// Represents the state of the course data
abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class CourseInitial extends CourseState {}

/// Loading state while fetching courses
class CourseLoading extends CourseState {}

/// Success state with loaded courses
class CourseLoaded extends CourseState {
  final List<LevelModel> levels;

  const CourseLoaded(this.levels);

  @override
  List<Object?> get props => [levels];
}

/// Error state with error message
class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Cubit for managing course data
class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _courseRepository;

  CourseCubit({CourseRepository? courseRepository})
    : _courseRepository = courseRepository ?? CourseRepository(),
      super(CourseInitial());

  /// Fetch all courses for the specified language
  ///
  /// Always fetches fresh data from the API
  ///
  /// Parameters:
  ///   - lang: Language code ('en' or 'ar')
  Future<void> fetchCourses({required String lang}) async {
    emit(CourseLoading());
    try {
      final levels = await _courseRepository.getAllCourses(lang: lang);
      emit(CourseLoaded(levels));
    } catch (e) {
      // Extract meaningful error message
      final errorMessage = _parseErrorMessage(e);
      emit(CourseError(errorMessage));
    }
  }

  /// Parse error to provide user-friendly message
  String _parseErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();

      // Remove 'Exception: ' prefix if present
      if (message.startsWith('Exception: ')) {
        return message.replaceFirst('Exception: ', '');
      }

      return message;
    }

    return error.toString();
  }
}
