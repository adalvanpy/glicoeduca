import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../progress/repositories/user_progress_repository.dart';
import '../controller/food_controller.dart';
import '../models/food_model.dart';
import '../repositories/food_repository.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late final FoodController _controller;
  String _selectedCarbohydrateType = 'Todos';
  String _selectedIgClassification = 'Todos';
  String _selectedCgClassification = 'Todos';
  bool _isLoading = true;

  final List<String> _carbohydrateTypes = ['Todos', 'Simples', 'Complexos'];
  final List<String> _igClassifications = ['Todos', 'Baixo', 'Moderado', 'Alto'];
  final List<String> _cgClassifications = ['Todos', 'Baixa', 'Moderada', 'Alta'];

  bool _hasSavedProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    _buildFoodList(),
                  ],
                ),
              ),
            ),
            AppBottomNavigation(
              currentIndex: 0,
              onItemSelected: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, AppRoutes.instructionsQuiz);
                    break;
                  case 4:
                    Navigator.pushReplacementNamed(context, AppRoutes.profile);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = FoodController(repository: FoodRepository());
    _controller.addListener(_refresh);
    _loadData();
    _saveProgressIfNeeded();
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildFilterSection(
          title: 'Tipo de carboidrato',
          options: _carbohydrateTypes,
          selected: _selectedCarbohydrateType,
          onChanged: (value) {
            final nextValue = value ?? 'Todos';
            setState(() {
              _selectedCarbohydrateType = nextValue;
            });
            _filterFoods();
          },
        ),
        const SizedBox(height: 16),

        _buildFilterSection(
          title: 'Índice glicêmico',
          options: _igClassifications,
          selected: _selectedIgClassification,
          onChanged: (value) {
            final nextValue = value ?? 'Todos';
            setState(() {
              _selectedIgClassification = nextValue;
            });
            _filterFoods();
          },
        ),
        const SizedBox(height: 16),

        _buildFilterSection(
          title: 'Carga glicêmica',
          options: _cgClassifications,
          selected: _selectedCgClassification,
          onChanged: (value) {
            final nextValue = value ?? 'Todos';
            setState(() {
              _selectedCgClassification = nextValue;
            });
            _filterFoods();
          },
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.cardTitle,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () {
                onChanged(isSelected ? null : option);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE7F7EC) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6ECF7A) : const Color(0xFFBFE7C5),
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyles.cardBodyText.copyWith(
                    fontSize: 12,
                    color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF374151),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_controller.foods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Nenhum alimento encontrado.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ..._controller.foods.map((food) => _foodCard(food)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Alimentos',
          style: TextStyles.pageTitle,
        ),
        const SizedBox(height: 4),
        const Text(
          'Entendendo as composições dos alimentos',
          style: TextStyles.description,
        ),
      ],
    );
  }

  Future<void> _filterFoods() async {
    setState(() => _isLoading = true);

    final carbohydrateType = _selectedCarbohydrateType == 'Todos'
        ? null
        : _selectedCarbohydrateType.trim();
    final ig =
        _selectedIgClassification == 'Todos' ? null : _selectedIgClassification.trim();
    final cg = _selectedCgClassification == 'Todos'
        ? null
        : _selectedCgClassification.trim();

    await _controller.loadFoodsFiltered(
      carbohydrateType: carbohydrateType,
      glycemicIndexClassification: ig,
      glycemicLoadClassification: cg,
    );

    setState(() => _isLoading = false);
  }

  Widget _foodCard(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.complexCardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF7F7F7),
                      border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                    ),
                    child: food.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              food.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.food_bank,
                                size: 26,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const Icon(Icons.food_bank, size: 26, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${food.kcal.toStringAsFixed(0)} kcal',
                    style: TextStyles.cardBodyText.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: TextStyles.cardTitle.copyWith(fontSize: 14),
                          ),
                        ),
                        Text(
                          '${food.grams.toStringAsFixed(0)}g',
                          style: TextStyles.cardBodyText.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _badge(
                          'Carb: ${food.carbohydrates.toStringAsFixed(0)}g',
                          const Color(0xFFEF5350),
                        ),
                        _badge(
                          'Fibra: ${food.fiber.toStringAsFixed(0)}g',
                          const Color(0xFF2DB93B),
                        ),
                        _badge(
                          'IG: ${food.glycemicIndex.toStringAsFixed(0)}',
                          _getGlycemicIndexColor(food.glycemicIndex),
                        ),
                        _badge(
                          'CG: ${food.glycemicLoad.toStringAsFixed(0)}',
                          _getGlycemicLoadColor(food.glycemicLoad),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.foodDetails,
                  arguments: food,
                );
              },
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Ver detalhes'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGlycemicIndexColor(double gi) => AppTheme.getGlycemicIndexColor(gi);

  Color _getGlycemicLoadColor(double gl) => AppTheme.getGlycemicLoadColor(gl);

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadFoods();
    setState(() => _isLoading = false);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _saveProgressIfNeeded() async {
    if (_hasSavedProgress) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return;

    _hasSavedProgress = true;

    await ProgressRepository().saveProgress(
      userId: userId,
      theoryTitle: 'Alimentos',
      progress: 1.0,
    );
  }
}
