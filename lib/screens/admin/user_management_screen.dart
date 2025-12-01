import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  Future<void> _updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': _roleToString(newRole),
        'updatedAt': Timestamp.now(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rol actualizado a: ${_getRoleDisplayName(newRole)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar rol: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': !currentStatus,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin: return 'admin';
      case UserRole.decorator: return 'decorator';
      case UserRole.logistics: return 'logistics';
      case UserRole.manager: return 'manager';
      case UserRole.client: return 'client';
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin: return 'Administrador';
      case UserRole.decorator: return 'Decorador';
      case UserRole.logistics: return 'Logística';
      case UserRole.manager: return 'Gestor';
      case UserRole.client: return 'Cliente';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin: return Colors.red;
      case UserRole.decorator: return Colors.blue;
      case UserRole.logistics: return Colors.green;
      case UserRole.manager: return Colors.orange;
      case UserRole.client: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Administra roles y permisos de usuarios del sistema',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final users = snapshot.data?.docs ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay usuarios registrados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    
                    final userRole = _stringToRole(userData['role'] ?? 'client');
                    final isActive = userData['isActive'] ?? true;
                    final createdAt = (userData['createdAt'] as Timestamp).toDate();

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(userRole),
                          child: Text(
                            userData['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          userData['name'] ?? 'Sin nombre',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userData['email'] ?? 'Sin email'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(userRole).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getRoleColor(userRole),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getRoleDisplayName(userRole),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getRoleColor(userRole),
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
                                    color: isActive 
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive ? Colors.green : Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'toggle_status') {
                              _toggleUserStatus(userDoc.id, isActive);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'toggle_status',
                              child: Text('Cambiar Estado'),
                            ),
                          ],
                        ),
                        onTap: () {
                          _showRoleDialog(userDoc.id, userRole, userData['name'] ?? 'Usuario');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  UserRole _stringToRole(String role) {
    switch (role) {
      case 'admin': return UserRole.admin;
      case 'decorator': return UserRole.decorator;
      case 'logistics': return UserRole.logistics;
      case 'manager': return UserRole.manager;
      default: return UserRole.client;
    }
  }

  void _showRoleDialog(String userId, UserRole currentRole, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Rol de $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return RadioListTile<UserRole>(
              title: Text(_getRoleDisplayName(role)),
              value: role,
              groupValue: currentRole,
              onChanged: (UserRole? newRole) {
                if (newRole != null) {
                  _updateUserRole(userId, newRole);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}