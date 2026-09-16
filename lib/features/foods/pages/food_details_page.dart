import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../models/food_model.dart';

class FoodDetailsPage extends StatelessWidget {
  final FoodModel food;

  const FoodDetailsPage({
    super.key,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    final glucoseColor = _getGlycemicIndexColor(food.glycemicIndex);
    final loadColor = _getGlycemicLoadColor(food.glycemicLoad);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 160,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: food.image.isNotEmpty
                              ? Image.network(
                                  food.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.broken_image_outlined,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.fastfood_rounded,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.name,
                      style: TextStyles.pageTitle.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _infoBlock(
                      title: 'Sobre o alimento',
                      rows: [
                        _buildInfoRow('Categoria:', food.category.isNotEmpty ? food.category : 'Não informado'),
                        _buildInfoRow('Tipo de carboidrato:', food.carbohydrateType.isNotEmpty ? food.carbohydrateType : 'Não informado'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoBlock(
                      title: 'Informações nutricionais',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${food.grams.toStringAsFixed(0)}g',
                          style: TextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      rows: [
                        _buildInfoRow('Calorias:', '${food.kcal.toStringAsFixed(0)} kcal'),
                        _buildInfoRow('Carboidratos:', '${food.carbohydrates.toStringAsFixed(0)}g'),
                        _buildInfoRow('Fibra:', '${food.fiber.toStringAsFixed(0)}g'),
                        _buildInfoRow('Índice glicêmico:', food.glycemicIndex.toStringAsFixed(0)),
                        _buildInfoRow('Carga glicêmica:', food.glycemicLoad.toStringAsFixed(0)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _classificationSection(
                      title: 'Classificação do índice glicêmico',
                      value: food.glycemicIndexClassification.isNotEmpty
                          ? food.glycemicIndexClassification
                          : 'Não informado',
                      color: glucoseColor,
                    ),
                    const SizedBox(height: 8),
                    _classificationSection(
                      title: 'Classificação da carga glicêmica',
                      value: food.glycemicLoadClassification.isNotEmpty
                          ? food.glycemicLoadClassification
                          : 'Não informado',
                      color: loadColor,
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNavigation(
              currentIndex: 1,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsQuiz);
                } else if (index == 4) {
                  Navigator.pushReplacementNamed(context, AppRoutes.profile);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color: const Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyles.bodySmall.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _classificationSection({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.9), width: 1),
        color: color.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.cardTitle,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              value,
              style: TextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGlycemicIndexColor(double gi) => AppTheme.getGlycemicIndexColor(gi);

  Color _getGlycemicLoadColor(double gl) => AppTheme.getGlycemicLoadColor(gl);

  Widget _infoBlock({
    required String title,
    Widget? trailing,
    required List<Widget> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB7D7FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.cardTitle,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

