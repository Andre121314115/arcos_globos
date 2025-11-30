import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String templateId;
  final String templateName;
  final String templateType;
  final List<String> selectedColors;
  final double width;
  final double height;
  final double quoteAmount;
  final double depositAmount;
  final DateTime eventDate;
  final String eventAddress;
  final OrderStatus status;
  final List<String> venuePhotos;
  final List<String> setupPhotos;
  final String? assignedDecoratorId;
  final String? assignedDecoratorName;
  final String? assignedTeamId;
  final String? transportInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.templateId,
    required this.templateName,
    required this.templateType,
    required this.selectedColors,
    required this.width,
    required this.height,
    required this.quoteAmount,
    required this.depositAmount,
    required this.eventDate,
    required this.eventAddress,
    required this.status,
    this.venuePhotos = const [],
    this.setupPhotos = const [],
    this.assignedDecoratorId,
    this.assignedDecoratorName,
    this.assignedTeamId,
    this.transportInfo,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientEmail: map['clientEmail'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      templateId: map['templateId'] ?? '',
      templateName: map['templateName'] ?? '',
      templateType: map['templateType'] ?? '',
      selectedColors: List<String>.from(map['selectedColors'] ?? []),
      width: (map['width'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      quoteAmount: (map['quoteAmount'] ?? 0.0).toDouble(),
      depositAmount: (map['depositAmount'] ?? 0.0).toDouble(),
      eventDate: map['eventDate']?.toDate() ?? DateTime.now(),
      eventAddress: map['eventAddress'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      venuePhotos: List<String>.from(map['venuePhotos'] ?? []),
      setupPhotos: List<String>.from(map['setupPhotos'] ?? []),
      assignedDecoratorId: map['assignedDecoratorId'],
      assignedDecoratorName: map['assignedDecoratorName'],
      assignedTeamId: map['assignedTeamId'],
      transportInfo: map['transportInfo'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'templateId': templateId,
      'templateName': templateName,
      'templateType': templateType,
      'selectedColors': selectedColors,
      'width': width,
      'height': height,
      'quoteAmount': quoteAmount,
      'depositAmount': depositAmount,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventAddress': eventAddress,
      'status': status.toString().split('.').last,
      'venuePhotos': venuePhotos,
      'setupPhotos': setupPhotos,
      'assignedDecoratorId': assignedDecoratorId,
      'assignedDecoratorName': assignedDecoratorName,
      'assignedTeamId': assignedTeamId,
      'transportInfo': transportInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
    };
  }
}

enum OrderStatus {
  pending,
  quoted,
  reserved,
  assigned,
  inProgress,
  completed,
  cancelled,
}

