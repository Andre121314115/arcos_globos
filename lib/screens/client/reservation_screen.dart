import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/quote_model.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'my_orders_screen.dart';

class ReservationScreen extends StatefulWidget {
  final QuoteModel quote;

  const ReservationScreen({super.key, required this.quote});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una fecha')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final depositAmount = widget.quote.totalAmount * AppConstants.depositPercentage;

      final order = OrderModel(
        id: '',
        clientId: user.id,
        clientName: user.name,
        clientEmail: user.email,
        clientPhone: user.phone,
        templateId: widget.quote.templateId,
        templateName: widget.quote.templateName,
        templateType: widget.quote.templateType,
        selectedColors: widget.quote.selectedColors,
        width: widget.quote.width,
        height: widget.quote.height,
        quoteAmount: widget.quote.totalAmount,
        depositAmount: depositAmount,
        eventDate: _selectedDate!,
        eventAddress: _addressController.text.trim(),
        status: OrderStatus.quoted,
        createdAt: DateTime.now(),
      );

      final orderId = await _orderService.createOrder(order);
      await _orderService.reserveOrder(orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositAmount = widget.quote.totalAmount * AppConstants.depositPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Fecha'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de Cotización',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Plantilla: ${widget.quote.templateName}'),
                      Text('Colores: ${widget.quote.selectedColors.join(", ")}'),
                      Text('Medidas: ${widget.quote.width}m x ${widget.quote.height}m'),
                      const Divider(),
                      Text(
                        'Total: ${CurrencyFormatter.format(widget.quote.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Señal (30%): ${CurrencyFormatter.format(depositAmount)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección del evento',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha del evento',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'Seleccione una fecha',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createReservation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar Reserva y Pagar Señal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

