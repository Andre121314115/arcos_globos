# 🚀 Guía para Inicializar Firebase - Arcos&Globos Perú

## 📋 Checklist de Funcionalidades Implementadas

### ✅ HU-C (Cliente)
- **HU-C1:** ✅ Elegir plantilla y colores - Cotización instantánea
- **HU-C2:** ✅ Reservar fecha y pagar señal
- **HU-C3:** ✅ Subir fotos del lugar para referencia
- **HU-C4:** ✅ Recibir fotos del montaje al finalizar

### ✅ HU-E (Empleados)
- **HU-E1:** ✅ Decorador: recibir órdenes y subir evidencia del montaje
- **HU-E2:** ✅ Admin: gestionar plantillas y precios (CRUD completo)
- **HU-E3:** ✅ Logística: asignar equipos y transporte
- **HU-E4:** ✅ Gestor: ver calendario de montajes y rutas

### ✅ RF (MVP)
- **RF1:** ✅ Cotización por plantilla/colores y medidas
- **RF2:** ✅ Reserva con pago de señal
- **RF3:** ✅ Subida de fotos del lugar y evidencia de montaje
- **RF4:** ✅ Panel decorador con órdenes
- **RF5:** ✅ Gestión plantillas y precios
- **RF6:** ✅ Reportes de ocupación y rutas

---

## 🔥 Paso 1: Configurar Firebase Console

### 1.1 Habilitar Authentication
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona proyecto: **proyectofinal-fcbaa**
3. **Authentication** > **Get Started** (si es primera vez)
4. **Sign-in method** > **Email/Password** > **Enable** > **Save**

### 1.2 Habilitar Firestore
1. **Firestore Database** > **Create database**
2. Modo: **Start in test mode** (para desarrollo)
3. Ubicación: **southamerica-east1** (cerca de Perú)
4. **Enable**

### 1.3 Habilitar Storage
1. **Storage** > **Get started**
2. Acepta reglas por defecto
3. Ubicación: **southamerica-east1**
4. **Done**

---

## 👤 Paso 2: Crear Usuarios en Authentication

Ve a **Authentication > Users > Add user** y crea:

| Email | Password | UID (copiar después) |
|-------|----------|----------------------|
| andre@gmail.com | 123456 | [Se generará] |
| cliente@arcosyglobos.pe | cliente123 | [Se generará] |
| decorador@arcosyglobos.pe | decorador123 | [Se generará] |
| admin@arcosyglobos.pe | admin123 | [Se generará] |
| logistica@arcosyglobos.pe | logistica123 | [Se generará] |
| gestor@arcosyglobos.pe | gestor123 | [Se generará] |

**IMPORTANTE:** Copia el UID de cada usuario, lo necesitarás para Firestore.

---

## 📁 Paso 3: Crear Documentos en Firestore

### Colección: `users`

Para cada usuario creado en Authentication, crea un documento en Firestore con el **UID como ID del documento**:

#### Usuario Principal (andre@gmail.com)
**ID:** [UID de andre@gmail.com]
```json
{
  "email": "andre@gmail.com",
  "name": "Andre De La Torre",
  "phone": "+51 912112268",
  "role": "admin",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Usuario Cliente
**ID:** [UID de cliente@arcosyglobos.pe]
```json
{
  "email": "cliente@arcosyglobos.pe",
  "name": "Juan Pérez",
  "phone": "+51 987 654 321",
  "role": "client",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Usuario Decorador
**ID:** [UID de decorador@arcosyglobos.pe]
```json
{
  "email": "decorador@arcosyglobos.pe",
  "name": "María González",
  "phone": "+51 987 654 322",
  "role": "decorator",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Usuario Administrador
**ID:** [UID de admin@arcosyglobos.pe]
```json
{
  "email": "admin@arcosyglobos.pe",
  "name": "Carlos Rodríguez",
  "phone": "+51 987 654 323",
  "role": "admin",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Usuario Logística
**ID:** [UID de logistica@arcosyglobos.pe]
```json
{
  "email": "logistica@arcosyglobos.pe",
  "name": "Ana Martínez",
  "phone": "+51 987 654 324",
  "role": "logistics",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Usuario Gestor
**ID:** [UID de gestor@arcosyglobos.pe]
```json
{
  "email": "gestor@arcosyglobos.pe",
  "name": "Luis Fernández",
  "phone": "+51 987 654 325",
  "role": "manager",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

---

### Colección: `templates`

Crea la colección `templates` y agrega estas plantillas:

#### Plantilla 1: Arco Clásico
```json
{
  "name": "Arco Clásico",
  "description": "Arco decorativo elegante para eventos formales y ceremonias",
  "type": "arco",
  "basePrice": 150.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Plantilla 2: Arco Premium
```json
{
  "name": "Arco Premium",
  "description": "Arco decorativo de lujo con materiales premium",
  "type": "arco",
  "basePrice": 250.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Plantilla 3: Columna Básica
```json
{
  "name": "Columna Básica",
  "description": "Columna decorativa con globos estándar",
  "type": "columna",
  "basePrice": 80.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Plantilla 4: Columna Premium
```json
{
  "name": "Columna Premium",
  "description": "Columna decorativa con globos de alta calidad y diseño exclusivo",
  "type": "columna",
  "basePrice": 120.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Plantilla 5: Centro de Mesa Básico
```json
{
  "name": "Centro de Mesa Básico",
  "description": "Centro de mesa decorativo estándar",
  "type": "centro",
  "basePrice": 50.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

#### Plantilla 6: Centro de Mesa Elegante
```json
{
  "name": "Centro de Mesa Elegante",
  "description": "Centro de mesa decorativo elegante para eventos especiales",
  "type": "centro",
  "basePrice": 90.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

---

## 🔒 Paso 4: Configurar Reglas de Seguridad

### Firestore Rules
Ve a **Firestore Database > Rules** y pega:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function para obtener el rol del usuario
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    // Usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        request.auth.uid == userId ||
        getUserRole() == 'admin'
      );
      allow create: if request.auth != null;
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
```

### Storage Rules
Ve a **Storage > Rules** y pega:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /templates/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /orders/{orderId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📊 Paso 5: Crear Índices Compuestos (Opcional)

Firestore te pedirá crear estos índices automáticamente cuando los necesites. Si quieres crearlos antes:

1. Ve a **Firestore Database > Indexes**
2. Haz clic en **Create Index**
3. Crea estos índices:

**Índice 1: orders - clientId + createdAt**
- Collection: `orders`
- Fields: `clientId` (Ascending), `createdAt` (Descending)

**Índice 2: orders - assignedDecoratorId + eventDate**
- Collection: `orders`
- Fields: `assignedDecoratorId` (Ascending), `eventDate` (Ascending)

**Índice 3: orders - eventDate (rango)**
- Collection: `orders`
- Fields: `eventDate` (Ascending)

---

## ✅ Paso 6: Verificar que Todo Funcione

1. **Ejecuta la app:**
   ```bash
   flutter pub get
   flutter run
   ```

2. **Inicia sesión con:**
   - Email: `andre@gmail.com`
   - Password: `123456`

3. **Verifica el acceso completo:**
   - Deberías ver el "Panel de Control - Acceso Completo"
   - Navega por todas las secciones
   - Verifica que no haya errores

4. **Prueba crear una orden:**
   - Ve a "Cliente" > "Plantillas"
   - Selecciona una plantilla
   - Elige colores y medidas
   - Calcula cotización
   - Reserva fecha

---

## 🎯 Resumen de Datos a Crear

- ✅ **6 usuarios** en Authentication
- ✅ **6 documentos** en Firestore colección `users` (usar UID como ID)
- ✅ **6 plantillas** en Firestore colección `templates`
- ✅ **Reglas de seguridad** configuradas
- ✅ **Índices compuestos** (se crearán automáticamente si es necesario)

---

## 📝 Notas Importantes

1. **UID es crítico:** El ID del documento en `users` DEBE ser el mismo UID de Authentication
2. **Timestamps:** Usa el formato Timestamp de Firestore (no strings)
3. **Moneda:** Todos los precios están en Soles Peruanos (S/)
4. **Usuario principal:** `andre@gmail.com` tiene acceso completo automáticamente
5. **Error de locale:** Ya está corregido con `initializeDateFormatting`

¡Todo está listo para funcionar! 🚀

