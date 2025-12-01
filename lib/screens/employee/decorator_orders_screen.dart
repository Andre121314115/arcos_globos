import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/currency_formatter.dart';
import 'decorator_order_detail_screen.dart';

class DecoratorOrdersScreen extends StatelessWidget {
  const DecoratorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // ✅ VERIFICACIÓN DE SEGURIDAD MEJORADA - Solo decoradores
    if (user == null || user.role != UserRole.decorator) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Acceso Denegado'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.brush,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Acceso Restringido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Solo los decoradores pueden acceder a esta sección.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final orderService = OrderService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mis Montajes',
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
        stream: orderService.getDecoratorOrders(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Cargando tus montajes...',
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
                      Icons.error_outline,
                      size: 64,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar órdenes',
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

          return Column(
            children: [
              // ✅ HEADER INFORMATIVO PERSONALIZADO
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
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.brush,
                        color: Colors.purple[700],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${user.name.split(' ').first}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${orders.length} ${orders.length == 1 ? 'montaje asignado' : 'montajes asignados'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Decorador',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ FILTROS POR ESTADO (OPCIONAL)
              if (orders.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', true),
                        _buildFilterChip('Pendientes', false),
                        _buildFilterChip('En Progreso', false),
                        _buildFilterChip('Completados', false),
                      ],
                    ),
                  ),
                ),
              ],

              // ✅ LISTA DE ÓRDENES MEJORADA
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_turned_in,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No tienes montajes asignados',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Cuando te asignen un montaje, aparecerá aquí',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.purple[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.purple[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '💡 ¿Cómo funciona?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '1. Logística te asignará a un montaje\n2. Verás los detalles aquí\n3. Subirás fotos del trabajo terminado',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.purple[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _buildOrderCard(context, order);
                          },
                        ),
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
    final dateFormat = DateFormat('EEE, dd/MM');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DecoratorOrderDetailScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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

              // ✅ INFORMACIÓN PRINCIPAL
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.clientName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ✅ FECHA Y HORA
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(order.eventDate)} • ${timeFormat.format(order.eventDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ✅ DIRECCIÓN
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.eventAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ✅ COLORES SELECCIONADOS
              if (order.selectedColors.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.palette, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Colores: ${order.selectedColors.join(", ")}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // ✅ BOTÓN DE ACCIÓN SEGÚN ESTADO
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DecoratorOrderDetailScreen(order: order),
                      ),
                    );
                  },
                  icon: Icon(
                    _getActionIcon(order.status),
                    size: 18,
                  ),
                  label: Text(
                    _getActionText(order.status),
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getActionColor(order.status),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ CHIP DE FILTRO
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implementar filtrado real
        },
        selectedColor: Colors.purple[600],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ✅ TEXTO DEL ESTADO
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

  // ✅ COLOR DE FONDO DEL ESTADO
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

  // ✅ COLOR DE TEXTO DEL ESTADO
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

  // ✅ ICONO DE ACCIÓN SEGÚN ESTADO
  IconData _getActionIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return Icons.visibility;
      case OrderStatus.inProgress:
        return Icons.photo_camera;
      default:
        return Icons.arrow_forward;
    }
  }

  // ✅ TEXTO DE ACCIÓN SEGÚN ESTADO
  String _getActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return 'Ver Detalles Completados';
      case OrderStatus.inProgress:
        return 'Continuar Montaje';
      default:
        return 'Ver Detalles del Montaje';
    }
  }

  // ✅ COLOR DE ACCIÓN SEGÚN ESTADO
  Color _getActionColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return Colors.green[600]!;
      case OrderStatus.inProgress:
        return Colors.orange[600]!;
      default:
        return Colors.blue[600]!;
    }
  }
}