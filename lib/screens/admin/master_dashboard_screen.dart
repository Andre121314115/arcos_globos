import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../client/templates_screen.dart';
import '../client/my_orders_screen.dart';
import '../employee/decorator_orders_screen.dart';
import '../employee/admin_templates_screen.dart';
import '../employee/logistics_orders_screen.dart';
import '../employee/manager_calendar_screen.dart';
import '../employee/reports_screen.dart';

class MasterDashboardScreen extends StatefulWidget {
  const MasterDashboardScreen({super.key});

  @override
  State<MasterDashboardScreen> createState() => _MasterDashboardScreenState();
}

class _MasterDashboardScreenState extends State<MasterDashboardScreen> {
  int _selectedIndex = 0;

  Widget? _getScreenForIndex(int sectionIndex, int screenIndex) {
    switch (sectionIndex) {
      case 0: // Cliente
        if (screenIndex == 0) return const TemplatesScreen();
        if (screenIndex == 1) return const MyOrdersScreen();
        break;
      case 1: // Decorador
        if (screenIndex == 0) return const DecoratorOrdersScreen();
        break;
      case 2: // Administrador
        if (screenIndex == 0) return const AdminTemplatesScreen();
        break;
      case 3: // Logística
        if (screenIndex == 0) return const LogisticsOrdersScreen();
        break;
      case 4: // Gestor
        if (screenIndex == 0) return const ManagerCalendarScreen();
        if (screenIndex == 1) return const ReportsScreen();
        break;
    }
    return null;
  }

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Cliente',
      'icon': Icons.shopping_cart,
      'screens': [
        {'name': 'Plantillas'},
        {'name': 'Mis Órdenes'},
      ],
    },
    {
      'title': 'Decorador',
      'icon': Icons.brush,
      'screens': [
        {'name': 'Órdenes Asignadas'},
      ],
    },
    {
      'title': 'Administrador',
      'icon': Icons.admin_panel_settings,
      'screens': [
        {'name': 'Gestión de Plantillas'},
      ],
    },
    {
      'title': 'Logística',
      'icon': Icons.local_shipping,
      'screens': [
        {'name': 'Asignación de Equipos'},
      ],
    },
    {
      'title': 'Gestor',
      'icon': Icons.calendar_today,
      'screens': [
        {'name': 'Calendario de Montajes'},
        {'name': 'Reportes y Rutas'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control - Acceso Completo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Menú lateral
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _sections.map((section) {
              return NavigationRailDestination(
                icon: Icon(section['icon'] as IconData),
                label: Text(section['title'] as String),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedIndex >= _sections.length) {
      return const Center(child: Text('Sección no encontrada'));
    }

    final section = _sections[_selectedIndex];
    final screens = section['screens'] as List<Map<String, dynamic>>;

    if (screens.length == 1) {
      // Si solo hay una pantalla, mostrarla directamente
      final screen = _getScreenForIndex(_selectedIndex, 0);
      return screen ?? const Center(child: Text('Pantalla no disponible'));
    } else {
      // Si hay múltiples pantallas, mostrar un selector
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Icon(section['icon'] as IconData),
                const SizedBox(width: 8),
                Text(
                  section['title'] as String,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: screens.length,
              itemBuilder: (context, index) {
                final screen = screens[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(screen['name'] as String),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      final widget = _getScreenForIndex(_selectedIndex, index);
                      if (widget != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => widget),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }
}

