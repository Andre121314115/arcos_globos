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
  DateTime _endDate = DateTime.now();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  
  // Tipos de reporte
  String _selectedReportType = 'general';
  final List<String> _reportTypes = [
    'general',
    'ocupacion',
    'financiero',
    'equipos'
  ];

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
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar reportes: $e'),
            backgroundColor: Colors.red,
          ),
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
    if (picked != null && mounted) {
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
    if (picked != null && mounted) {
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
    final inProgressOrders = _orders.where((o) => o.status == OrderStatus.inProgress).length;
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

    // Estadísticas por estado
    final statusStats = Map<OrderStatus, int>.fromIterable(
      OrderStatus.values,
      key: (status) => status,
      value: (status) => _orders.where((o) => o.status == status).length,
    );

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'reservedOrders': reservedOrders,
      'assignedOrders': assignedOrders,
      'inProgressOrders': inProgressOrders,
      'totalRevenue': totalRevenue,
      'totalDeposits': totalDeposits,
      'pendingRevenue': totalRevenue - totalDeposits,
      'occupancyByDate': occupancyByDate,
      'routesByTeam': routesByTeam,
      'statusStats': statusStats,
    };
  }

  List<Map<String, dynamic>> _getStatusChartData(Map<OrderStatus, int> statusStats) {
    return statusStats.entries.map((entry) {
      String label;
      Color color;
      
      switch (entry.key) {
        case OrderStatus.pending:
          label = 'Pendiente';
          color = Colors.grey;
          break;
        case OrderStatus.quoted:
          label = 'Cotizado';
          color = Colors.blue;
          break;
        case OrderStatus.reserved:
          label = 'Reservado';
          color = Colors.orange;
          break;
        case OrderStatus.assigned:
          label = 'Asignado';
          color = Colors.purple;
          break;
        case OrderStatus.inProgress:
          label = 'En Progreso';
          color = Colors.yellow.shade700!;
          break;
        case OrderStatus.completed:
          label = 'Completado';
          color = Colors.green;
          break;
        case OrderStatus.cancelled:
          label = 'Cancelado';
          color = Colors.red;
          break;
      }
      
      return {
        'label': label,
        'value': entry.value.toDouble(),
        'color': color,
        'count': entry.value,
      };
    }).where((data) => (data['value'] as double) > 0).toList(); // CORRECCIÓN AQUÍ
  }

  List<Map<String, dynamic>> _getRevenueChartData() {
    final Map<String, double> monthlyRevenue = {};
    
    for (final order in _orders) {
      final monthKey = DateFormat('MMM yyyy').format(order.eventDate);
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + order.quoteAmount;
    }
    
    return monthlyRevenue.entries
        .map((entry) => {
          'label': entry.key,
          'value': entry.value,
          'color': Colors.blue,
        })
        .toList();
  }

  // Método auxiliar para formatear moneda de forma compacta
  String _formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return 'S/ ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'S/ ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return CurrencyFormatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();
    final statusChartData = _getStatusChartData(stats['statusStats'] as Map<OrderStatus, int>);
    final revenueChartData = _getRevenueChartData();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue[800],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generando reportes...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
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
                      'Reportes del Sistema',
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

                // Selector de fechas
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.date_range, color: Colors.blue[800]),
                              const SizedBox(width: 8),
                              Text(
                                'Rango de Fechas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateSelector(
                                  'Fecha Inicio',
                                  _startDate,
                                  _selectStartDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDateSelector(
                                  'Fecha Fin',
                                  _endDate,
                                  _selectEndDate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.refresh, color: Colors.blue[800], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Mostrando ${_orders.length} órdenes',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Selector de tipo de reporte
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _reportTypes.map((type) {
                          final isSelected = _selectedReportType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                _getReportTypeLabel(type),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedReportType = type;
                                });
                              },
                              selectedColor: Colors.blue[800],
                              checkmarkColor: Colors.white,
                              showCheckmark: true,
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Contenido del reporte seleccionado
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_selectedReportType == 'general')
                        _buildGeneralReport(stats, statusChartData),
                      if (_selectedReportType == 'ocupacion')
                        _buildOccupancyReport(stats),
                      if (_selectedReportType == 'financiero')
                        _buildFinancialReport(stats, revenueChartData),
                      if (_selectedReportType == 'equipos')
                        _buildTeamsReport(stats),
                    ]),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _exportReport(context, stats);
        },
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.download),
        label: const Text('Exportar'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.blue[800],
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralReport(Map<String, dynamic> stats, List<Map<String, dynamic>> chartData) {
    return Column(
      children: [
        // Resumen general
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Colors.blue[800]),
                    const SizedBox(width: 8),
                    Text(
                      'Resumen General',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard(
                      'Total Órdenes',
                      '${stats['totalOrders']}',
                      Icons.assignment,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Completadas',
                      '${stats['completedOrders']}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'En Progreso',
                      '${stats['inProgressOrders']}',
                      Icons.timelapse,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Reservadas',
                      '${stats['reservedOrders']}',
                      Icons.event_available,
                      Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatRow('Ingresos Totales:', 
                  CurrencyFormatter.format(stats['totalRevenue'] as double), true),
                _buildStatRow('Señales Recibidas:', 
                  CurrencyFormatter.format(stats['totalDeposits'] as double)),
                _buildStatRow('Pendiente de Cobro:', 
                  CurrencyFormatter.format(stats['pendingRevenue'] as double)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Gráfico de estados (versión simplificada sin librería)
        if (chartData.isNotEmpty)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Text(
                        'Distribución por Estado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...chartData.map((data) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: data['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(data['label'] as String),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (data['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: (data['color'] as Color).withOpacity(0.3)),
                            ),
                            child: Text(
                              '${data['count']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: data['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOccupancyReport(Map<String, dynamic> stats) {
    final occupancyByDate = stats['occupancyByDate'] as Map<DateTime, int>;
    final entries = occupancyByDate.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_day, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(
                  'Ocupación por Fecha',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Mostrando ${entries.length} días con eventos',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay eventos en este período',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...entries.map((entry) {
                final occupancyLevel = entry.value;
                Color color;
                String levelText;
                
                if (occupancyLevel >= 5) {
                  color = Colors.red.shade100!;
                  levelText = 'Máxima';
                } else if (occupancyLevel >= 3) {
                  color = Colors.orange.shade100!;
                  levelText = 'Alta';
                } else if (occupancyLevel >= 2) {
                  color = Colors.yellow.shade100!;
                  levelText = 'Media';
                } else {
                  color = Colors.green.shade100!;
                  levelText = 'Normal';
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy').format(entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nivel de ocupación: $levelText',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${entry.value} montajes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: occupancyLevel >= 5 ? Colors.red : 
                                   occupancyLevel >= 3 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialReport(Map<String, dynamic> stats, List<Map<String, dynamic>> chartData) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.blue[800]),
                    const SizedBox(width: 8),
                    Text(
                      'Reporte Financiero',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tarjetas de resumen financiero
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatCard(
                      'Ingresos Totales',
                      CurrencyFormatter.format(stats['totalRevenue'] as double),
                      Icons.money,
                      Colors.green,
                      isCurrency: true,
                    ),
                    _buildStatCard(
                      'Señales',
                      CurrencyFormatter.format(stats['totalDeposits'] as double),
                      Icons.account_balance_wallet,
                      Colors.blue,
                      isCurrency: true,
                    ),
                    _buildStatCard(
                      'Por Cobrar',
                      CurrencyFormatter.format(stats['pendingRevenue'] as double),
                      Icons.pending,
                      Colors.orange,
                      isCurrency: true,
                    ),
                    _buildStatCard(
                      'Órdenes Facturadas',
                      '${stats['completedOrders']}',
                      Icons.receipt,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Gráfico de ingresos por mes (versión simplificada)
        if (chartData.isNotEmpty)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Text(
                        'Ingresos por Mes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: chartData.map((data) {
                        final maxValue = chartData
                            .map((d) => d['value'] as double)
                            .reduce((a, b) => a > b ? a : b);
                        final height = ((data['value'] as double) / maxValue) * 150;
                        
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 30,
                              height: height,
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _formatCurrencyCompact(data['value'] as double), // CORRECCIÓN AQUÍ
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 60,
                              child: Text(
                                data['label'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamsReport(Map<String, dynamic> stats) {
    final routesByTeam = stats['routesByTeam'] as Map<String, List<OrderModel>>;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(
                  'Rutas por Equipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${routesByTeam.length} equipos con asignaciones',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            if (routesByTeam.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_off,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay equipos asignados',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...routesByTeam.entries.map((entry) {
                final teamId = entry.key;
                final orders = entry.value;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        teamId.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    title: Text(
                      'Equipo $teamId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${orders.length} montaje${orders.length != 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    children: orders.map((order) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.templateName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm').format(order.eventDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    order.eventAddress,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (order.transportInfo != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '🚚 ${order.transportInfo!}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {bool isCurrency = false}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isCurrency ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [bool isHighlight = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green[700] : Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTypeLabel(String type) {
    switch (type) {
      case 'general':
        return 'General';
      case 'ocupacion':
        return 'Ocupación';
      case 'financiero':
        return 'Financiero';
      case 'equipos':
        return 'Equipos';
      default:
        return type;
    }
  }

  void _exportReport(BuildContext context, Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar Reporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleccione el formato de exportación:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF'),
                subtitle: const Text('Documento imprimible'),
                onTap: () {
                  Navigator.pop(context);
                  _showExportSuccess(context, 'PDF');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Excel'),
                subtitle: const Text('Datos tabulares'),
                onTap: () {
                  Navigator.pop(context);
                  _showExportSuccess(context, 'Excel');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Imagen'),
                subtitle: const Text('Gráficos e imágenes'),
                onTap: () {
                  Navigator.pop(context);
                  _showExportSuccess(context, 'Imagen');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showExportSuccess(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reporte exportado en formato $format'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}