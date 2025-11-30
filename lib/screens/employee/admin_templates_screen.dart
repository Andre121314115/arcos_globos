import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/template_model.dart';
import '../../models/user_model.dart';
import '../../services/template_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/currency_formatter.dart';
import 'edit_template_screen.dart';

class AdminTemplatesScreen extends StatelessWidget {
  const AdminTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }
    
    // Permitir acceso si es admin o tiene acceso completo
    if (user.role != UserRole.admin && !user.hasFullAccess) {
      return const Scaffold(
        body: Center(child: Text('Acceso no autorizado')),
      );
    }

    final templateService = TemplateService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Plantillas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditTemplateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TemplateModel>>(
        stream: templateService.getTemplates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final templates = snapshot.data ?? [];

          if (templates.isEmpty) {
            return const Center(
              child: Text('No hay plantillas disponibles'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (template.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: template.imageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 50),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(template.description),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(template.type.toUpperCase()),
                                  backgroundColor: Colors.purple[100],
                                ),
                                const Spacer(),
                                Text(
                                  CurrencyFormatter.format(template.basePrice),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditTemplateScreen(template: template),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Plantilla'),
                              content: const Text(
                                  '¿Está seguro de eliminar esta plantilla?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await templateService.deleteTemplate(template.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Plantilla eliminada'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

