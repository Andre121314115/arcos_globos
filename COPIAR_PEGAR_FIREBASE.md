# 📋 Datos Listos para Copiar y Pegar en Firebase

## 🔐 USUARIOS EN AUTHENTICATION

Crea estos usuarios en **Firebase Console > Authentication > Users > Add user**:

1. **andre@gmail.com** / **123456**
2. **cliente@arcosyglobos.pe** / **cliente123**
3. **decorador@arcosyglobos.pe** / **decorador123**
4. **admin@arcosyglobos.pe** / **admin123**
5. **logistica@arcosyglobos.pe** / **logistica123**
6. **gestor@arcosyglobos.pe** / **gestor123**

**IMPORTANTE:** Después de crear cada usuario, copia su UID. Lo necesitarás para Firestore.

---

## 📁 COLECCIÓN: `users`

Crea la colección `users` y para cada usuario, crea un documento usando el **UID como ID del documento**.

### Documento 1: andre@gmail.com
**ID del documento:** [mqVXRDMYASRdbuEpDurAo25G2hp1]
```json
{
  "email": "ande@gmail.com",
  "name": "Andre De La Torre",
  "phone": "+51 927535786",
  "role": "admin",
  "createdAt": {
    "_seconds": 1705320600,
    "_nanoseconds": 0
  }
}
```

### Documento 2: cliente@arcosyglobos.pe
**ID del documento:** [uKCrwuxL0RVPoEMEcep4HjlZCLw2]
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

### Documento 3: decorador@arcosyglobos.pe
**ID del documento:** [kgoN0muiaNQKz6FbA708hlUHWGd2]
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

### Documento 4: admin@arcosyglobos.pe
**ID del documento:** [1K2eJT3hZccZevBr0kAR5iU1zAT2]
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

### Documento 5: logistica@arcosyglobos.pe
**ID del documento:** [sWZyH2KjMkhcRhD51z9rOCA0CHw1]
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

### Documento 6: gestor@arcosyglobos.pe
**ID del documento:** [79pGYsk8rDeGLTX51WF3YIy32S52]
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

## 📁 COLECCIÓN: `templates`

Crea la colección `templates` y agrega estos documentos:

### Documento 1: Arco Clásico
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

### Documento 2: Arco Premium
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

### Documento 3: Columna Básica
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

### Documento 4: Columna Premium
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

### Documento 5: Centro de Mesa Básico
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

### Documento 6: Centro de Mesa Elegante
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

## 🔒 REGLAS DE SEGURIDAD FIRESTORE

Copia y pega en **Firestore Database > Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        request.auth.uid == userId ||
        getUserRole() == 'admin'
      );
      allow create: if request.auth != null;
    }
    
    match /templates/{templateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && getUserRole() == 'admin';
    }
    
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

---

## 🔒 REGLAS DE SEGURIDAD STORAGE

Copia y pega en **Storage > Rules**:

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

## ✅ CHECKLIST FINAL

- [ ] Authentication habilitado (Email/Password)
- [ ] Firestore habilitado
- [ ] Storage habilitado
- [ ] 6 usuarios creados en Authentication
- [ ] 6 documentos creados en colección `users` (con UID como ID)
- [ ] 6 plantillas creadas en colección `templates`
- [ ] Reglas de Firestore configuradas
- [ ] Reglas de Storage configuradas
- [ ] App ejecutándose sin errores
- [ ] Login exitoso con andre@gmail.com / 123456
- [ ] Panel de control con acceso completo visible

---

## 🎯 Credenciales de Acceso Completo

**Email:** `andre@gmail.com`  
**Contraseña:** `123456`

Este usuario tiene acceso a TODAS las funcionalidades de la app.

