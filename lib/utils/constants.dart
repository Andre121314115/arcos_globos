class AppConstants {
  static const String appName = 'Arcos&Globos';
  static const String country = 'Perú';
  static const String locale = 'es_PE';
  static const String currency = 'PEN'; // Soles Peruanos
  
  // Colors
  static const List<String> availableColors = [
    'Rojo',
    'Azul',
    'Amarillo',
    'Verde',
    'Rosa',
    'Morado',
    'Naranja',
    'Blanco',
    'Negro',
    'Dorado',
    'Plateado',
  ];

  // Template Types
  static const List<String> templateTypes = [
    'arco',
    'columna',
    'centro',
  ];

  // Deposit percentage
  static const double depositPercentage = 0.3; // 30%
  
  // Usuario principal con acceso completo
  static const Map<String, String> mainUser = {
    'email': 'andre@gmail.com',
    'password': '123456',
    'name': 'Andre De La Torre',
    'phone': '+51927535786',
  };
  
  // Usuarios de prueba adicionales
  static const Map<String, Map<String, String>> testUsers = {
    'cliente': {
      'email': 'cliente@arcosyglobos.pe',
      'password': 'cliente123',
      'name': 'Juan Pérez',
      'phone': '+51 987 654 321',
    },
    'decorador': {
      'email': 'decorador@arcosyglobos.pe',
      'password': 'decorador123',
      'name': 'María González',
      'phone': '+51 987 654 322',
    },
    'admin': {
      'email': 'admin@arcosyglobos.pe',
      'password': 'admin123',
      'name': 'Carlos Rodríguez',
      'phone': '+51 987 654 323',
    },
    'logistica': {
      'email': 'logistica@arcosyglobos.pe',
      'password': 'logistica123',
      'name': 'Ana Martínez',
      'phone': '+51 987 654 324',
    },
    'gestor': {
      'email': 'gestor@arcosyglobos.pe',
      'password': 'gestor123',
      'name': 'Luis Fernández',
      'phone': '+51 987 654 325',
    },
  };
}

