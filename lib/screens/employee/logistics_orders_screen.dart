import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'assign_team_screen.dart';

class LogisticsOrdersScreen extends StatelessWidget {
  const LogisticsOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Logística'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          final reservedOrders = orders
              .where((o) =>
                  o.status == OrderStatus.reserved ||
                  o.status == OrderStatus.assigned)
              .toList();

          if (reservedOrders.isEmpty) {
            return const Center(
              child: Text('No hay órdenes para asignar'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservedOrders.length,
            itemBuilder: (context, index) {
              final order = reservedOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.templateName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(_getStatusText(order.status)),
                            backgroundColor: _getStatusColor(order.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Cliente: ${order.clientName}'),
                      Text('Fecha: ${DateFormat('dd/MM/yyyy').format(order.eventDate)}'),
                      Text('Dirección: ${order.eventAddress}'),
                      if (order.assignedTeamId != null)
                        Text('Equipo: ${order.assignedTeamId}'),
                      if (order.transportInfo != null)
                        Text('Transporte: ${order.transportInfo}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AssignTeamScreen(order: order),
                            ),
                          );
                        },
                        child: const Text('Asignar Equipo y Transporte'),
                      ),
                    ],
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

