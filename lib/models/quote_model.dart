class QuoteModel {
  final String templateId;
  final String templateName;
  final String templateType;
  final List<String> selectedColors;
  final double width;
  final double height;
  final double basePrice;
  final double colorMultiplier;
  final double sizeMultiplier;
  final double totalAmount;

  QuoteModel({
    required this.templateId,
    required this.templateName,
    required this.templateType,
    required this.selectedColors,
    required this.width,
    required this.height,
    required this.basePrice,
    required this.colorMultiplier,
    required this.sizeMultiplier,
    required this.totalAmount,
  });

  factory QuoteModel.calculate({
    required String templateId,
    required String templateName,
    required String templateType,
    required double basePrice,
    required List<String> selectedColors,
    required double width,
    required double height,
  }) {
    // Multiplicador por colores (cada color adicional agrega 10%)
    final colorMultiplier = 1.0 + (selectedColors.length - 1) * 0.1;
    
    // Multiplicador por tamaño (área base: 2m x 2m = 4m²)
    final baseArea = 4.0; // 2m x 2m
    final currentArea = width * height;
    final sizeMultiplier = currentArea / baseArea;
    
    final totalAmount = basePrice * colorMultiplier * sizeMultiplier;
    
    return QuoteModel(
      templateId: templateId,
      templateName: templateName,
      templateType: templateType,
      selectedColors: selectedColors,
      width: width,
      height: height,
      basePrice: basePrice,
      colorMultiplier: colorMultiplier,
      sizeMultiplier: sizeMultiplier,
      totalAmount: totalAmount,
    );
  }
}

