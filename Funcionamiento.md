**📚 GUÍA COMPLETA DE IMPLEMENTACIÓN - ARCO&GLOBOS**
**🔐 USUARIOS Y ACCESOS**
**Credenciales Principales**

Rol	Email	Contraseña	UID (Ejemplo)

Acceso Total	andre@gmail.com	123456	mqVXRDMYASRdbuEpDurAo25G2hp1
Cliente	cliente@arcosyglobos.pe	cliente123	uKCrwuxL0RVPoEMEcep4HjlZCLw2
Decorador	decorador@arcosyglobos.pe	decorador123	kgoN0muiaNQKz6FbA708hlUHWGd2
Administrador	admin@arcosyglobos.pe	admin123	1K2eJT3hZccZevBr0kAR5iU1zAT2
Logística	logistica@arcosyglobos.pe	logistica123	sWZyH2KjMkhcRhD51z9rOCA0CHw1
Gestor	gestor@arcosyglobos.pe	gestor123	79pGYsk8rDeGLTX51WF3YIy32S52

**🚀 CONFIGURACIÓN FIREBASE**
**1. Habilitar Servicios**
✅ Authentication: Email/Password
✅ Firestore Database
✅ Storage
**2. Crear Colecciones**
Colección users (6 documentos - usar UID como ID)
json
{
  "email": "string",
  "name": "string", 
  "phone": "string",
  "role": "admin|client|decorator|logistics|manager",
  "createdAt": "timestamp"
}
Colección templates (6 documentos)
json
{
  "name": "string",
  "description": "string",
  "type": "arco|columna|centro",
  "basePrice": number,
  "imageUrl": "string|null",
  "isActive": boolean,
  "createdAt": "timestamp"
}
**3. Reglas de Seguridad**
Firestore Rules
javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        request.auth.uid == userId || getUserRole() == 'admin'
      );
    }
    
    // Plantillas
    match /templates/{templateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && getUserRole() == 'admin';
    }
    
    // Órdenes
    match /orders/{orderId} {
      allow read: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.assignedDecoratorId == request.auth.uid ||
        getUserRole() in ['admin', 'logistics', 'manager']
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.assignedDecoratorId == request.auth.uid ||
        getUserRole() in ['admin', 'logistics', 'manager']
      );
    }
  }
}
Storage Rules
javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /templates/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && getUserRole() == 'admin';
    }
    
    match /orders/{orderId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
**📱 PANTALLAS IMPLEMENTADAS**
**Cliente (8 pantallas)**
login_screen.dart - Inicio de sesión con gradientes
register_screen.dart - Registro seguro
client_home_screen.dart - Dashboard principal
templates_screen.dart - Catálogo de plantillas
quote_screen.dart - Calculadora de cotizaciones
reservation_screen.dart - Reserva con pago de señal
my_orders_screen.dart - Historial de órdenes
order_detail_screen.dart - Detalles de orden
upload_venue_photos_screen.dart - Subida de fotos

**Administrador (3 pantallas)**
admin_dashboard.dart - Dashboard de admin
user_management_screen.dart - Gestión de usuarios
admin_templates_screen.dart - CRUD de plantillas

**Empleados (8 pantallas)**
employee_home_screen.dart - Dashboard por rol
decorator_orders_screen.dart - Órdenes para decoradores
logistics_orders_screen.dart - Gestión de envíos
manager_calendar_screen.dart - Calendario de eventos
reports_screen.dart - Reportes con gráficos
assign_team_screen.dart - Asignación de equipos
edit_template_screen.dart - Edición de plantillas
decorator_order_detail_screen.dart - Detalles para decoradores

**🎯 FUNCIONALIDADES POR HISTORIA DE USUARIO**
**HU-C (Cliente) - 100% COMPLETADO**
✅ C1: Elegir plantilla, colores, medidas → cotización instantánea
✅ C2: Reservar fecha específica y pagar señal (30%)
✅ C3: Subir fotos del lugar para referencia del decorador
✅ C4: Recibir fotos del montaje terminado

**HU-E (Empleados) - 100% COMPLETADO**
✅ E1: Decorador recibe órdenes asignadas y sube evidencia del montaje
✅ E2: Admin gestiona plantillas y precios (CRUD completo)
✅ E3: Logística asigna equipos y gestiona transporte
✅ E4: Gestor visualiza calendario de montajes y reportes de rutas

**Requerimientos Funcionales (MVP) - 100% COMPLETADO**
✅ RF1: Cotización basada en plantilla, colores y medidas
✅ RF2: Reserva con pago de señal (30%)
✅ RF3: Subida de fotos del lugar y evidencia de montaje
✅ RF4: Panel de decorador con órdenes asignadas
✅ RF5: Sistema de gestión de plantillas y precios
✅ RF6: Reportes de ocupación y optimización de rutas

**🎨 ESTILO Y DISEÑO**
**Tema Corporativo**
Color Principal: Colors.blue[800] (Azul corporativo)
Botones: BorderRadius.circular(12)
Tarjetas: BorderRadius.circular(16) con sombras
Gradientes: Azul a índigo para headers
Tipografía: Google Fonts con énfasis en legibilidad
Componentes Personalizados
AppBar con bordes redondeados inferiores
Tarjetas con sombras y efectos hover
Botones con estados visuales claros
Inputs con validación y feedback

**🛠️ TECNOLOGÍAS UTILIZADAS**
Frontend
Flutter 3.0+ con Null Safety
Material Design 3 (M3)
Provider para gestión de estado
Firebase Auth para autenticación
Cloud Firestore para base de datos
Firebase Storage para archivos
Intl para localización (es_PE)
Dependencias Principales
yaml
firebase_core: ^2.24.2
cloud_firestore: ^4.15.2
firebase_auth: ^4.15.1
firebase_storage: ^11.3.2
provider: ^6.1.1
intl: ^0.18.1
image_picker: ^1.0.4
table_calendar: ^3.0.9
flutter_launcher_icons: ^0.13.1
**📊 ESTRUCTURA DE DATOS**
Modelo OrderModel
dart
enum OrderStatus {
  pending,      // Pendiente
  quoted,       // Cotizado
  reserved,     // Reservado (con señal)
  assigned,     // Asignado a decorador
  inProgress,   // En montaje
  completed,    // Completado
  cancelled     // Cancelado
}
Modelo UserModel
dart
enum UserRole {
  admin,        // Administrador total
  client,       // Cliente
  decorator,    // Decorador
  logistics,    // Logística
  manager       // Gestor
}
Cálculo de Precios
dart
// Cotización = (precio base × área) + extras por colores
// Señal = 30% de la cotización
// Área = ancho × alto (metros)
🚀 INSTALACIÓN Y EJECUCIÓN
1. Configurar Firebase
bash
# Crear proyecto en Firebase Console
# Descargar google-services.json (Android) / GoogleService-Info.plist (iOS)
# Copiar archivos de configuración a las carpetas correspondientes
2. Ejecutar la App
bash
flutter clean
flutter pub get
flutter run
3. Generar APK
bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
✅ CHECKLIST FINAL DE IMPLEMENTACIÓN
Authentication: 6 usuarios creados con roles específicos
Firestore: Colecciones users y templates pobladas
Storage: Configurado para fotos de órdenes y plantillas
Seguridad: Reglas implementadas por rol
Interfaz: Todas las pantallas modernizadas
Funcionalidad: 100% de historias de usuario implementadas
Localización: Español Perú (es_PE) con moneda S/
Tema: Diseño corporativo consistente en toda la app
Navegación: Sistema de routing basado en roles
Estado: Gestión con Provider optimizada
APK: Generado y funcional

**🎖️ CARACTERÍSTICAS DESTACADAS**
Sistema de Roles Completo: 5 roles con permisos específicos
Cotización en Tiempo Real: Cálculo instantáneo basado en medidas
Gestión Visual de Órdenes: Estados claros con colores diferenciados
Calendario Interactivo: Vista mensual/semanal para gestores
Reportes con Gráficos: Estadísticas de ocupación y finanzas
Subida de Fotos Múltiple: Para clientes y decoradores
Diseño Responsivo: Adaptable a diferentes tamaños de pantalla
Localización Peruana: Formato de fechas, teléfonos y moneda

**📞 SOPORTE Y CONTACTO**
**Desarrollador: Andre De La Torre**
Email: delatorreandre03@gmail.com
Teléfono: +51927535786
Repositorio: Disponible en GitHub
Documentación: Completa en archivos README.md
Demo: APK disponible para pruebas

| Email | Password | UID (copiar después) |
|-------|----------|----------------------|
| andre@gmail.com | 123456 | [Se generará] |
| cliente@arcosyglobos.pe | cliente123 | [Se generará] |
| decorador@arcosyglobos.pe | decorador123 | [Se generará] |
| admin@arcosyglobos.pe | admin123 | [Se generará] |
| logistica@arcosyglobos.pe | logistica123 | [Se generará] |
| gestor@arcosyglobos.pe | gestor123 | [Se generará] |
