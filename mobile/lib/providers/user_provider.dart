import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UserManagementState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  const UserManagementState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserManagementState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier() : super(const UserManagementState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiService.get('/auth/users');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final users = data.map((user) => User.fromJson(user)).toList();

        state = state.copyWith(users: users, isLoading: false);
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          error: error['message'] ?? 'Failed to load users',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<bool> createUser({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await ApiService.post('/auth/users', {
        'username': username,
        'password': password,
        'role': role.name.toUpperCase(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadUsers(); // Refresh the list
        return true;
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          error: error['message'] ?? 'Failed to create user',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      final response = await ApiService.patch('/auth/users/$userId/status', {
        'isActive': isActive,
      });

      if (response.statusCode == 200) {
        await loadUsers(); // Refresh the list
        return true;
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          error: error['message'] ?? 'Failed to update user status',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refresh() {
    loadUsers();
  }
}

final userManagementProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
      return UserManagementNotifier();
    });
