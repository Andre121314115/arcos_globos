import 'package:flutter/material.dart';
import 'templates_screen.dart';
import 'my_orders_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TemplatesScreen(),
    const MyOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcos&Globos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.celebration),
            label: 'Plantillas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Órdenes',
          ),
        ],
      ),
    );
  }
}

