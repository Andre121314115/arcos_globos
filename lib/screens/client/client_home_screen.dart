import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'templates_screen.dart';
import 'my_orders_screen.dart';
import '../../providers/auth_provider.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  // ✅ SOLO PANTALLAS QUE NO REQUIEREN PARÁMETROS
  final List<Widget> _screens = [
    const TemplatesScreen(),  // Desde aquí se navega a QuoteScreen
    const MyOrdersScreen(),   // Desde aquí se navega a OrderDetailScreen
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Arcos&Globos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ✅ INFO DE USUARIO MEJORADA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  currentUser?.name.split(' ').first ?? 'Cliente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.signOut();
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // ✅ BOTTOM NAVIGATION MEJORADA - SOLO 2 OPCIONES
  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.celebration_outlined,
                activeIcon: Icons.celebration,
                label: 'Catálogo',
                isSelected: _currentIndex == 0,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                label: 'Mis Pedidos',
                isSelected: _currentIndex == 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ITEM DE NAVEGACIÓN PERSONALIZADO
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.blue[100]!, width: 1)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue[700] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}