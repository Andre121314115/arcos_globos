import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class AssignTeamScreen extends StatefulWidget {
  final OrderModel order;

  const AssignTeamScreen({super.key, required this.order});

  @override
  State<AssignTeamScreen> createState() => _AssignTeamScreenState();
}

class _AssignTeamScreenState extends State<AssignTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamIdController = TextEditingController();
  final _transportController = TextEditingController();
  String? _selectedDecoratorId;
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _decorators = [];

  @override
  void initState() {
    super.initState();
    _loadDecorators();
  }

  @override
  void dispose() {
    _teamIdController.dispose();
    _transportController.dispose();
    super.dispose();
  }

  Future<void> _loadDecorators() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'decorator')
          .where('isActive', isEqualTo: true) // ✅ SOLO USUARIOS ACTIVOS
          .get();

      setState(() {
        _decorators = snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc['name'],
            "email": doc['email'],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error cargando decoradores: $e');
    }
  }

  Future<void> _assignTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ ASIGNAR EQUIPO Y TRANSPORTE
      await _orderService.assignTeamAndTransport(
        widget.order.id,
        _teamIdController.text.trim(),
        _transportController.text.trim(),
      );

      // ✅ ASIGNAR DECORADOR SI SE SELECCIONÓ
      if (_selectedDecoratorId != null && _selectedDecoratorId!.isNotEmpty) {
        final decorator = _decorators.firstWhere(
          (d) => d['id'] == _selectedDecoratorId,
        );

        await _orderService.assignDecorator(
          widget.order.id,
          decorator['id'] as String,
          decorator['name'] as String,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Equipo y decorador asignados exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Asignar Recursos',
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
                      Icons.assignment_ind,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Asignación de Recursos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Asigna equipo, transporte y decorador para esta orden',
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

              // ✅ INFORMACIÓN DE LA ORDEN MEJORADA
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
                          Icon(
                            Icons.event_note,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Información de la Orden',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildOrderInfo('Diseño', widget.order.templateName, Icons.design_services),
                      _buildOrderInfo('Cliente', widget.order.clientName, Icons.person),
                      _buildOrderInfo('Fecha', DateFormat('EEEE, dd/MM/yyyy').format(widget.order.eventDate), Icons.calendar_today),
                      _buildOrderInfo('Dirección', widget.order.eventAddress, Icons.location_on),
                      if (widget.order.selectedColors.isNotEmpty)
                        _buildOrderInfo('Colores', widget.order.selectedColors.join(", "), Icons.palette),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ FORMULARIO DE ASIGNACIÓN
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
                          Icon(
                            Icons.group_work,
                            color: Colors.green[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Recursos a Asignar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // CAMPO ID DEL EQUIPO
                      _buildTextField(
                        controller: _teamIdController,
                        label: 'ID del Equipo',
                        icon: Icons.group,
                        hintText: 'Ej: EQ-001, Team-A, etc.',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el ID del equipo';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // CAMPO INFORMACIÓN DE TRANSPORTE
                      TextFormField(
                        controller: _transportController,
                        decoration: InputDecoration(
                          labelText: 'Información de Transporte',
                          labelStyle: TextStyle(color: Colors.grey[700]),
                          prefixIcon: Icon(Icons.local_shipping, color: Colors.blue[700]),
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
                          hintText: 'Ej: Camión grande, Vehículo ABC-123, etc.',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la información de transporte';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ✅ DROPDOWN DE DECORADORES MEJORADO
                      _decorators.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Decorador Asignado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedDecoratorId,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: '',
                                      child: Text(
                                        'Seleccionar decorador (opcional)',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    ..._decorators.map<DropdownMenuItem<String>>((decorator) {
                                      return DropdownMenuItem<String>(
                                        value: decorator['id'] as String,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              decorator['name'] as String,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              decorator['email'] as String? ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedDecoratorId = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Decorador',
                                    prefixIcon: Icon(Icons.brush, color: Colors.purple[700]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  isExpanded: true,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '💡 Puedes dejar este campo vacío si no hay decorador disponible',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No hay decoradores disponibles en este momento',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ BOTÓN DE ASIGNACIÓN MEJORADO
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
                      '📋 La orden se actualizará y el cliente será notificado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _assignTeam,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.assignment_turned_in, size: 24),
                        label: _isLoading
                            ? const Text(
                                'Asignando...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            : const Text(
                                'Confirmar Asignación',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading ? Colors.grey : Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
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

  // ✅ CAMPO DE TEXTO MEJORADO
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
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
        hintText: hintText,
      ),
      validator: validator,
    );
  }

  // ✅ INFORMACIÓN DE ORDEN MEJORADA
  Widget _buildOrderInfo(String label, String value, IconData icon) {
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
              '$label:',
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
}