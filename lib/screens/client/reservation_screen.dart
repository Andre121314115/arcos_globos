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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
        const SnackBar(
          content: Text('Seleccione una fecha para el evento'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
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
            content: Text('🎉 ¡Reserva creada exitosamente!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
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
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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
    final remainingAmount = widget.quote.totalAmount - depositAmount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Confirmar Reserva',
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER INFORMATIVO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[800]!, Colors.purple[700]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Último Paso',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confirma los detalles y completa tu reserva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ RESUMEN DE COTIZACIÓN MEJORADO
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.purple[700], size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Resumen de tu Cotización',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryItem('Plantilla', widget.quote.templateName, Icons.design_services),
                      _buildSummaryItem('Colores', widget.quote.selectedColors.join(", "), Icons.palette),
                      _buildSummaryItem('Medidas', '${widget.quote.width}m × ${widget.quote.height}m', Icons.aspect_ratio),
                      const Divider(height: 24),
                      _buildAmountItem('Total cotizado', widget.quote.totalAmount, Colors.grey[800]!),
                      _buildAmountItem('Señal (${(AppConstants.depositPercentage * 100).toInt()}%)', depositAmount, Colors.purple[700]!),
                      _buildAmountItem('Saldo pendiente', remainingAmount, Colors.green[700]!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ FORMULARIO DE RESERVA
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event, color: Colors.blue[700], size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Detalles del Evento',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // CAMPO DIRECCIÓN
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Dirección del evento',
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          prefixIcon: Icon(Icons.location_on, color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ingresa la dirección completa del evento...',
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la dirección del evento';
                          }
                          if (value.length < 10) {
                            return 'La dirección parece muy corta';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // SELECTOR DE FECHA MEJORADO
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedDate != null ? Colors.green[400]! : Colors.grey[400]!,
                              width: _selectedDate != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _selectedDate != null ? Colors.green[600] : Colors.grey[600],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fecha del evento',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedDate != null
                                          ? DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!)
                                          : 'Selecciona una fecha',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedDate != null ? Colors.green[800] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '✅ Fecha seleccionada',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ BOTÓN DE CONFIRMACIÓN MEJORADO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      '📋 Tu pedido estará listo en "Mis Pedidos"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createReservation,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.event_available, size: 24),
                        label: _isLoading
                            ? const Text(
                                'Procesando...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'Confirmar Reserva - ${CurrencyFormatter.format(depositAmount)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading ? Colors.grey : Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pagas la señal ahora, el saldo se paga el día del evento',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ITEM DE RESUMEN
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ITEM DE MONTO
  Widget _buildAmountItem(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}