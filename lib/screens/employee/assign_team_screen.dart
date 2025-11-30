import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          .get();

      setState(() {
        _decorators = snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc['name'],
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
      await _orderService.assignTeamAndTransport(
        widget.order.id,
        _teamIdController.text.trim(),
        _transportController.text.trim(),
      );

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
            content: Text('Equipo y transporte asignados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Equipo y Transporte'),
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
                      Text(
                        widget.order.templateName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Cliente: ${widget.order.clientName}'),
                      Text('Fecha: ${widget.order.eventDate.day}/${widget.order.eventDate.month}/${widget.order.eventDate.year}'),
                      Text('Dirección: ${widget.order.eventAddress}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _teamIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del Equipo',
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el ID del equipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transportController,
                decoration: const InputDecoration(
                  labelText: 'Información de Transporte',
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la información de transporte';
                  }
                  return null;
                },
              ),
              
              // ✅ DROPDOWN CORREGIDO
              const SizedBox(height: 16),
              _decorators.isNotEmpty
                  ? DropdownButtonFormField<String>(
                      value: _selectedDecoratorId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Seleccionar decorador (opcional)'),
                        ),
                        ..._decorators.map<DropdownMenuItem<String>>((decorator) {
                          return DropdownMenuItem<String>(
                            value: decorator['id'] as String,
                            child: Text(decorator['name'] as String),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDecoratorId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Decorador',
                        prefixIcon: Icon(Icons.brush),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No hay decoradores disponibles',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _assignTeam,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Asignar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}