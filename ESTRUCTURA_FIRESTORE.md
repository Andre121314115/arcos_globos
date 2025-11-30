# 📊 Estructura de Firestore - Arcos&Globos Perú

## 🔐 Usuario Principal (Acceso Completo)
- **Email:** `andre@gmail.com`
- **Contraseña:** `123456`
- **Nombre:** `Andre De La Torre`
- **Teléfono:** `+51 912112268`
- **Rol en Firestore:** `admin` (pero tiene acceso a TODAS las funcionalidades)
- **Acceso:** ✅ Acceso completo a todas las pantallas y funcionalidades

---

## 📁 Colecciones de Firestore

### 1. Colección: `users`

**Descripción:** Almacena información de todos los usuarios (clientes, decoradores, admin, etc.)

**Estructura del Documento:**
```json
{
  "email": "string",
  "name": "string",
  "phone": "string",
  "role": "string",
  "createdAt": "timestamp"
}
```

**Campos Detallados:**

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `email` | String | Correo electrónico del usuario | `"andre@gmail.com"` |
| `name` | String | Nombre completo | `"Andre De La Torre"` |
| `phone` | String | Teléfono con código de país | `"+51 987 654 321"` |
| `role` | String | Rol del usuario: `client`, `decorator`, `admin`, `logistics`, `manager` | `"client"` |
| `createdAt` | Timestamp | Fecha de creación del usuario | `Timestamp(2024, 1, 15, 10, 30, 0)` |

**Ejemplo de Documento (Usuario Principal con Acceso Completo):**
```json
{
  "email": "andre@gmail.com",
  "name": "Andre De La Torre",
  "phone": "+51 927535786",
  "role": "admin",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Nota:** Este usuario tiene acceso completo a todas las funcionalidades independientemente del rol asignado en Firestore.

**Ejemplo de Documento (Usuario Admin):**
```json
{
  "email": "andre@gmail.com",
  "name": "Andre De La Torre",
  "phone": "+51 987 654 321",
  "role": "admin",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### 2. Colección: `templates`

**Descripción:** Almacena las plantillas de decoración disponibles (arcos, columnas, centros)

**Estructura del Documento:**
```json
{
  "name": "string",
  "description": "string",
  "type": "string",
  "basePrice": "number",
  "imageUrl": "string (nullable)",
  "isActive": "boolean",
  "createdAt": "timestamp"
}
```

**Campos Detallados:**

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `name` | String | Nombre de la plantilla | `"Arco Clásico"` |
| `description` | String | Descripción detallada | `"Arco decorativo elegante para eventos"` |
| `type` | String | Tipo: `arco`, `columna`, `centro` | `"arco"` |
| `basePrice` | Number (Double) | Precio base en soles peruanos | `150.00` |
| `imageUrl` | String (nullable) | URL de la imagen en Firebase Storage | `"https://firebasestorage..."` o `null` |
| `isActive` | Boolean | Si la plantilla está activa | `true` |
| `createdAt` | Timestamp | Fecha de creación | `Timestamp(2024, 1, 15, 10, 30, 0)` |

**Ejemplos de Documentos:**

**Arco:**
```json
{
  "name": "Arco Clásico",
  "description": "Arco decorativo elegante para eventos formales",
  "type": "arco",
  "basePrice": 150.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Columna:**
```json
{
  "name": "Columna Premium",
  "description": "Columna decorativa con globos de alta calidad",
  "type": "columna",
  "basePrice": 80.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Centro:**
```json
{
  "name": "Centro de Mesa Elegante",
  "description": "Centro de mesa decorativo para eventos",
  "type": "centro",
  "basePrice": 50.00,
  "imageUrl": null,
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

### 3. Colección: `orders`

**Descripción:** Almacena todas las órdenes de decoración realizadas por los clientes

**Estructura del Documento:**
```json
{
  "clientId": "string",
  "clientName": "string",
  "clientEmail": "string",
  "clientPhone": "string",
  "templateId": "string",
  "templateName": "string",
  "templateType": "string",
  "selectedColors": "array of strings",
  "width": "number",
  "height": "number",
  "quoteAmount": "number",
  "depositAmount": "number",
  "eventDate": "timestamp",
  "eventAddress": "string",
  "status": "string",
  "venuePhotos": "array of strings",
  "setupPhotos": "array of strings",
  "assignedDecoratorId": "string (nullable)",
  "assignedDecoratorName": "string (nullable)",
  "assignedTeamId": "string (nullable)",
  "transportInfo": "string (nullable)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp (nullable)",
  "notes": "string (nullable)"
}
```

**Campos Detallados:**

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `clientId` | String | ID del usuario cliente (UID de Firebase Auth) | `"abc123..."` |
| `clientName` | String | Nombre del cliente | `"Antony Guerrero"` |
| `clientEmail` | String | Email del cliente | `"antony@gmail.com"` |
| `clientPhone` | String | Teléfono del cliente | `"+51 987 654 321"` |
| `templateId` | String | ID de la plantilla seleccionada | `"template123"` |
| `templateName` | String | Nombre de la plantilla | `"Arco Clásico"` |
| `templateType` | String | Tipo de plantilla | `"arco"` |
| `selectedColors` | Array[String] | Colores seleccionados | `["Rojo", "Azul", "Dorado"]` |
| `width` | Number (Double) | Ancho en metros | `3.0` |
| `height` | Number (Double) | Alto en metros | `2.5` |
| `quoteAmount` | Number (Double) | Monto total de la cotización en soles | `225.50` |
| `depositAmount` | Number (Double) | Monto de la señal (30%) en soles | `67.65` |
| `eventDate` | Timestamp | Fecha del evento | `Timestamp(2024, 2, 15, 14, 0, 0)` |
| `eventAddress` | String | Dirección del evento | `"Av. Principal 123, Lima, Perú"` |
| `status` | String | Estado: `pending`, `quoted`, `reserved`, `assigned`, `inProgress`, `completed`, `cancelled` | `"reserved"` |
| `venuePhotos` | Array[String] | URLs de fotos del lugar | `["https://storage.../photo1.jpg"]` |
| `setupPhotos` | Array[String] | URLs de fotos del montaje | `["https://storage.../setup1.jpg"]` |
| `assignedDecoratorId` | String (nullable) | ID del decorador asignado | `"decorator123"` o `null` |
| `assignedDecoratorName` | String (nullable) | Nombre del decorador | `"María González"` o `null` |
| `assignedTeamId` | String (nullable) | ID del equipo asignado | `"team001"` o `null` |
| `transportInfo` | String (nullable) | Información de transporte | `"Camioneta blanca, placa ABC-123"` o `null` |
| `createdAt` | Timestamp | Fecha de creación de la orden | `Timestamp(2024, 1, 15, 10, 30, 0)` |
| `updatedAt` | Timestamp (nullable) | Fecha de última actualización | `Timestamp(2024, 1, 16, 15, 20, 0)` o `null` |
| `notes` | String (nullable) | Notas adicionales | `"Cliente solicita entrega antes de las 2pm"` o `null` |

**Ejemplo de Documento Completo:**
```json
{
  "clientId": "abc123def456",
  "clientName": "Antony Guerrero",
  "clientEmail": "antony@gmail.com",
  "clientPhone": "+51 987 654 321",
  "templateId": "template_arco_001",
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
  "venuePhotos": ["https://firebasestorage.googleapis.com/.../venue1.jpg"],
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

**Ejemplo de Orden Asignada:**
```json
{
  "clientId": "abc123def456",
  "clientName": "Antony Guerrero",
  "clientEmail": "antony@gmail.com",
  "clientPhone": "+51 987 654 321",
  "templateId": "template_arco_001",
  "templateName": "Arco Clásico",
  "templateType": "arco",
  "selectedColors": ["Rojo", "Dorado"],
  "width": 2.0,
  "height": 2.0,
  "quoteAmount": 180.00,
  "depositAmount": 54.00,
  "eventDate": "2024-02-20T16:00:00Z",
  "eventAddress": "Jr. Los Olivos 456, Miraflores, Lima, Perú",
  "status": "assigned",
  "venuePhotos": ["https://firebasestorage.googleapis.com/.../venue1.jpg"],
  "setupPhotos": [],
  "assignedDecoratorId": "decorator_maria_001",
  "assignedDecoratorName": "María González",
  "assignedTeamId": "team_001",
  "transportInfo": "Camioneta blanca, placa ABC-123",
  "createdAt": "2024-01-16T09:00:00Z",
  "updatedAt": "2024-01-17T11:00:00Z",
  "notes": "Cliente solicita instalación antes de las 3pm"
}
```

---

## 📋 Resumen de Tipos de Datos

### Tipos Básicos en Firestore:
- **String:** Texto
- **Number:** Números (Integer o Double)
- **Boolean:** `true` o `false`
- **Timestamp:** Fecha y hora
- **Array:** Lista de valores del mismo tipo
- **Map/Object:** Objeto anidado (no usado en esta estructura)
- **Null:** Valor nulo (para campos opcionales)

### Valores Especiales:

**Roles de Usuario (`role`):**
- `"client"` - Cliente
- `"decorator"` - Decorador
- `"admin"` - Administrador
- `"logistics"` - Logística
- `"manager"` - Gestor

**Tipos de Plantilla (`type`):**
- `"arco"` - Arco decorativo
- `"columna"` - Columna decorativa
- `"centro"` - Centro de mesa

**Estados de Orden (`status`):**
- `"pending"` - Pendiente
- `"quoted"` - Cotizado
- `"reserved"` - Reservado (con señal pagada)
- `"assigned"` - Asignado a decorador
- `"inProgress"` - En progreso
- `"completed"` - Completado
- `"cancelled"` - Cancelado

**Colores Disponibles (`selectedColors`):**
- `"Rojo"`, `"Azul"`, `"Amarillo"`, `"Verde"`, `"Rosa"`, `"Morado"`, `"Naranja"`, `"Blanco"`, `"Negro"`, `"Dorado"`, `"Plateado"`

---

## 🔥 Reglas de Seguridad Recomendadas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
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

## 📝 Notas Importantes

1. **IDs de Documentos:** Firestore genera automáticamente los IDs, pero puedes usar IDs personalizados
2. **Timestamps:** Se almacenan como objetos Timestamp de Firestore
3. **Arrays:** Los arrays pueden crecer dinámicamente (ej: agregar más fotos)
4. **Nullables:** Los campos marcados como `nullable` pueden ser `null` o tener un valor
5. **Moneda:** Todos los precios están en Soles Peruanos (PEN)
6. **Fechas:** Usar formato ISO 8601 o Timestamp de Firestore

