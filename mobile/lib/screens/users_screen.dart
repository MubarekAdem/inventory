import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';
import '../widgets/create_user_dialog.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({Key? key}) : super(key: key);

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateUserDialog(),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.user:
        return Colors.green;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagementState = ref.watch(userManagementProvider);
    final currentUser = ref.watch(authProvider).user;

    // Listen for errors
    ref.listen<UserManagementState>(userManagementProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(userManagementProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(userManagementProvider.notifier).refresh();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(context),
        child: const Icon(Icons.person_add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(userManagementProvider.notifier).refresh();
        },
        child:
            userManagementState.isLoading && userManagementState.users.isEmpty
                ? const Center(
                  child: SpinKitThreeBounce(color: Colors.blue, size: 40),
                )
                : userManagementState.users.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userManagementState.users.length,
                  itemBuilder: (context, index) {
                    final user = userManagementState.users[index];
                    final isCurrentUser = user.id == currentUser?.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(user.role),
                          child: Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCurrentUser)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(
                                      user.role,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getRoleDisplayName(user.role),
                                    style: TextStyle(
                                      color: _getRoleColor(user.role),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        user.isActive
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color:
                                          user.isActive
                                              ? Colors.green
                                              : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Created: ${_formatDate(user.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing:
                            !isCurrentUser && user.role != UserRole.superAdmin
                                ? PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'toggle_status') {
                                      await ref
                                          .read(userManagementProvider.notifier)
                                          .updateUserStatus(
                                            user.id,
                                            !user.isActive,
                                          );
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'toggle_status',
                                          child: ListTile(
                                            leading: Icon(
                                              user.isActive
                                                  ? Icons.block
                                                  : Icons.check_circle,
                                              color:
                                                  user.isActive
                                                      ? Colors.red
                                                      : Colors.green,
                                            ),
                                            title: Text(
                                              user.isActive
                                                  ? 'Deactivate'
                                                  : 'Activate',
                                              style: TextStyle(
                                                color:
                                                    user.isActive
                                                        ? Colors.red
                                                        : Colors.green,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                )
                                : null,
                      ),
                    );
                  },
                ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
