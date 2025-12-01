import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../employee/admin_templates_screen.dart';
import '../employee/reports_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  // ✅ NUEVA ESTRUCTURA SEGURA - Solo pantallas de admin
  final List<Map<String, dynamic>> _adminSections = [
    {
      'title': 'Gestión de Usuarios',
      'icon': Icons.people_alt,
      'screen': const UserManagementScreen(),
      'color': Colors.blue,
      'description': 'Administrar roles y permisos de usuarios',
    },
    {
      'title': 'Plantillas',
      'icon': Icons.dashboard_customize,
      'screen': const AdminTemplatesScreen(),
      'color': Colors.green,
      'description': 'Gestionar plantillas del sistema',
    },
    {
      'title': 'Reportes',
      'icon': Icons.analytics,
      'screen': const ReportsScreen(),
      'color': Colors.orange,
      'description': 'Estadísticas y reportes del sistema',
    },
    {
      'title': 'Auditoría',
      'icon': Icons.security,
      'screen': const Placeholder(), // Puedes crear esta después
      'color': Colors.purple,
      'description': 'Registros de actividad del sistema',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    // ✅ VERIFICACIÓN DE SEGURIDAD - Solo admins pueden acceder
    if (currentUser?.role != UserRole.admin) {
      return _buildAccessDeniedScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.signOut();
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _currentIndex < _adminSections.length
          ? _adminSections[_currentIndex]['screen'] as Widget
          : const Center(child: Text('Sección no disponible')),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // ✅ NUEVO BOTTOM NAVIGATION MODERNO
  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: _adminSections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            final isSelected = _currentIndex == index;

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          section['icon'] as IconData,
                          color: isSelected 
                              ? section['color'] as Color 
                              : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            color: isSelected 
                                ? section['color'] as Color 
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ✅ PANTALLA DE ACCESO DENEGADO
  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Solo los administradores pueden acceder a esta sección.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al Inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}