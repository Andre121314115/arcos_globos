class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.client,
      ),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
    };
  }

  // Verificar si es el usuario principal con acceso completo
  bool get hasFullAccess {
    return email == 'andre@gmail.com';
  }

  // Obtener todos los roles disponibles para este usuario
  List<UserRole> get availableRoles {
    if (hasFullAccess) {
      return UserRole.values; // Acceso a todos los roles
    }
    return [role]; // Solo su rol
  }
}

enum UserRole {
  client,
  decorator,
  admin,
  logistics,
  manager,
}

