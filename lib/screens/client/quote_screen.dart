import 'package:flutter/material.dart';
import '../../models/template_model.dart';
import '../../models/quote_model.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import 'reservation_screen.dart';

class QuoteScreen extends StatefulWidget {
  final TemplateModel template;

  const QuoteScreen({super.key, required this.template});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final List<String> _selectedColors = [];
  final _widthController = TextEditingController(text: '2.0');
  final _heightController = TextEditingController(text: '2.0');
  QuoteModel? _quote;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateQuote() {
    final width = double.tryParse(_widthController.text) ?? 2.0;
    final height = double.tryParse(_heightController.text) ?? 2.0;

    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un color')),
      );
      return;
    }

    setState(() {
      _quote = QuoteModel.calculate(
        templateId: widget.template.id,
        templateName: widget.template.name,
        templateType: widget.template.type,
        basePrice: widget.template.basePrice,
        selectedColors: _selectedColors,
        width: width,
        height: height,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      widget.template.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Precio base: ${CurrencyFormatter.format(widget.template.basePrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seleccione colores:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.availableColors.map((color) {
                final isSelected = _selectedColors.contains(color);
                return FilterChip(
                  label: Text(color),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedColors.add(color);
                      } else {
                        _selectedColors.remove(color);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Medidas (metros):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ancho',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Alto',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateQuote,
              child: const Text('Calcular Cotización'),
            ),
            if (_quote != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cotización:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Precio base: ${CurrencyFormatter.format(_quote!.basePrice)}'),
                      Text('Multiplicador colores: ${_quote!.colorMultiplier.toStringAsFixed(2)}x'),
                      Text('Multiplicador tamaño: ${_quote!.sizeMultiplier.toStringAsFixed(2)}x'),
                      const Divider(),
                      Text(
                        'Total: ${CurrencyFormatter.format(_quote!.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationScreen(quote: _quote!),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Reservar Fecha'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

