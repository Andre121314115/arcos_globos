import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'decorator_orders_screen.dart';
import 'admin_templates_screen.dart';
import 'logistics_orders_screen.dart';
import 'manager_calendar_screen.dart';
import 'reports_screen.dart';
import 'inventory_screen.dart'; // Agregar esta línea

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _selectedIndex = 0;
  late UserModel _user;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;
  late String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    _user = authProvider.currentUser!;
    _initializeNavigation();
  }

  void _initializeNavigation() {
    switch (_user.role) {
      case UserRole.decorator:
        _screens = [
          const DecoratorOrdersScreen(),
          Container(
            color: Colors.grey[100],
            child: const Center(
              child: Text(
                'Herramientas Decorador',
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
            ),
          ),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Órdenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Herramientas',
          ),
        ];
        _title = 'Panel Decorador';
        break;

 case UserRole.logistics:
  _screens = [
    const LogisticsOrdersScreen(),
    const InventoryScreen(), // ¡NUEVA PANTALLA!
  ];
  _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.local_shipping),
      label: 'Envíos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.inventory),
      label: 'Inventario',
    ),
  ];
  _title = 'Panel Logística';
  break;

      case UserRole.manager:
        _screens = [
          const ManagerCalendarScreen(),
          const ReportsScreen(),
          Container(
            color: Colors.grey[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 50, color: Colors.blueGrey),
                  SizedBox(height: 16),
                  Text(
                    'Gestión de Equipos',
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Equipos',
          ),
        ];
        _title = 'Panel Gestor';
        break;

      case UserRole.admin:
        _screens = [
          const AdminTemplatesScreen(),
          Container(
            color: Colors.grey[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 50, color: Colors.blueGrey),
                  SizedBox(height: 16),
                  Text(
                    'Configuración Admin',
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Plantillas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
        ];
        _title = 'Panel Administrador';
        break;

      default:
        _screens = [
          Container(
            color: Colors.grey[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 60, color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'Rol no reconocido',
                    style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Contacte al administrador',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ];
        _navItems = const [];
        _title = 'Panel';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.currentUser == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.indigo],
            ),
          ),
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.blue[800],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No autenticado',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Debe iniciar sesión para acceder',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Cerrar todas las pantallas y regresar al login
                        Navigator.of(context).popUntil(
                            (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        'Ir al Login',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 4,
        shadowColor: Colors.blue[800]!.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _getRoleIcon(_user.role),
                color: Colors.blue[800],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final confirmed = await _showLogoutConfirmation(context);
              if (confirmed) {
                await authProvider.signOut();
                if (!mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _navItems.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: BottomNavigationBar(
                  items: _navItems,
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.blue[800],
                  unselectedItemColor: Colors.grey[600],
                  backgroundColor: Colors.white,
                  elevation: 8,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                ),
              ),
            )
          : null,
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  Widget? _getFloatingActionButton() {
    switch (_user.role) {
      case UserRole.decorator:
        return FloatingActionButton(
          onPressed: () {
            // Acción específica para decoradores
          },
          backgroundColor: Colors.blue[800],
          child: const Icon(Icons.add, color: Colors.white),
        );
      case UserRole.logistics:
        return FloatingActionButton(
          onPressed: () {
            // Acción específica para logística
          },
          backgroundColor: Colors.blue[800],
          child: const Icon(Icons.add_shopping_cart, color: Colors.white),
        );
      case UserRole.manager:
        return FloatingActionButton(
          onPressed: () {
            // Acción específica para gestores
          },
          backgroundColor: Colors.blue[800],
          child: const Icon(Icons.event_available, color: Colors.white),
        );
      default:
        return null;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.decorator:
        return Icons.brush;
      case UserRole.logistics:
        return Icons.local_shipping;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Está seguro de que desea cerrar sesión?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}