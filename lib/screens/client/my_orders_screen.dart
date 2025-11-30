import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/currency_formatter.dart';
import 'order_detail_screen.dart';
import 'upload_venue_photos_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }

    final orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Órdenes'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getClientOrders(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text('No tienes órdenes aún'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.templateName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(_getStatusText(order.status)),
                              backgroundColor: _getStatusColor(order.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(order.eventDate)}'),
                        Text('Total: ${CurrencyFormatter.format(order.quoteAmount)}'),
                        Text('Señal: ${CurrencyFormatter.format(order.depositAmount)}'),
                        if (order.status == OrderStatus.reserved ||
                            order.status == OrderStatus.assigned) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UploadVenuePhotosScreen(order: order),
                                ),
                              );
                            },
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Subir Fotos del Lugar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.quoted:
        return 'Cotizado';
      case OrderStatus.reserved:
        return 'Reservado';
      case OrderStatus.assigned:
        return 'Asignado';
      case OrderStatus.inProgress:
        return 'En Progreso';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color? _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.grey[300];
      case OrderStatus.quoted:
        return Colors.blue[100];
      case OrderStatus.reserved:
        return Colors.orange[100];
      case OrderStatus.assigned:
        return Colors.purple[100];
      case OrderStatus.inProgress:
        return Colors.yellow[100];
      case OrderStatus.completed:
        return Colors.green[100];
      case OrderStatus.cancelled:
        return Colors.red[100];
    }
  }
}

