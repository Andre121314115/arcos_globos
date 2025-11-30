# 📊 Datos Iniciales para Firebase - Arcos&Globos Perú

## 🔐 Paso 1: Crear Usuarios en Authentication

Ve a **Firebase Console > Authentication > Users** y crea estos usuarios:

### Usuario Principal (Acceso Completo)
- **Email:** `andre@gmail.com`
- **Contraseña:** `123456`
- **UID:** (se generará automáticamente)

### Otros Usuarios
1. **Email:** `cliente@arcosyglobos.pe` | **Password:** `cliente123`
2. **Email:** `decorador@arcosyglobos.pe` | **Password:** `decorador123`
3. **Email:** `admin@arcosyglobos.pe` | **Password:** `admin123`
4. **Email:** `logistica@arcosyglobos.pe` | **Password:** `logistica123`
5. **Email:** `gestor@arcosyglobos.pe` | **Password:** `gestor123`

---

## 📁 Paso 2: Crear Documentos en Firestore

### Colección: `users`

#### Usuario Principal
**ID del documento:** (usa el UID de Authentication de andre@gmail.com)
```json
{
  "email": "andre@gmail.com",
  "name": "Andre De La Torre",
  "phone": "+51 927535786",
  "role": "admin",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Usuario Cliente
**ID del documento:** (usa el UID de Authentication de cliente@arcosyglobos.pe)
```json
{
  "email": "cliente@arcosyglobos.pe",
  "name": "Juan Pérez",
  "phone": "+51 987 654 321",
  "role": "client",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Usuario Decorador
**ID del documento:** (usa el UID de Authentication de decorador@arcosyglobos.pe)
```json
{
  "email": "decorador@arcosyglobos.pe",
  "name": "María González",
  "phone": "+51 987 654 322",
  "role": "decorator",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Usuario Administrador
**ID del documento:** (usa el UID de Authentication de admin@arcosyglobos.pe)
```json
{
  "email": "admin@arcosyglobos.pe",
  "name": "Carlos Rodríguez",
  "phone": "+51 987 654 323",
  "role": "admin",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Usuario Logística
**ID del documento:** (usa el UID de Authentication de logistica@arcosyglobos.pe)
```json
{
  "email": "logistica@arcosyglobos.pe",
  "name": "Ana Martínez",
  "phone": "+51 987 654 324",
  "role": "logistics",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Usuario Gestor
**ID del documento:** (usa el UID de Authentication de gestor@arcosyglobos.pe)
```json
{
  "email": "gestor@arcosyglobos.pe",
  "name": "Luis Fernández",
  "phone": "+51 987 654 325",
  "role": "manager",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### Colección: `templates`

#### Plantilla 1: Arco Clásico
**ID del documento:** `template_arco_clasico` (o deja que Firestore lo genere)
```json
{
  "name": "Arco Clásico",
  "description": "Arco decorativo elegante para eventos formales y ceremonias",
  "type": "arco",
  "basePrice": 150.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Plantilla 2: Arco Premium
**ID del documento:** `template_arco_premium`
```json
{
  "name": "Arco Premium",
  "description": "Arco decorativo de lujo con materiales premium",
  "type": "arco",
  "basePrice": 250.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Plantilla 3: Columna Básica
**ID del documento:** `template_columna_basica`
```json
{
  "name": "Columna Básica",
  "description": "Columna decorativa con globos estándar",
  "type": "columna",
  "basePrice": 80.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Plantilla 4: Columna Premium
**ID del documento:** `template_columna_premium`
```json
{
  "name": "Columna Premium",
  "description": "Columna decorativa con globos de alta calidad y diseño exclusivo",
  "type": "columna",
  "basePrice": 120.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Plantilla 5: Centro de Mesa Básico
**ID del documento:** `template_centro_basico`
```json
{
  "name": "Centro de Mesa Básico",
  "description": "Centro de mesa decorativo estándar",
  "type": "centro",
  "basePrice": 50.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

#### Plantilla 6: Centro de Mesa Elegante
**ID del documento:** `template_centro_elegante`
```json
{
  "name": "Centro de Mesa Elegante",
  "description": "Centro de mesa decorativo elegante para eventos especiales",
  "type": "centro",
  "basePrice": 90.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### Colección: `orders` (Opcional - Datos de Ejemplo)

#### Orden de Ejemplo 1: Reservada
**ID del documento:** (deja que Firestore lo genere)
```json
{
  "clientId": "[UID del cliente]",
  "clientName": "Juan Pérez",
  "clientEmail": "cliente@arcosyglobos.pe",
  "clientPhone": "+51 987 654 321",
  "templateId": "template_arco_clasico",
  "templateName": "Arco Clásico",
  "templateType": "arco",
  "selectedColors": ["Rojo", "Dorado", "Blanco"],
  "width": 3.0,
  "height": 2.5,
  "quoteAmount": 225.50,
  "depositAmount": 67.65,
  "eventDate": "2024-02-15T14:00:00Z",
  "eventAddress": "Av. Principal 123, San Isidro, Lima, Perú",
  "status": "reserved",
  "venuePhotos": [],
  "setupPhotos": [],
  "assignedDecoratorId": null,
  "assignedDecoratorName": null,
  "assignedTeamId": null,
  "transportInfo": null,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:35:00Z",
  "notes": null
}
```

#### Orden de Ejemplo 2: Asignada
```json
{
  "clientId": "[UID del cliente]",
  "clientName": "Juan Pérez",
  "clientEmail": "cliente@arcosyglobos.pe",
  "clientPhone": "+51 987 654 321",
  "templateId": "template_columna_premium",
  "templateName": "Columna Premium",
  "templateType": "columna",
  "selectedColors": ["Azul", "Plateado"],
  "width": 2.0,
  "height": 2.0,
  "quoteAmount": 180.00,
  "depositAmount": 54.00,
  "eventDate": "2024-02-20T16:00:00Z",
  "eventAddress": "Jr. Los Olivos 456, Miraflores, Lima, Perú",
  "status": "assigned",
  "venuePhotos": ["https://firebasestorage.googleapis.com/.../venue1.jpg"],
  "setupPhotos": [],
  "assignedDecoratorId": "[UID del decorador]",
  "assignedDecoratorName": "María González",
  "assignedTeamId": "team_001",
  "transportInfo": "Camioneta blanca, placa ABC-123",
  "createdAt": "2024-01-16T09:00:00Z",
  "updatedAt": "2024-01-17T11:00:00Z",
  "notes": "Cliente solicita instalación antes de las 3pm"
}
```

---

## 📋 Instrucciones para Crear los Datos

### Método 1: Desde Firebase Console (Manual)

1. **Crear Usuarios en Authentication:**
   - Ve a Firebase Console > Authentication > Users
   - Haz clic en "Add user"
   - Ingresa email y contraseña
   - Copia el UID generado

2. **Crear Documentos en Firestore:**
   - Ve a Firebase Console > Firestore Database
   - Haz clic en "Start collection"
   - Nombre de colección: `users`
   - Crea documentos con los datos de arriba
   - **IMPORTANTE:** Usa el UID de Authentication como ID del documento

3. **Crear Plantillas:**
   - Crea colección `templates`
   - Agrega cada plantilla como documento
   - Puedes usar IDs personalizados o dejar que Firestore los genere

### Método 2: Desde la App (Recomendado)

1. **Registrar Usuarios:**
   - Ejecuta la app
   - Ve a "Registrarse"
   - Crea cada usuario con las credenciales indicadas
   - Selecciona el rol correspondiente

2. **Crear Plantillas (como Admin):**
   - Inicia sesión con `andre@gmail.com` o `admin@arcosyglobos.pe`
   - Ve a "Administrador" > "Gestión de Plantillas"
   - Haz clic en el botón "+" para crear nuevas plantillas
   - Completa el formulario con los datos de arriba

---

## ✅ Verificación de Funcionalidades

### HU-C1: Elegir plantilla y colores - Cotización instantánea
✅ **Implementado:** `lib/screens/client/quote_screen.dart`
- Selección de plantilla
- Selección de colores
- Ingreso de medidas
- Cálculo automático de cotización

### HU-C2: Reservar fecha y pagar señal
✅ **Implementado:** `lib/screens/client/reservation_screen.dart`
- Selección de fecha
- Ingreso de dirección
- Cálculo de señal (30%)
- Creación de orden con estado "reserved"

### HU-C3: Subir fotos del lugar
✅ **Implementado:** `lib/screens/client/upload_venue_photos_screen.dart`
- Selección múltiple de imágenes
- Subida a Firebase Storage
- Almacenamiento de URLs en Firestore

### HU-C4: Recibir fotos del montaje
✅ **Implementado:** `lib/screens/client/order_detail_screen.dart`
- Visualización de fotos del montaje
- Las fotos son subidas por el decorador

### HU-E1: Decorador - Recibir órdenes y subir evidencia
✅ **Implementado:** 
- `lib/screens/employee/decorator_orders_screen.dart` - Ver órdenes asignadas
- `lib/screens/employee/decorator_order_detail_screen.dart` - Subir fotos del montaje

### HU-E2: Admin - Gestionar plantillas y precios
✅ **Implementado:**
- `lib/screens/employee/admin_templates_screen.dart` - Lista de plantillas
- `lib/screens/employee/edit_template_screen.dart` - CRUD completo

### HU-E3: Logística - Asignar equipos y transporte
✅ **Implementado:**
- `lib/screens/employee/logistics_orders_screen.dart` - Ver órdenes
- `lib/screens/employee/assign_team_screen.dart` - Asignar equipo y transporte

### HU-E4: Gestor - Ver calendario de montajes
✅ **Implementado:** `lib/screens/employee/manager_calendar_screen.dart`
- Calendario interactivo
- Visualización de órdenes por fecha
- Información de rutas y equipos

---

## 🔥 Reglas de Seguridad Firestore

Asegúrate de configurar estas reglas en Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        request.auth.uid == userId ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
      allow create: if request.auth != null;
    }
    
    // Plantillas
    match /templates/{templateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Órdenes
    match /orders/{orderId} {
      allow read: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.assignedDecoratorId == request.auth.uid ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'logistics', 'manager']
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.clientId == request.auth.uid ||
        resource.data.assignedDecoratorId == request.auth.uid ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'logistics', 'manager']
      );
    }
  }
}
```

---

## 📝 Notas Finales

- Todos los precios están en **Soles Peruanos (S/)**
- Las fechas deben ser objetos **Timestamp** de Firestore
- Los arrays pueden crecer dinámicamente
- Los campos `nullable` pueden ser `null`
- El usuario `andre@gmail.com` tiene **acceso completo** a todas las funcionalidades

