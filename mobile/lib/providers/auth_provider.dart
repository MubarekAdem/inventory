import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      await getCurrentUser();
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiService.post('/auth/login', {
        'username': username,
        'password': password,
      }, requireAuth: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        await ApiService.saveAuthToken(loginResponse.accessToken);

        state = state.copyWith(
          user: loginResponse.user,
          isLoading: false,
          isAuthenticated: true,
        );
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          error: error['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await ApiService.get('/auth/profile');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The profile endpoint returns just the user data, so we need to fetch full user details
        // For now, create a user object with the available data
        final user = User(
          id: data['userId'] ?? data['id'] ?? '',
          username: data['username'] ?? '',
          role: _parseUserRole(data['role']),
          isActive: data['isActive'] ?? true, // Default to true if not provided
          createdAt:
              DateTime.now(), // Placeholder since profile doesn't include this
          updatedAt:
              DateTime.now(), // Placeholder since profile doesn't include this
        );

        state = state.copyWith(user: user, isAuthenticated: true);
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    await ApiService.clearAuthToken();
    state = const AuthState();
  }

  UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.user;

    switch (role.toString().toUpperCase()) {
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'USER':
      default:
        return UserRole.user;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
