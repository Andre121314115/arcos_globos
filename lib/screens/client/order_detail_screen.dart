import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../utils/currency_formatter.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalle del Pedido',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER CON ESTADO
            _buildStatusHeader(),
            const SizedBox(height: 20),

            // ✅ INFORMACIÓN PRINCIPAL DE LA ORDEN
            _buildOrderInfoCard(),
            const SizedBox(height: 16),

            // ✅ INFORMACIÓN DEL EVENTO
            _buildEventInfoCard(),
            const SizedBox(height: 16),

            // ✅ EQUIPO ASIGNADO (SI EXISTE)
            if (order.assignedDecoratorName != null || order.assignedTeamId != null)
              _buildTeamAssignmentCard(),
            if (order.assignedDecoratorName != null || order.assignedTeamId != null)
              const SizedBox(height: 16),

            // ✅ FOTOS DEL LUGAR
            if (order.venuePhotos.isNotEmpty) _buildPhotosSection(
              title: 'Fotos del Lugar',
              photos: order.venuePhotos,
              icon: Icons.location_on,
              color: Colors.blue,
            ),

            // ✅ FOTOS DEL MONTAJE
            if (order.setupPhotos.isNotEmpty) _buildPhotosSection(
              title: 'Fotos del Montaje',
              photos: order.setupPhotos,
              icon: Icons.construction,
              color: Colors.green,
            ),

            // ✅ NOTAS ADICIONALES
            if (order.notes != null && order.notes!.isNotEmpty)
              _buildNotesCard(),
          ],
        ),
      ),
    );
  }

  // ✅ HEADER CON ESTADO DE LA ORDEN
  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getStatusGradientColor(order.status), _getStatusGradientColor(order.status).withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusGradientColor(order.status).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Orden #${order.id.substring(0, 8).toUpperCase()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ INFORMACIÓN PRINCIPAL DE LA ORDEN
  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.design_services, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Detalles del Diseño',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tipo de diseño', order.templateType, Icons.category),
            _buildInfoRow('Colores seleccionados', order.selectedColors.join(", "), Icons.palette),
            _buildInfoRow('Medidas', '${order.width}m x ${order.height}m', Icons.aspect_ratio),
            const Divider(height: 24),
            _buildInfoRow('Total cotizado', CurrencyFormatter.format(order.quoteAmount), Icons.attach_money, isAmount: true),
            _buildInfoRow('Señal pagada', CurrencyFormatter.format(order.depositAmount), Icons.payment, isAmount: true),
            if (order.quoteAmount > order.depositAmount)
              _buildInfoRow('Saldo pendiente', CurrencyFormatter.format(order.quoteAmount - order.depositAmount), Icons.pending_actions, isAmount: true),
          ],
        ),
      ),
    );
  }

  // ✅ INFORMACIÓN DEL EVENTO
  Widget _buildEventInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Información del Evento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Fecha del evento', DateFormat('EEEE, dd/MM/yyyy').format(order.eventDate), Icons.calendar_today),
            _buildInfoRow('Dirección', order.eventAddress, Icons.location_on),
            _buildInfoRow('Cliente', order.clientName, Icons.person),
            _buildInfoRow('Contacto', order.clientPhone, Icons.phone),
          ],
        ),
      ),
    );
  }

  // ✅ EQUIPO ASIGNADO
  Widget _buildTeamAssignmentCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.purple[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Equipo Asignado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (order.assignedDecoratorName != null)
              _buildInfoRow('Decorador asignado', order.assignedDecoratorName!, Icons.brush),
            if (order.assignedTeamId != null)
              _buildInfoRow('Equipo de logística', order.assignedTeamId!, Icons.local_shipping),
            if (order.transportInfo != null)
              _buildInfoRow('Información de transporte', order.transportInfo!, Icons.directions_car),
          ],
        ),
      ),
    );
  }

  // ✅ SECCIÓN DE FOTOS
  Widget _buildPhotosSection({
    required String title,
    required List<String> photos,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: photos[index],
                        width: 180,
                        height: 140,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 180,
                          height: 140,
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 180,
                          height: 140,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}/${photos.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ✅ NOTAS ADICIONALES
  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Colors.orange[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Notas Adicionales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Text(
                order.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FILA DE INFORMACIÓN
  Widget _buildInfoRow(String label, String value, IconData icon, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isAmount ? Colors.green[700] : Colors.grey[800],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
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

  // ✅ COLOR DEL GRADIENTE SEGÚN ESTADO
  Color _getStatusGradientColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.grey;
      case OrderStatus.quoted:
        return Colors.blue;
      case OrderStatus.reserved:
        return Colors.orange;
      case OrderStatus.assigned:
        return Colors.purple;
      case OrderStatus.inProgress:
        return Colors.yellow[700]!;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}