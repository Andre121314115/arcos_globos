import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'assign_team_screen.dart';

class LogisticsOrdersScreen extends StatefulWidget {
  const LogisticsOrdersScreen({super.key});

  @override
  State<LogisticsOrdersScreen> createState() => _LogisticsOrdersScreenState();
}

class _LogisticsOrdersScreenState extends State<LogisticsOrdersScreen> {
  final OrderService _orderService = OrderService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  
  // Filtro por estado
  OrderStatus? _selectedFilter;
  final List<OrderStatus> _filterOptions = [
    OrderStatus.reserved,
    OrderStatus.assigned,
    OrderStatus.inProgress,
    OrderStatus.completed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header con gradiente
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[800],
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Gestión Logística',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[800]!,
                      Colors.indigo[700]!,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.blue[800]),
                          const SizedBox(width: 8),
                          Text(
                            'Filtrar por estado:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Opción "Todos"
                          FilterChip(
                            label: const Text('Todos'),
                            selected: _selectedFilter == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = null;
                              });
                            },
                            selectedColor: Colors.blue[100],
                            checkmarkColor: Colors.blue[800],
                            labelStyle: TextStyle(
                              color: _selectedFilter == null
                                  ? Colors.blue[800]
                                  : Colors.grey[700],
                              fontWeight: _selectedFilter == null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          // Opciones de estado específicas
                          ..._filterOptions.map((status) {
                            return FilterChip(
                              label: Text(_getStatusText(status)),
                              selected: _selectedFilter == status,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilter = _selectedFilter == status
                                      ? null
                                      : status;
                                });
                              },
                              selectedColor: _getStatusColor(status),
                              checkmarkColor: Colors.blue[800],
                              labelStyle: TextStyle(
                                color: _selectedFilter == status
                                    ? Colors.blue[800]
                                    : Colors.grey[700],
                                fontWeight: _selectedFilter == status
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lista de órdenes
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: StreamBuilder<List<OrderModel>>(
              stream: _orderService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue[800],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cargando órdenes...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar órdenes',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allOrders = snapshot.data ?? [];
                
                // Filtrar órdenes para logística (reservadas, asignadas, en progreso)
                List<OrderModel> logisticsOrders = allOrders.where((order) {
                  return order.status == OrderStatus.reserved ||
                         order.status == OrderStatus.assigned ||
                         order.status == OrderStatus.inProgress ||
                         order.status == OrderStatus.completed;
                }).toList();

                // Aplicar filtro adicional si está seleccionado
                if (_selectedFilter != null) {
                  logisticsOrders = logisticsOrders
                      .where((order) => order.status == _selectedFilter)
                      .toList();
                }

                // Ordenar por fecha del evento (más cercana primero)
                logisticsOrders.sort((a, b) => a.eventDate.compareTo(b.eventDate));

                if (logisticsOrders.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == null
                                ? 'No hay órdenes para logística'
                                : 'No hay órdenes ${_getStatusText(_selectedFilter!).toLowerCase()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Las órdenes aparecerán aquí cuando estén listas para logística',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = logisticsOrders[index];
                      return _buildOrderCard(order, context);
                    },
                    childCount: logisticsOrders.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implementar acción para agregar nueva tarea de logística
          _showAddLogisticsTask(context);
        },
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Nueva Tarea'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, BuildContext context) {
    final isUrgent = order.eventDate.isBefore(DateTime.now().add(const Duration(days: 2)));
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showOrderDetails(context, order);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUrgent ? Colors.orange.shade200 : Colors.transparent,
              width: isUrgent ? 2 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      order.templateName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: Colors.orange.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'URGENTE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Estado con chip
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        _getStatusText(order.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusTextColor(order.status),
                        ),
                      ),
                      backgroundColor: _getStatusColor(order.status),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                    ),
                  ],
                ),
              ),
              
              // Información del cliente y evento
              _buildInfoRow(Icons.person, order.clientName),
              _buildInfoRow(
                Icons.event,
                '${_dateFormat.format(order.eventDate)}',
              ),
              
              if (order.eventAddress.isNotEmpty)
                _buildInfoRow(Icons.location_on, order.eventAddress),
              
              if (order.assignedTeamId != null)
                _buildInfoRow(Icons.group, 'Equipo: ${order.assignedTeamId}'),
              
              if (order.transportInfo != null && order.transportInfo!.isNotEmpty)
                _buildInfoRow(Icons.local_shipping, '${order.transportInfo}'),
              
              // Acciones (SOLO para ciertos estados)
              const SizedBox(height: 12),
              _buildActionButtons(order, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, BuildContext context) {
    if (order.status == OrderStatus.reserved || order.status == OrderStatus.assigned) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignTeamScreen(order: order),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_ind, size: 18),
              label: const Text('Asignar Equipo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[800],
                side: BorderSide(color: Colors.blue[800]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogisticsActions(context, order);
              },
              icon: const Icon(Icons.more_vert, size: 18),
              label: const Text('Acciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    } else if (order.status == OrderStatus.inProgress) {
      // Solo acciones para órdenes en progreso
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _showLogisticsActions(context, order);
          },
          icon: const Icon(Icons.track_changes, size: 18),
          label: const Text('Seguimiento Envío'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    } else if (order.status == OrderStatus.completed) {
      // Órdenes completadas - solo ver detalles
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            _showOrderDetails(context, order);
          },
          icon: const Icon(Icons.visibility, size: 18),
          label: const Text('Ver Detalles'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green[800],
            side: BorderSide(color: Colors.green[800]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    } else {
      // Para otros estados (no debería ocurrir)
      return const SizedBox.shrink();
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Detalles de la Orden',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Plantilla:', order.templateName),
                _buildDetailItem('Cliente:', order.clientName),
                _buildDetailItem('Estado:', _getStatusText(order.status)),
                _buildDetailItem('Fecha del Evento:', 
                    _dateFormat.format(order.eventDate)),
                _buildDetailItem('Dirección:', order.eventAddress),
                if (order.assignedTeamId != null)
                  _buildDetailItem('Equipo Asignado:', order.assignedTeamId!),
                if (order.transportInfo != null)
                  _buildDetailItem('Información de Transporte:', 
                      order.transportInfo!),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _buildDetailItem('Notas:', order.notes!),
                const SizedBox(height: 24),
                
                // Mostrar botón adecuado según estado
                if (order.status == OrderStatus.reserved || order.status == OrderStatus.assigned)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignTeamScreen(order: order),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Asignar Equipo y Transporte'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[800],
                        side: BorderSide(color: Colors.blue[800]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogisticsActions(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Acciones de Logística',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  Icons.local_shipping,
                  'Actualizar Transporte',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    _updateTransportInfo(context, order);
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.check_circle,
                  'Marcar como Enviado',
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    _markAsShipped(context, order);
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.directions_car,
                  'Generar Ruta',
                  Colors.purple,
                  () {
                    Navigator.pop(context);
                    _generateRoute(context, order);
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.description,
                  'Generar Documentos',
                  Colors.orange,
                  () {
                    Navigator.pop(context);
                    _generateDocuments(context, order);
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String text,
      MaterialColor color, VoidCallback onPressed) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color.shade700),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onPressed,
    );
  }

  void _updateTransportInfo(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar Transporte'),
          content: const Text('Esta funcionalidad está en desarrollo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _markAsShipped(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Marcar como Enviado'),
          content: const Text('Esta funcionalidad está en desarrollo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _generateRoute(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generar Ruta'),
          content: const Text('Esta funcionalidad está en desarrollo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _generateDocuments(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generar Documentos'),
          content: const Text('Esta funcionalidad está en desarrollo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddLogisticsTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Tarea de Logística'),
          content: const Text('Esta funcionalidad está en desarrollo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
        return Colors.orange.shade100;
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
        return Colors.orange.shade800;
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