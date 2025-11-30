import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      // Si el usuario no existe en Firestore pero es el usuario principal, crearlo automáticamente
      if (user.email == 'antony@gmail.com') {
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? 'antony@gmail.com',
          name: 'Luis Antony',
          phone: '+51 912112268',
          role: UserRole.admin, // Rol por defecto, pero tendrá acceso completo
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
      return null;
    }

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    UserRole role = UserRole.client,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrar';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo electrónico ya está en uso';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es muy débil';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico no es válido';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Autenticación por email no está habilitada. Por favor, habilítala en Firebase Console';
      } else if (e.code == 'unknown' || e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        errorMessage = 'Firebase no está configurado correctamente. Verifica que Authentication esté habilitado en Firebase Console';
      }
      throw Exception('$errorMessage: ${e.message}');
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = await getCurrentUserData();
      if (userData == null) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        errorMessage = 'No existe una cuenta con este correo';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico no es válido';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Esta cuenta ha sido deshabilitada';
      } else if (e.code == 'unknown' || e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        errorMessage = 'Firebase no está configurado correctamente. Verifica que Authentication esté habilitado en Firebase Console';
      }
      throw Exception('$errorMessage: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

