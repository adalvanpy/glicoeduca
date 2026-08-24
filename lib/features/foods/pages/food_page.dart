import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
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
  String _selectedCategory = 'Simples';
  String _selectedIgClassification = 'Todos';
  String _selectedCgClassification = 'Todos';
  bool _isLoading = true;

  final List<String> _categories = ['Todos', 'Simples', 'Complexos'];
  final List<String> _igClassifications = ['Todos', 'Baixo', 'Moderado', 'Alto'];
  final List<String> _cgClassifications = ['Todos', 'Baixa', 'Moderada', 'Alta'];

  @override
  void initState() {
    super.initState();
    _controller = FoodController(repository: FoodRepository());
    _controller.addListener(_refresh);
    _loadData();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadFoods();
    setState(() => _isLoading = false);
  }

  Future<void> _filterFoods() async {
    setState(() => _isLoading = true);
    
    final category = _selectedCategory == 'Todos' ? null : _selectedCategory;
    final ig = _selectedIgClassification == 'Todos' ? null : _selectedIgClassification;
    final cg = _selectedCgClassification == 'Todos' ? null : _selectedCgClassification;
    
    await _controller.loadFoodsFiltered(
      category: category,
      glycemicIndexClassification: ig,
      glycemicLoadClassification: cg,
    );
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Glico', style: TextStyles.logoRed),
                  TextSpan(text: 'Educa', style: TextStyles.logoGreen),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Alimentos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Entendendo as composições dos alimentos',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipos (Simples/Complexos)
        _buildFilterSection(
          title: 'Tipos',
          options: _categories,
          selected: _selectedCategory,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
            _filterFoods();
          },
        ),
        const SizedBox(height: 16),
        // Índice Glicêmico
        _buildFilterSection(
          title: 'Índice glicêmico',
          options: _igClassifications,
          selected: _selectedIgClassification,
          onChanged: (value) {
            setState(() {
              _selectedIgClassification = value!;
            });
            _filterFoods();
          },
        ),
        const SizedBox(height: 16),
        // Carga Glicêmica
        _buildFilterSection(
          title: 'Carga glicêmica',
          options: _cgClassifications,
          selected: _selectedCgClassification,
          onChanged: (value) {
            setState(() {
              _selectedCgClassification = value!;
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
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
        ..._controller.foods.map((food) {
          return _foodCard(food);
        }).toList(),
      ],
    );
  }

  Widget _foodCard(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: food.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.food_bank,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const Icon(Icons.food_bank, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _badge(
                      'Carb: ${food.carbohydrates.toStringAsFixed(0)}g',
                      Colors.red,
                    ),
                    _badge(
                      'Fibras: ${food.fiber.toStringAsFixed(0)}g',
                      Colors.green,
                    ),
                    _badge(
                      'IG: ${food.glycemicIndex.toStringAsFixed(0)}',
                      _getGlycemicIndexColor(food.glycemicIndex),
                    ),
                    _badge(
                      'CG: ${food.glycemicLoad.toStringAsFixed(1)}',
                      _getGlycemicLoadColor(food.glycemicLoad),
                    ),
                    if (food.category.isNotEmpty)
                      _badge(food.category, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          // Quantidade
          Column(
            children: [
              Text(
                '${food.grams.toStringAsFixed(0)}g',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
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

  Color _getGlycemicIndexColor(double gi) {
    if (gi <= 55) return Colors.green;
    if (gi <= 69) return Colors.orange;
    return Colors.red;
  }

  Color _getGlycemicLoadColor(double gl) {
    if (gl <= 10) return Colors.green;
    if (gl <= 19) return Colors.orange;
    return Colors.red;
  }
}