import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/currency_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final OrderService _orderService = OrderService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderService.getOrdersByDateRange(_startDate, _endDate);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar reportes: $e')),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _loadReports();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _loadReports();
    }
  }

  Map<String, dynamic> _calculateStatistics() {
    final totalOrders = _orders.length;
    final completedOrders = _orders.where((o) => o.status == OrderStatus.completed).length;
    final reservedOrders = _orders.where((o) => o.status == OrderStatus.reserved).length;
    final assignedOrders = _orders.where((o) => o.status == OrderStatus.assigned).length;
    final totalRevenue = _orders.fold<double>(0.0, (sum, order) => sum + order.quoteAmount);
    final totalDeposits = _orders.fold<double>(0.0, (sum, order) => sum + order.depositAmount);
    
    // Ocupación por día
    final Map<DateTime, int> occupancyByDate = {};
    for (final order in _orders) {
      final date = DateTime(
        order.eventDate.year,
        order.eventDate.month,
        order.eventDate.day,
      );
      occupancyByDate[date] = (occupancyByDate[date] ?? 0) + 1;
    }
    
    // Rutas agrupadas por equipo
    final Map<String, List<OrderModel>> routesByTeam = {};
    for (final order in _orders.where((o) => o.assignedTeamId != null)) {
      final teamId = order.assignedTeamId!;
      if (!routesByTeam.containsKey(teamId)) {
        routesByTeam[teamId] = [];
      }
      routesByTeam[teamId]!.add(order);
    }

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'reservedOrders': reservedOrders,
      'assignedOrders': assignedOrders,
      'totalRevenue': totalRevenue,
      'totalDeposits': totalDeposits,
      'occupancyByDate': occupancyByDate,
      'routesByTeam': routesByTeam,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Ocupación y Rutas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selector de fechas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _selectStartDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Fecha Inicio',
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(_startDate),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectEndDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Fecha Fin',
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(_endDate),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Estadísticas generales
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estadísticas Generales',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow('Total de Órdenes', '${stats['totalOrders']}'),
                          _buildStatRow('Completadas', '${stats['completedOrders']}'),
                          _buildStatRow('Reservadas', '${stats['reservedOrders']}'),
                          _buildStatRow('Asignadas', '${stats['assignedOrders']}'),
                          const Divider(),
                          _buildStatRow(
                            'Ingresos Totales',
                            CurrencyFormatter.format(stats['totalRevenue'] as double),
                            isHighlight: true,
                          ),
                          _buildStatRow(
                            'Señales Recibidas',
                            CurrencyFormatter.format(stats['totalDeposits'] as double),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ocupación por fecha
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ocupación por Fecha',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if ((stats['occupancyByDate'] as Map).isEmpty)
                            const Text('No hay datos de ocupación')
                          else
                            ...() {
                              final entries = (stats['occupancyByDate'] as Map<DateTime, int>)
                                  .entries
                                  .toList();
                              entries.sort((a, b) => a.key.compareTo(b.key));
                              return entries.map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(entry.key),
                                        ),
                                        Chip(
                                          label: Text('${entry.value} montajes'),
                                          backgroundColor: entry.value > 3
                                              ? Colors.red[100]
                                              : entry.value > 1
                                                  ? Colors.orange[100]
                                                  : Colors.green[100],
                                        ),
                                      ],
                                    ),
                                  )).toList();
                            }(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rutas por equipo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rutas por Equipo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if ((stats['routesByTeam'] as Map).isEmpty)
                            const Text('No hay rutas asignadas')
                          else
                            ...(stats['routesByTeam'] as Map<String, List<OrderModel>>)
                                .entries
                                .map((entry) => ExpansionTile(
                                      title: Text('Equipo: ${entry.key}'),
                                      subtitle: Text(
                                        '${entry.value.length} montaje(s)',
                                      ),
                                      children: entry.value.map((order) {
                                        return ListTile(
                                          title: Text(order.templateName),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm')
                                                    .format(order.eventDate),
                                              ),
                                              Text(order.eventAddress),
                                              if (order.transportInfo != null)
                                                Text(
                                                  'Transporte: ${order.transportInfo}',
                                                  style: TextStyle(
                                                    color: Colors.blue[700],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ))
                                .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.purple : null,
            ),
          ),
        ],
      ),
    );
  }
}

