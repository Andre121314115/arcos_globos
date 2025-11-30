import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class UploadVenuePhotosScreen extends StatefulWidget {
  final OrderModel order;

  const UploadVenuePhotosScreen({super.key, required this.order});

  @override
  State<UploadVenuePhotosScreen> createState() => _UploadVenuePhotosScreenState();
}

class _UploadVenuePhotosScreenState extends State<UploadVenuePhotosScreen> {
  final OrderService _orderService = OrderService();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isUploading = false;

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imágenes: $e')),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos una imagen')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      for (final image in _selectedImages) {
        await _orderService.uploadVenuePhoto(widget.order.id, image);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotos subidas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir fotos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Fotos del Lugar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleccione fotos del lugar donde se realizará el evento para referencia',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Seleccionar Fotos'),
            ),
            const SizedBox(height: 16),
            if (_selectedImages.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadImages,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Subir Fotos'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

