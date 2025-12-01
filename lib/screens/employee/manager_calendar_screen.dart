import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class ManagerCalendarScreen extends StatefulWidget {
  const ManagerCalendarScreen({super.key});

  @override
  State<ManagerCalendarScreen> createState() => _ManagerCalendarScreenState();
}

class _ManagerCalendarScreenState extends State<ManagerCalendarScreen> {
  final OrderService _orderService = OrderService();
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<OrderModel>> _ordersByDate = {};
  
  // Filtros
  OrderStatus? _selectedStatusFilter;
  bool _showUrgentOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('es_PE', null);
    } catch (e) {
      try {
        await initializeDateFormatting('es', null);
      } catch (e2) {
        debugPrint('Error inicializando locale en calendario: $e2');
      }
    }
  }

  Future<void> _loadOrders() async {
    try {
      // Usamos el método original que estaba funcionando
      final orders = await _orderService.getOrdersByDateRange(
        DateTime(_focusedDay.year, _focusedDay.month, 1),
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
      );
      
      final Map<DateTime, List<OrderModel>> grouped = {};
      for (final order in orders) {
        // Filtrar por estado si está seleccionado
        if (_selectedStatusFilter != null && order.status != _selectedStatusFilter) {
          continue;
        }
        
        // Filtrar por urgente si está activado
        if (_showUrgentOnly) {
          final isUrgent = order.eventDate.isBefore(
            DateTime.now().add(const Duration(days: 2))
          );
          if (!isUrgent) continue;
        }
        
        final date = DateTime(
          order.eventDate.year,
          order.eventDate.month,
          order.eventDate.day,
        );
        
        if (grouped.containsKey(date)) {
          grouped[date]!.add(order);
        } else {
          grouped[date] = [order];
        }
      }
      
      if (mounted) {
        setState(() {
          _ordersByDate = grouped;
        });
      }
    } catch (e) {
      debugPrint('Error cargando órdenes para calendario: $e');
    }
  }

  List<OrderModel> _getOrdersForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _ordersByDate[date] ?? [];
  }

  int _getEventCount(DateTime day) {
    return _getOrdersForDay(day).length;
  }

  Widget _buildEventMarker(DateTime day, List<OrderModel> events) {
    final eventCount = events.length;
    final hasUrgent = events.any((order) => 
      order.eventDate.isBefore(DateTime.now().add(const Duration(days: 2)))
    );
    
    return Positioned(
      bottom: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: hasUrgent ? Colors.orange.shade100 : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasUrgent ? Colors.orange.shade300 : Colors.blue.shade300,
            width: 1,
          ),
        ),
        child: Text(
          '$eventCount',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: hasUrgent ? Colors.orange.shade800 : Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOrders = _getOrdersForDay(_selectedDay);
    
    // Ordenar por hora del evento
    selectedOrders.sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header con gradiente
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[800]!,
                  Colors.indigo[700]!,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendario de Montajes',
                    style: TextStyle(
                      fontSize: 24,
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
                  const SizedBox(height: 8),
                  Text(
                    _dateFormat.format(_selectedDay),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filtros
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      const Text(
                        'Filtros:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.blue[800],
                        onPressed: _loadOrders,
                        tooltip: 'Refrescar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<OrderStatus?>(
                          value: _selectedStatusFilter,
                          decoration: InputDecoration(
                            labelText: 'Filtrar por estado',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todos los estados'),
                            ),
                            ...OrderStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_getStatusText(status)),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusFilter = value;
                            });
                            _loadOrders();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Urgentes'),
                        selected: _showUrgentOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showUrgentOnly = selected;
                          });
                          _loadOrders();
                        },
                        selectedColor: Colors.orange.shade100,
                        checkmarkColor: Colors.orange.shade800,
                        labelStyle: TextStyle(
                          color: _showUrgentOnly
                              ? Colors.orange.shade800
                              : Colors.grey[700],
                          fontWeight: _showUrgentOnly
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Calendario
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TableCalendar<OrderModel>(
                        firstDay: DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        eventLoader: _getOrdersForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          todayTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          selectedTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue[800],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          weekendTextStyle: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                          outsideDaysVisible: false,
                          cellMargin: const EdgeInsets.all(2),
                          cellPadding: const EdgeInsets.all(4),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          formatButtonTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          titleTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.blue[800],
                            size: 24,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.blue[800],
                            size: 24,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          weekendStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return const SizedBox.shrink();
                            return _buildEventMarker(date, events);
                          },
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                          _loadOrders();
                        },
                      ),
                    ),
                  ),

                  // Lista de eventos del día seleccionado
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              color: Colors.blue[800],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Eventos del ${_dateFormat.format(_selectedDay)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${selectedOrders.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        if (selectedOrders.isEmpty)
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay montajes programados',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Seleccione otra fecha en el calendario',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...selectedOrders.map((order) {
                            final isUrgent = order.eventDate.isBefore(
                              DateTime.now().add(const Duration(days: 2))
                            );
                            
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isUrgent 
                                      ? Colors.orange.shade200 
                                      : Colors.transparent,
                                  width: isUrgent ? 2 : 0,
                                ),
                              ),
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isUrgent)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.orange.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.warning,
                                                  size: 12,
                                                  color: Colors.orange.shade800,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'URGENTE',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange.shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order.status),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getStatusText(order.status),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getStatusTextColor(order.status),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _timeFormat.format(order.eventDate),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(Icons.person, order.clientName),
                                    if (order.eventAddress.isNotEmpty)
                                      _buildInfoRow(Icons.location_on, order.eventAddress),
                                    if (order.assignedDecoratorName != null)
                                      _buildInfoRow(Icons.brush, 'Decorador: ${order.assignedDecoratorName}'),
                                    if (order.assignedTeamId != null)
                                      _buildInfoRow(Icons.group, 'Equipo: ${order.assignedTeamId}'),
                                    const SizedBox(height: 12),
                                    
                                    // Acciones para GESTOR (solo ver, no asignar)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _showEventDetails(context, order);
                                        },
                                        icon: const Icon(Icons.visibility, size: 18),
                                        label: const Text('Ver Detalles Completos'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCalendarActions(context);
        },
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.more_vert),
        label: const Text('Acciones'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      )
    );
  }

  void _showEventDetails(BuildContext context, OrderModel order) {
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
                  'Detalles del Evento',
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
                _buildDetailItem('Fecha:', _dateFormat.format(order.eventDate)),
                _buildDetailItem('Hora:', _timeFormat.format(order.eventDate)),
                _buildDetailItem('Dirección:', order.eventAddress),
                if (order.assignedDecoratorName != null)
                  _buildDetailItem('Decorador Asignado:', order.assignedDecoratorName!),
                if (order.assignedTeamId != null)
                  _buildDetailItem('Equipo Asignado:', order.assignedTeamId!),
                if (order.transportInfo != null)
                  _buildDetailItem('Transporte:', order.transportInfo!),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _buildDetailItem('Notas:', order.notes!),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
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

  void _showCalendarActions(BuildContext context) {
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
                  'Acciones del Calendario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  Icons.download,
                  'Exportar Calendario',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    _exportCalendar(context);
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.print,
                  'Imprimir Vista',
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    _printCalendarView(context);
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.notifications,
                  'Ver Recordatorios',
                  Colors.orange,
                  () {
                    Navigator.pop(context);
                    _showReminders(context);
                  },
                ),
                _buildActionButton(
                  context,
                  Icons.analytics,
                  'Ver Estadísticas',
                  Colors.purple,
                  () {
                    Navigator.pop(context);
                    _showStatistics(context);
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

  void _exportCalendar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar Calendario'),
          content: const Text('Exportar vista actual del calendario.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calendario exportado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Exportar'),
            ),
          ],
        );
      },
    );
  }

  void _printCalendarView(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Imprimir Vista'),
          content: const Text('Generar versión imprimible del calendario.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vista lista para imprimir'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Generar'),
            ),
          ],
        );
      },
    );
  }

  void _showReminders(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recordatorios'),
          content: const Text('Ver recordatorios programados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showStatistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Estadísticas'),
          content: const Text('Ver estadísticas de montajes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
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