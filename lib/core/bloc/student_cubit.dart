import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../repositories/student_repository.dart';

// Student States
abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {
  final UserModel? previousUser;
  const StudentLoading({this.previousUser});

  @override
  List<Object?> get props => [previousUser];
}

class StudentImageUploading extends StudentState {
  final UserModel? previousUser;
  const StudentImageUploading({this.previousUser});

  @override
  List<Object?> get props => [previousUser];
}

class StudentLoaded extends StudentState {
  final UserModel user;

  const StudentLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class StudentError extends StudentState {
  final String message;
  final UserModel? previousUser;

  const StudentError(this.message, {this.previousUser});

  @override
  List<Object?> get props => [message, previousUser];
}

// Student Cubit
class StudentCubit extends Cubit<StudentState> {
  final StudentRepository _studentRepository;

  StudentCubit({StudentRepository? studentRepository})
    : _studentRepository = studentRepository ?? StudentRepository(),
      super(StudentInitial());

  /// Load student dashboard from API
  Future<void> loadDashboard({String lang = 'en'}) async {
    final currentUser = state is StudentLoaded
        ? (state as StudentLoaded).user
        : null;
    emit(StudentLoading(previousUser: currentUser));
    try {
      final user = await _studentRepository.getDashboard();
      emit(StudentLoaded(user));
    } on ApiException catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(StudentError(e.message, previousUser: currentUser));
      }
    } catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(
          StudentError(
            'Failed to load dashboard: ${e.toString()}',
            previousUser: currentUser,
          ),
        );
      }
    }
  }

  /// Load student profile from API
  Future<void> loadProfile({String lang = 'en'}) async {
    final currentUser = state is StudentLoaded
        ? (state as StudentLoaded).user
        : null;
    emit(StudentLoading(previousUser: currentUser));
    try {
      final user = await _studentRepository.getProfile(lang: lang);
      emit(StudentLoaded(user));
    } on ApiException catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(StudentError(e.message, previousUser: currentUser));
      }
    } catch (e) {
      final cachedUser = await _studentRepository.getCachedProfile();
      if (cachedUser != null) {
        emit(StudentLoaded(cachedUser));
      } else {
        emit(
          StudentError(
            'Failed to load profile: ${e.toString()}',
            previousUser: currentUser,
          ),
        );
      }
    }
  }

  /// Load cached profile (for offline use)
  Future<void> loadCachedProfile() async {
    final cachedUser = await _studentRepository.getCachedProfile();
    if (cachedUser != null) {
      emit(StudentLoaded(cachedUser));
    }
  }

  /// Clear profile data
  void clearProfile() {
    emit(StudentInitial());
  }

  /// Update student profile
  Future<void> updateProfile({
    required String studentID,
    required String name,
    required String fullName,
    required String email,
    required String major,
    required String year,
    required String semester,
    required String phone,
    String lang = 'en',
  }) async {
    final currentUser = state is StudentLoaded
        ? (state as StudentLoaded).user
        : null;
    emit(StudentLoading(previousUser: currentUser));
    try {
      final user = await _studentRepository.updateProfile(
        studentID: studentID,
        name: name,
        fullName: fullName,
        email: email,
        major: major,
        year: year,
        semester: semester,
        phone: phone,
        lang: lang,
      );
      emit(StudentLoaded(user));
      // Refresh again just to be 100% sure the UI is in sync with the server
      await loadProfile(lang: lang);
    } on ApiException catch (e) {
      emit(StudentError(e.message, previousUser: currentUser));
    } catch (e) {
      emit(
        StudentError(
          'Failed to update profile: ${e.toString()}',
          previousUser: currentUser,
        ),
      );
    }
  }

  UserModel? get _currentUser {
    final currentState = state;
    if (currentState is StudentLoaded) return currentState.user;
    if (currentState is StudentLoading) return currentState.previousUser;
    if (currentState is StudentImageUploading) return currentState.previousUser;
    if (currentState is StudentError) return currentState.previousUser;
    return null;
  }

  /// Select a local image to preview immediately in the UI. The preview stays
  /// in Cubit state only; it is not cached as backend data unless upload works.
  Future<void> selectLocalProfileImage(String localPath) async {
    final currentUser = _currentUser;
    if (currentUser != null) {
      final updated = currentUser.copyWith(profilePictureUrl: localPath);
      emit(StudentLoaded(updated));
      try {
        await _studentRepository.saveProfile(updated);
      } catch (_) {
        // Ignore cache save errors to avoid breaking UX; profile preview already updated in state
      }
    }
  }

  /// Upload profile image file to backend. Emits uploading state, then loaded
  /// (on success/fallback) or error.
  Future<void> uploadProfileImage({
    required File file,
    String lang = 'en',
  }) async {
    final currentUser = _currentUser;
    emit(StudentImageUploading(previousUser: currentUser));
    try {
      final updated = await _studentRepository.uploadProfileImage(
        file: file,
        lang: lang,
      );
      emit(StudentLoaded(updated));
      await loadProfile(lang: lang);
      await loadDashboard(lang: lang);
    } on ApiException catch (e) {
      emit(StudentError(e.message, previousUser: currentUser));
    } catch (e) {
      emit(
        StudentError(
          'Failed to upload image: ${e.toString()}',
          previousUser: currentUser,
        ),
      );
    }
  }
}
