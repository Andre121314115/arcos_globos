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
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<OrderModel>> _ordersByDate = {};

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _loadOrders();
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
    final orders = await _orderService.getOrdersByDateRange(
      DateTime(_focusedDay.year, _focusedDay.month, 1),
      DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
    );

    final Map<DateTime, List<OrderModel>> grouped = {};
    for (final order in orders) {
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

    setState(() {
      _ordersByDate = grouped;
    });
  }

  List<OrderModel> _getOrdersForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _ordersByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedOrders = _getOrdersForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Montajes'),
      ),
      body: Column(
        children: [
          TableCalendar<OrderModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getOrdersForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
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
              _focusedDay = focusedDay;
              _loadOrders();
            },
          ),
          Expanded(
            child: selectedOrders.isEmpty
                ? const Center(
                    child: Text('No hay montajes programados para este día'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedOrders.length,
                    itemBuilder: (context, index) {
                      final order = selectedOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(order.templateName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cliente: ${order.clientName}'),
                              Text('Dirección: ${order.eventAddress}'),
                              if (order.assignedDecoratorName != null)
                                Text('Decorador: ${order.assignedDecoratorName}'),
                              if (order.assignedTeamId != null)
                                Text('Equipo: ${order.assignedTeamId}'),
                            ],
                          ),
                          trailing: Text(
                            DateFormat('HH:mm').format(order.eventDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

