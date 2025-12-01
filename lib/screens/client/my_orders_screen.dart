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
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No autenticado',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final orderService = OrderService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getClientOrders(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Cargando tus pedidos...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 64,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar pedidos',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aún no tienes pedidos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cuando hagas una reserva, aparecerá aquí',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar al catálogo de plantillas
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Explorar Plantillas'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // ✅ HEADER INFORMATIVO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.blue[100]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${orders.length} ${orders.length == 1 ? 'pedido' : 'pedidos'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text(
                            'Historial de tus reservas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ LISTA DE PEDIDOS MEJORADA
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ TARJETA DE ORDEN MEJORADA
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER DE LA ORDEN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.templateName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ INFORMACIÓN DE LA ORDEN
              _buildOrderInfoRow(
                Icons.calendar_today,
                'Fecha del evento:',
                DateFormat('dd/MM/yyyy').format(order.eventDate),
              ),
              const SizedBox(height: 6),
              _buildOrderInfoRow(
                Icons.attach_money,
                'Total:',
                CurrencyFormatter.format(order.quoteAmount),
              ),
              const SizedBox(height: 6),
              _buildOrderInfoRow(
                Icons.payment,
                'Señal pagada:',
                CurrencyFormatter.format(order.depositAmount),
              ),

              // ✅ COLORES SELECCIONADOS
              if (order.selectedColors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Colores: ${order.selectedColors.join(", ")}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ✅ BOTÓN PARA SUBIR FOTOS (SOLO EN ESTADOS ESPECÍFICOS)
              if (order.status == OrderStatus.reserved ||
                  order.status == OrderStatus.assigned) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UploadVenuePhotosScreen(order: order),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_camera, size: 20),
                    label: const Text('Subir Fotos del Lugar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              // ✅ BOTÓN VER DETALLES
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver detalles'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FILA DE INFORMACIÓN DE ORDEN
  Widget _buildOrderInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.grey[300]!;
      case OrderStatus.quoted:
        return Colors.blue[100]!;
      case OrderStatus.reserved:
        return Colors.orange[100]!;
      case OrderStatus.assigned:
        return Colors.purple[100]!;
      case OrderStatus.inProgress:
        return Colors.yellow[100]!;
      case OrderStatus.completed:
        return Colors.green[100]!;
      case OrderStatus.cancelled:
        return Colors.red[100]!;
    }
  }

  Color _getStatusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.grey[800]!;
      case OrderStatus.quoted:
        return Colors.blue[800]!;
      case OrderStatus.reserved:
        return Colors.orange[800]!;
      case OrderStatus.assigned:
        return Colors.purple[800]!;
      case OrderStatus.inProgress:
        return Colors.yellow[800]!;
      case OrderStatus.completed:
        return Colors.green[800]!;
      case OrderStatus.cancelled:
        return Colors.red[800]!;
    }
  }
}