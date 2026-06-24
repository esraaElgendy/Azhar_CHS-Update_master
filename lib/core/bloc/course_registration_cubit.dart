import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/course_repository.dart';
import '../utils/app_preferences.dart';

// States
abstract class CourseRegistrationState extends Equatable {
  final Set<String> registeredCourseIds;
  final Map<String, bool> loadingCourseIds;

  const CourseRegistrationState({
    required this.registeredCourseIds,
    required this.loadingCourseIds,
  });

  @override
  List<Object?> get props => [registeredCourseIds, loadingCourseIds];
}

class CourseRegistrationInitial extends CourseRegistrationState {
  const CourseRegistrationInitial()
      : super(registeredCourseIds: const {}, loadingCourseIds: const {});
}

class CourseRegistrationUpdated extends CourseRegistrationState {
  final String? lastError;
  final String? lastCourseId;

  const CourseRegistrationUpdated({
    required super.registeredCourseIds,
    required super.loadingCourseIds,
    this.lastError,
    this.lastCourseId,
  });

  @override
  List<Object?> get props => [super.props, lastError, lastCourseId];
}

// Cubit
class CourseRegistrationCubit extends Cubit<CourseRegistrationState> {
  final CourseRepository _repository;
  final AppPreferences _prefs;

  CourseRegistrationCubit({
    required CourseRepository repository,
    required AppPreferences prefs,
  })  : _repository = repository,
        _prefs = prefs,
        super(const CourseRegistrationInitial()) {
    _loadPersistedState();
  }

  void _loadPersistedState() {
    final ids = _prefs.getRegisteredCourses();
    emit(CourseRegistrationUpdated(
      registeredCourseIds: ids.toSet(),
      loadingCourseIds: const {},
    ));
  }

  Future<void> registerCourse({
    required String courseID,
    required String lang,
  }) async {
    final previousRegistered = Set<String>.from(state.registeredCourseIds);
    final currentLoading = Map<String, bool>.from(state.loadingCourseIds);

    // Optimistic UI update
    final newRegistered = Set<String>.from(previousRegistered)..add(courseID);
    currentLoading[courseID] = true;

    emit(CourseRegistrationUpdated(
      registeredCourseIds: newRegistered,
      loadingCourseIds: currentLoading,
    ));

    try {
      final success = await _repository.registerCourse(courseID: courseID, lang: lang);
      
      currentLoading.remove(courseID);
      if (success) {
        await _prefs.setRegisteredCourses(newRegistered.toList());
        emit(CourseRegistrationUpdated(
          registeredCourseIds: newRegistered,
          loadingCourseIds: currentLoading,
          lastCourseId: courseID,
        ));
      } else {
        // Rollback
        emit(CourseRegistrationUpdated(
          registeredCourseIds: previousRegistered,
          loadingCourseIds: currentLoading,
          lastError: "Failed to register $courseID",
          lastCourseId: courseID,
        ));
      }
    } catch (e) {
      currentLoading.remove(courseID);
      // Rollback on error
      String errorMsg = e.toString();
      if (e is Exception) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }
      emit(CourseRegistrationUpdated(
        registeredCourseIds: previousRegistered,
        loadingCourseIds: currentLoading,
        lastError: errorMsg,
        lastCourseId: courseID,
      ));
    }
  }

  Future<void> dropCourse({
    required String courseID,
    required String lang,
  }) async {
    final previousRegistered = Set<String>.from(state.registeredCourseIds);
    final currentLoading = Map<String, bool>.from(state.loadingCourseIds);

    // Optimistic UI update
    final newRegistered = Set<String>.from(previousRegistered)..remove(courseID);
    currentLoading[courseID] = true;

    emit(CourseRegistrationUpdated(
      registeredCourseIds: newRegistered,
      loadingCourseIds: currentLoading,
    ));

    try {
      final success = await _repository.dropCourse(courseID: courseID, lang: lang);
      
      currentLoading.remove(courseID);
      if (success) {
        await _prefs.setRegisteredCourses(newRegistered.toList());
        emit(CourseRegistrationUpdated(
          registeredCourseIds: newRegistered,
          loadingCourseIds: currentLoading,
          lastCourseId: courseID,
        ));
      } else {
        // Rollback
        emit(CourseRegistrationUpdated(
          registeredCourseIds: previousRegistered,
          loadingCourseIds: currentLoading,
          lastError: "Failed to drop $courseID",
          lastCourseId: courseID,
        ));
      }
    } catch (e) {
      currentLoading.remove(courseID);
      // Rollback on error
      String errorMsg = e.toString();
      if (e is Exception) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }
      emit(CourseRegistrationUpdated(
        registeredCourseIds: previousRegistered,
        loadingCourseIds: currentLoading,
        lastError: errorMsg,
        lastCourseId: courseID,
      ));
    }
  }

  bool isRegistered(String courseID) {
    return state.registeredCourseIds.contains(courseID);
  }

  bool isLoading(String courseID) {
    return state.loadingCourseIds[courseID] ?? false;
  }
}
