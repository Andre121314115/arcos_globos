// lib/screens/employee/inventory_screen.dart
import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      name: 'Globos Estándar (paq. 100)',
      category: 'Material Básico',
      quantity: 45,
      minQuantity: 10,
      unit: 'paquetes',
      location: 'Almacén A',
    ),
    InventoryItem(
      name: 'Globos Metálicos (paq. 50)',
      category: 'Material Premium',
      quantity: 22,
      minQuantity: 5,
      unit: 'paquetes',
      location: 'Almacén B',
    ),
    InventoryItem(
      name: 'Cintas Decorativas',
      category: 'Complementos',
      quantity: 120,
      minQuantity: 30,
      unit: 'rollos',
      location: 'Almacén C',
    ),
    InventoryItem(
      name: 'Bases para Arcos',
      category: 'Estructuras',
      quantity: 15,
      minQuantity: 5,
      unit: 'unidades',
      location: 'Almacén Principal',
    ),
    InventoryItem(
      name: 'Bombas de Helio',
      category: 'Herramientas',
      quantity: 8,
      minQuantity: 3,
      unit: 'unidades',
      location: 'Sala Técnica',
    ),
    InventoryItem(
      name: 'Cilindros de Helio',
      category: 'Insumos',
      quantity: 12,
      minQuantity: 4,
      unit: 'cilindros',
      location: 'Almacén Seguro',
    ),
    InventoryItem(
      name: 'Cajas de Empaque',
      category: 'Embalaje',
      quantity: 200,
      minQuantity: 50,
      unit: 'unidades',
      location: 'Almacén D',
    ),
    InventoryItem(
      name: 'Tarjetas Personalizadas',
      category: 'Complementos',
      quantity: 350,
      minQuantity: 100,
      unit: 'unidades',
      location: 'Almacén A',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header
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
                'Inventario Logística',
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

          // Resumen del inventario
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            'Total Items',
                            _inventoryItems.length.toString(),
                            Icons.inventory,
                            Colors.blue,
                          ),
                          _buildSummaryItem(
                            'Bajo Stock',
                            _getLowStockCount().toString(),
                            Icons.warning,
                            Colors.orange,
                          ),
                          _buildSummaryItem(
                            'Categorías',
                            '5',
                            Icons.category,
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _getInventoryLevel(),
                        backgroundColor: Colors.grey[200],
                        color: _getInventoryLevel() < 0.3
                            ? Colors.orange
                            : Colors.green,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nivel de Inventario',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(_getInventoryLevel() * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lista de inventario
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _inventoryItems[index];
                  final isLowStock = item.quantity <= item.minQuantity;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLowStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.orange.shade200),
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
                                        'BAJO STOCK',
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
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cantidad Actual',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} ${item.unit}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mínimo Requerido',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${item.minQuantity} ${item.unit}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLowStock
                                          ? Colors.orange.shade100
                                          : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isLowStock ? 'Bajo' : 'Normal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isLowStock
                                            ? Colors.orange.shade800
                                            : Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showUpdateQuantityDialog(context, item);
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Ajustar'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue[800],
                                    side: BorderSide(color: Colors.blue[800]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showItemDetails(context, item);
                                  },
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('Detalles'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _inventoryItems.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddItemDialog(context);
        },
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Item'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _getLowStockCount() {
    return _inventoryItems.where((item) => item.quantity <= item.minQuantity).length;
  }

  double _getInventoryLevel() {
    final totalItems = _inventoryItems.length;
    final lowStockItems = _getLowStockCount();
    return (totalItems - lowStockItems) / totalItems;
  }

  void _showUpdateQuantityDialog(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajustar Cantidad'),
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

  void _showItemDetails(BuildContext context, InventoryItem item) {
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
                  'Detalles del Item',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Nombre:', item.name),
                _buildDetailItem('Categoría:', item.category),
                _buildDetailItem('Ubicación:', item.location),
                _buildDetailItem('Cantidad Actual:', '${item.quantity} ${item.unit}'),
                _buildDetailItem('Mínimo Requerido:', '${item.minQuantity} ${item.unit}'),
                _buildDetailItem('Estado:', 
                    item.quantity <= item.minQuantity ? 'Bajo Stock' : 'Stock Normal'),
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

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Item'),
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
}

class InventoryItem {
  final String name;
  final String category;
  final int quantity;
  final int minQuantity;
  final String unit;
  final String location;

  InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.location,
  });
}