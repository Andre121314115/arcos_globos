/**
 * Script para inicializar datos en Firebase Firestore
 * Ejecutar desde Firebase Console > Firestore Database > Data > Run Script
 * O usar Firebase Admin SDK
 */

// Datos de usuarios
const users = [
  {
    id: 'user_antony',
    email: 'antony@gmail.com',
    name: 'Luis Antony',
    phone: '+51 912112268',
    role: 'admin',
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'user_cliente',
    email: 'cliente@arcosyglobos.pe',
    name: 'Juan Pérez',
    phone: '+51 987 654 321',
    role: 'client',
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'user_decorador',
    email: 'decorador@arcosyglobos.pe',
    name: 'María González',
    phone: '+51 987 654 322',
    role: 'decorator',
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'user_admin',
    email: 'admin@arcosyglobos.pe',
    name: 'Carlos Rodríguez',
    phone: '+51 987 654 323',
    role: 'admin',
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'user_logistica',
    email: 'logistica@arcosyglobos.pe',
    name: 'Ana Martínez',
    phone: '+51 987 654 324',
    role: 'logistics',
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'user_gestor',
    email: 'gestor@arcosyglobos.pe',
    name: 'Luis Fernández',
    phone: '+51 987 654 325',
    role: 'manager',
    createdAt: new Date('2024-01-15T10:30:00Z')
  }
];

// Datos de plantillas
const templates = [
  {
    id: 'template_arco_clasico',
    name: 'Arco Clásico',
    description: 'Arco decorativo elegante para eventos formales y ceremonias',
    type: 'arco',
    basePrice: 150.00,
    imageUrl: null,
    isActive: true,
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'template_arco_premium',
    name: 'Arco Premium',
    description: 'Arco decorativo de lujo con materiales premium',
    type: 'arco',
    basePrice: 250.00,
    imageUrl: null,
    isActive: true,
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'template_columna_basica',
    name: 'Columna Básica',
    description: 'Columna decorativa con globos estándar',
    type: 'columna',
    basePrice: 80.00,
    imageUrl: null,
    isActive: true,
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'template_columna_premium',
    name: 'Columna Premium',
    description: 'Columna decorativa con globos de alta calidad y diseño exclusivo',
    type: 'columna',
    basePrice: 120.00,
    imageUrl: null,
    isActive: true,
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'template_centro_basico',
    name: 'Centro de Mesa Básico',
    description: 'Centro de mesa decorativo estándar',
    type: 'centro',
    basePrice: 50.00,
    imageUrl: null,
    isActive: true,
    createdAt: new Date('2024-01-15T10:30:00Z')
  },
  {
    id: 'template_centro_elegante',
    name: 'Centro de Mesa Elegante',
    description: 'Centro de mesa decorativo elegante para eventos especiales',
    type: 'centro',
    basePrice: 90.00,
    imageUrl: null,
    isActive: true,
    createdAt: new Date('2024-01-15T10:30:00Z')
  }
];

// Función para convertir a formato Firestore
function toFirestoreDate(date) {
  return {
    _seconds: Math.floor(date.getTime() / 1000),
    _nanoseconds: (date.getTime() % 1000) * 1000000
  };
}

// Función para crear usuarios
function createUsers() {
  users.forEach(user => {
    const userData = {
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      createdAt: toFirestoreDate(user.createdAt)
    };
    console.log(`Creando usuario: ${user.email}`);
    // Aquí iría la lógica para crear en Firestore
    // db.collection('users').doc(user.id).set(userData);
  });
}

// Función para crear plantillas
function createTemplates() {
  templates.forEach(template => {
    const templateData = {
      name: template.name,
      description: template.description,
      type: template.type,
      basePrice: template.basePrice,
      imageUrl: template.imageUrl,
      isActive: template.isActive,
      createdAt: toFirestoreDate(template.createdAt)
    };
    console.log(`Creando plantilla: ${template.name}`);
    // Aquí iría la lógica para crear en Firestore
    // db.collection('templates').doc(template.id).set(templateData);
  });
}

console.log('Script de inicialización de Firebase');
console.log('Usuarios a crear:', users.length);
console.log('Plantillas a crear:', templates.length);

