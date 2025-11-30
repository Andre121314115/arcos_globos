import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear orden: $e');
    }
  }

  Stream<List<OrderModel>> getClientOrders(String clientId) {
    return _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
          debugPrint('Error en getClientOrders: $error');
          return <OrderModel>[];
        });
  }

  Stream<List<OrderModel>> getDecoratorOrders(String decoratorId) {
    return _firestore
        .collection('orders')
        .where('assignedDecoratorId', isEqualTo: decoratorId)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
          debugPrint('Error en getDecoratorOrders: $error');
          return <OrderModel>[];
        });
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList())
        .handleError((error) {
          debugPrint('Error en getAllOrders: $error');
          return <OrderModel>[];
        });
  }

  Future<List<OrderModel>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error en getOrdersByDateRange: $e');
      // Si falla por índices, intentar sin el segundo where
      try {
        final snapshot = await _firestore
            .collection('orders')
            .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .get();
        return snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .where((order) => order.eventDate.isBefore(end.add(const Duration(days: 1))))
            .toList();
      } catch (e2) {
        debugPrint('Error en getOrdersByDateRange (fallback): $e2');
        return [];
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.toString().split('.').last,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<String> uploadVenuePhoto(String orderId, File imageFile) async {
    try {
      final ref = _storage.ref().child('orders/$orderId/venue/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      
      await _firestore.collection('orders').doc(orderId).update({
        'venuePhotos': FieldValue.arrayUnion([url]),
      });
      
      return url;
    } catch (e) {
      throw Exception('Error al subir foto: $e');
    }
  }

  Future<String> uploadSetupPhoto(String orderId, File imageFile) async {
    try {
      final ref = _storage.ref().child('orders/$orderId/setup/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      
      await _firestore.collection('orders').doc(orderId).update({
        'setupPhotos': FieldValue.arrayUnion([url]),
        'status': OrderStatus.completed.toString().split('.').last,
        'updatedAt': Timestamp.now(),
      });
      
      return url;
    } catch (e) {
      throw Exception('Error al subir foto: $e');
    }
  }

  Future<void> assignDecorator(String orderId, String decoratorId, String decoratorName) async {
    await _firestore.collection('orders').doc(orderId).update({
      'assignedDecoratorId': decoratorId,
      'assignedDecoratorName': decoratorName,
      'status': OrderStatus.assigned.toString().split('.').last,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> assignTeamAndTransport(String orderId, String teamId, String transportInfo) async {
    await _firestore.collection('orders').doc(orderId).update({
      'assignedTeamId': teamId,
      'transportInfo': transportInfo,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> reserveOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.reserved.toString().split('.').last,
      'updatedAt': Timestamp.now(),
    });
  }
}

