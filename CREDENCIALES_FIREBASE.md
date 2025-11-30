# 🔐 Credenciales de Usuarios de Prueba - Arcos&Globos Perú

## 📧 Usuarios de Prueba

### 👤 Cliente
- **Email:** `cliente@arcosyglobos.pe`
- **Contraseña:** `cliente123`
- **Rol:** Cliente
- **Nombre:** Juan Pérez
- **Teléfono:** +51 987 654 321

### 🎨 Decorador
- **Email:** `decorador@arcosyglobos.pe`
- **Contraseña:** `decorador123`
- **Rol:** Decorador
- **Nombre:** María González
- **Teléfono:** +51 987 654 322

### 👨‍💼 Administrador
- **Email:** `admin@arcosyglobos.pe`
- **Contraseña:** `admin123`
- **Rol:** Administrador
- **Nombre:** Carlos Rodríguez
- **Teléfono:** +51 987 654 323

### 🚚 Logística
- **Email:** `logistica@arcosyglobos.pe`
- **Contraseña:** `logistica123`
- **Rol:** Logística
- **Nombre:** Ana Martínez
- **Teléfono:** +51 987 654 324

### 📅 Gestor
- **Email:** `gestor@arcosyglobos.pe`
- **Contraseña:** `gestor123`
- **Rol:** Gestor
- **Nombre:** Luis Fernández
- **Teléfono:** +51 987 654 325

## 🔥 Configuración de Firebase

### 1. Habilitar Servicios en Firebase Console

Ve a tu proyecto Firebase (`proyectofinal-fcbaa`) y habilita:

#### Authentication
1. Ve a **Authentication** > **Sign-in method**
2. Habilita **Email/Password**
3. Guarda los cambios

#### Cloud Firestore
1. Ve a **Firestore Database**
2. Crea la base de datos en modo **Producción** o **Prueba**
3. Configura las reglas de seguridad:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios: solo lectura/escritura propia
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Para búsquedas
    }
    
    // Plantillas: lectura pública, escritura solo admin
    match /templates/{templateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Órdenes: clientes ven las suyas, empleados ven las asignadas
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

#### Cloud Storage
1. Ve a **Storage**
2. Habilita Storage
3. Configura las reglas:

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

### 2. Crear Usuarios de Prueba

#### Opción A: Desde la App
1. Ejecuta la app
2. Ve a "Registrarse"
3. Crea cada usuario con las credenciales de arriba
4. Selecciona el rol correspondiente

#### Opción B: Desde Firebase Console
1. Ve a **Authentication** > **Users**
2. Haz clic en **Add user**
3. Ingresa email y contraseña
4. Luego crea el documento en Firestore en la colección `users`:

```json
{
  "email": "cliente@arcosyglobos.pe",
  "name": "Juan Pérez",
  "phone": "+51 987 654 321",
  "role": "client",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 3. Crear Datos de Ejemplo

#### Plantillas de Ejemplo (Colección: `templates`)

```json
{
  "name": "Arco Clásico",
  "description": "Arco decorativo elegante para eventos",
  "type": "arco",
  "basePrice": 150.00,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

```json
{
  "name": "Columna Premium",
  "description": "Columna decorativa con globos",
  "type": "columna",
  "basePrice": 80.00,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

```json
{
  "name": "Centro de Mesa",
  "description": "Centro de mesa decorativo",
  "type": "centro",
  "basePrice": 50.00,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

## 📱 Configuración de la App para Perú

La app ya está configurada para:
- ✅ Moneda: Soles Peruanos (S/)
- ✅ Locale: es_PE (Español de Perú)
- ✅ Formato de fecha: dd/MM/yyyy
- ✅ Teléfonos: Formato peruano (+51)

## 🚀 Probar la App

1. Ejecuta `flutter pub get`
2. Ejecuta `flutter run`
3. Inicia sesión con cualquiera de los usuarios de prueba
4. Explora las funcionalidades según el rol

## ⚠️ Notas Importantes

- Los usuarios de prueba deben crearse manualmente la primera vez
- Asegúrate de que Firebase esté correctamente configurado
- Las reglas de seguridad deben permitir las operaciones necesarias
- Los índices compuestos en Firestore se crearán automáticamente cuando los necesites

