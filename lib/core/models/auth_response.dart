import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Auth response model for login/register
class AuthResponse extends Equatable {
  final String token;
  final UserModel? user;
  final String? message;
  final bool success;

  const AuthResponse({
    required this.token,
    this.user,
    this.message,
    this.success = true,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle different API response formats
    final token = json['token'] ?? json['accessToken'] ?? json['data']?['token'] ?? '';
    
    UserModel? user;
    if (json['user'] != null) {
      user = UserModel.fromJson(json['user']);
    } else if (json['data'] != null && json['data']['user'] != null) {
      user = UserModel.fromJson(json['data']['user']);
    }

    return AuthResponse(
      token: token,
      user: user,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }

  @override
  List<Object?> get props => [token, user, message, success];
}
