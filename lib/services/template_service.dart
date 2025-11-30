import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/template_model.dart';

class TemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<TemplateModel>> getTemplates() {
    return _firestore
        .collection('templates')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
          debugPrint('Error en getTemplates: $error');
          return <TemplateModel>[];
        });
  }

  Future<List<TemplateModel>> getTemplatesOnce() async {
    try {
      final snapshot = await _firestore
          .collection('templates')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => TemplateModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en getTemplatesOnce: $e');
      return [];
    }
  }

  Future<TemplateModel?> getTemplate(String id) async {
    final doc = await _firestore.collection('templates').doc(id).get();
    if (!doc.exists) return null;
    return TemplateModel.fromMap(doc.data()!, doc.id);
  }

  Future<String> createTemplate(TemplateModel template, File? imageFile) async {
    try {
      String? imageUrl;
      
      if (imageFile != null) {
        final ref = _storage.ref().child('templates/${template.id}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final templateWithImage = TemplateModel(
        id: template.id,
        name: template.name,
        description: template.description,
        type: template.type,
        basePrice: template.basePrice,
        imageUrl: imageUrl,
        isActive: template.isActive,
        createdAt: template.createdAt,
      );

      await _firestore
          .collection('templates')
          .doc(template.id)
          .set(templateWithImage.toMap());

      return template.id;
    } catch (e) {
      throw Exception('Error al crear plantilla: $e');
    }
  }

  Future<void> updateTemplate(TemplateModel template, File? imageFile) async {
    try {
      String? imageUrl = template.imageUrl;
      
      if (imageFile != null) {
        final ref = _storage.ref().child('templates/${template.id}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final templateWithImage = TemplateModel(
        id: template.id,
        name: template.name,
        description: template.description,
        type: template.type,
        basePrice: template.basePrice,
        imageUrl: imageUrl,
        isActive: template.isActive,
        createdAt: template.createdAt,
      );

      await _firestore
          .collection('templates')
          .doc(template.id)
          .update(templateWithImage.toMap());
    } catch (e) {
      throw Exception('Error al actualizar plantilla: $e');
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _firestore.collection('templates').doc(id).update({'isActive': false});
    } catch (e) {
      throw Exception('Error al eliminar plantilla: $e');
    }
  }
}

