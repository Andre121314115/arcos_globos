import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'screens/employee/employee_home_screen.dart';
import 'screens/admin/admin_dashboard.dart'; // ✅ NUEVO IMPORT
import 'models/user_model.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Si Firebase ya está inicializado, continuar
    debugPrint('Firebase initialization: $e');
  }
  
  // Inicializar formato de fecha para español de Perú
  try {
    await initializeDateFormatting('es_PE', null);
    Intl.defaultLocale = 'es_PE';
  } catch (e) {
    debugPrint('Error inicializando locale: $e');
    // Fallback a español genérico
    try {
      await initializeDateFormatting('es', null);
      Intl.defaultLocale = 'es';
    } catch (e2) {
      debugPrint('Error inicializando locale fallback: $e2');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Arcos&Globos',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'PE'),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final user = authProvider.currentUser;
        if (user == null) {
          return const LoginScreen();
        }

        // ✅ NUEVA LÓGICA DE NAVEGACIÓN SEGURA POR ROLES
        switch (user.role) {
          case UserRole.admin:
            return const AdminDashboardScreen(); // ✅ REEMPLAZA MasterDashboard
          case UserRole.decorator:
          case UserRole.logistics:
          case UserRole.manager:
            return const EmployeeHomeScreen();
          case UserRole.client:
          default:
            return const ClientHomeScreen();
        }
      },
    );
  }
}