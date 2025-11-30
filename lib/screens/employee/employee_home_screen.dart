import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'decorator_orders_screen.dart';
import 'admin_templates_screen.dart';
import 'logistics_orders_screen.dart';
import 'manager_calendar_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }

    Widget screen;
    String title;

    switch (user.role) {
      case UserRole.decorator:
        screen = const DecoratorOrdersScreen();
        title = 'Panel Decorador';
        break;
      case UserRole.admin:
        screen = const AdminTemplatesScreen();
        title = 'Panel Administrador';
        break;
      case UserRole.logistics:
        screen = const LogisticsOrdersScreen();
        title = 'Panel Logística';
        break;
      case UserRole.manager:
        screen = const ManagerCalendarScreen();
        title = 'Panel Gestor';
        break;
      default:
        screen = const Center(child: Text('Rol no reconocido'));
        title = 'Panel';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: screen,
    );
  }
}

