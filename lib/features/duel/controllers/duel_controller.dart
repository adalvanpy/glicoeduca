// duel_controller.dart
import 'package:flutter/foundation.dart';
import '../../contexts/models/context_model.dart';
import '../../foods/models/food_model.dart';
import '../../nutritionist_tips/models/nutritionist_tips_model.dart';
import '../models/duel_model.dart';
import '../repositories/duel_repository.dart';

class DuelController extends ChangeNotifier {
  final DuelRepository repository;

  DuelController({required this.repository});

  // Estado
  List<ContextModel> _contexts = [];
  
  // Itens do duelo (podem ser Food ou NutritionistTip)
  dynamic _itemA; // FoodModel ou NutritionistTipsModel
  dynamic _itemB; // FoodModel ou NutritionistTipsModel
  dynamic _correctItem; // Item que é a resposta correta
  
  String? _itemAType; // 'food' ou 'nutritionist_tip'
  String? _itemBType; // 'food' ou 'nutritionist_tip'
  String? _correctItemType; // 'food' ou 'nutritionist_tip'
  
  DuelModel? _currentDuel;
  String? _selectedItemId;

  bool _isLoading = false;
  bool _showResult = false;
  bool? _isCorrect;
  String? _errorMessage;
  bool _isSaving = false;

  int _wins = 0;
  int _losses = 0;
  int _totalGames = 0;

  String? _currentContextId;
  String? _currentContextName;

  // Getters
  List<ContextModel> get contexts => _contexts;
  dynamic get itemA => _itemA;
  dynamic get itemB => _itemB;
  dynamic get correctItem => _correctItem;
  String? get itemAType => _itemAType;
  String? get itemBType => _itemBType;
  String? get correctItemType => _correctItemType;
  DuelModel? get currentDuel => _currentDuel;
  String? get selectedItemId => _selectedItemId;
  bool get isLoading => _isLoading;
  bool get showResult => _showResult;
  bool? get isCorrect => _isCorrect;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  int get wins => _wins;
  int get losses => _losses;
  int get totalGames => _totalGames;
  String? get currentContextId => _currentContextId;
  String? get currentContextName => _currentContextName;
  
  // 🔥 DESCRIPTION do item correto (explicação) 🔥
  String get description {
    if (_correctItem == null) return '';
    
    if (_correctItem is FoodModel) {
      return (_correctItem as FoodModel).description ?? '';
    }
    if (_correctItem is NutritionistTipsModel) {
      return (_correctItem as NutritionistTipsModel).description ?? '';
    }
    return '';
  }

  // ============= GETTERS PARA ITEM A =============
  
  String get itemAName {
    if (_itemA is FoodModel) return (_itemA as FoodModel).name;
    if (_itemA is NutritionistTipsModel) return (_itemA as NutritionistTipsModel).dish;
    return 'Item não encontrado (ID: ${_currentDuel?.foodAId})';
  }

  String get itemADescription {
    if (_itemA is FoodModel) {
      final food = _itemA as FoodModel;
      return '${food.name ?? 0} name • ${food.category ?? "Sem categoria"}';
    }
    if (_itemA is NutritionistTipsModel) {
      return (_itemA as NutritionistTipsModel).description;
    }
    return '';
  }

  String get itemAImage {
    if (_itemA is FoodModel) return (_itemA as FoodModel).image;
    if (_itemA is NutritionistTipsModel) return (_itemA as NutritionistTipsModel).image;
    return '';
  }

  String get itemATypeLabel {
    if (_itemA is FoodModel) return 'Alimento';
    if (_itemA is NutritionistTipsModel) return 'Dica do Nutricionista';
    return 'Desconhecido';
  }

  bool get isItemAFood => _itemA is FoodModel;
  bool get isItemANutritionistTip => _itemA is NutritionistTipsModel;

  // ============= GETTERS PARA ITEM B =============
  
  String get itemBName {
    if (_itemB is FoodModel) return (_itemB as FoodModel).name;
    if (_itemB is NutritionistTipsModel) return (_itemB as NutritionistTipsModel).dish;
    return 'Item não encontrado (ID: ${_currentDuel?.foodBId})';
  }

  String get itemBDescription {
    if (_itemB is FoodModel) {
      final food = _itemB as FoodModel;
      return '${food.name ?? 0} name • ${food.category ?? "Sem categoria"}';
    }
    if (_itemB is NutritionistTipsModel) {
      return (_itemB as NutritionistTipsModel).description;
    }
    return '';
  }

  String get itemBImage {
    if (_itemB is FoodModel) return (_itemB as FoodModel).image;
    if (_itemB is NutritionistTipsModel) return (_itemB as NutritionistTipsModel).image;
    return '';
  }

  String get itemBTypeLabel {
    if (_itemB is FoodModel) return 'Alimento';
    if (_itemB is NutritionistTipsModel) return 'Dica do Nutricionista';
    return 'Desconhecido';
  }

  bool get isItemBFood => _itemB is FoodModel;
  bool get isItemBNutritionistTip => _itemB is NutritionistTipsModel;

  // ============= MÉTODOS DE CARREGAMENTO =============

  Future<void> loadContexts() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _contexts = await repository.getContexts();
    } catch (e) {
      _setError('Não foi possível carregar os contextos.');
      debugPrint('❌ Erro ao carregar contextos: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDuel(String contextId, {String? contextName}) async {
    if (contextId.trim().isEmpty) return;

    _resetDuelState();
    _setLoading(true);
    _clearError();

    try {
      _currentContextId = contextId;
      _currentContextName = contextName;

      final contextDuels = await repository.getDuelsByContext(contextId);

      debugPrint('🔍 Duelos encontrados para contexto $contextName (ID: $contextId): ${contextDuels.length}');

      if (contextDuels.isEmpty) {
        _currentDuel = null;
        _setError('Não há duelos disponíveis para este contexto.');
      } else {
        final validDuels = contextDuels.where((duel) =>
          duel.foodAId.isNotEmpty && duel.foodBId.isNotEmpty
        ).toList();

        if (validDuels.isEmpty) {
          _currentDuel = null;
          _setError('Não há duelos válidos disponíveis para este contexto.');
          debugPrint('⚠️ Todos os duelos têm IDs de alimentos vazios!');
        } else {
          validDuels.shuffle();
          _currentDuel = validDuels.first;

          debugPrint('🎯 Duelo selecionado: ${_currentDuel!.id}');
          debugPrint('🍎 FoodA ID: ${_currentDuel!.foodAId}');
          debugPrint('🍎 FoodB ID: ${_currentDuel!.foodBId}');
          debugPrint('✅ Correct Answer ID: ${_currentDuel!.correctAnswerId}');

          // Carregar os dois itens do duelo
          await _loadDuelItems(_currentDuel!);

          debugPrint('✅ ItemA: ${itemAName} (${_itemAType})');
          debugPrint('✅ ItemB: ${itemBName} (${_itemBType})');
          debugPrint('📝 Description (explicação): $description');
        }
      }
    } catch (e) {
      _setError('Não foi possível carregar o duelo.');
      debugPrint('❌ Erro ao carregar duelo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadDuelItems(DuelModel duel) async {
    // Carregar Item A
    final itemAResult = await repository.getItemById(duel.foodAId);
    if (itemAResult != null) {
      _itemA = itemAResult.item;
      _itemAType = itemAResult.type;
      
      if (_itemA is FoodModel) {
        final food = _itemA as FoodModel;
        debugPrint('✅ Item A (Food): ${food.name}');
      } else if (_itemA is NutritionistTipsModel) {
        final tip = _itemA as NutritionistTipsModel;
        debugPrint('✅ Item A (NutritionistTip): ${tip.dish} - ${tip.description}');
      }
    } else {
      debugPrint('⚠️ ItemA não encontrado! ID: ${duel.foodAId}');
      _setError('Item A não encontrado.');
    }

    // Carregar Item B
    final itemBResult = await repository.getItemById(duel.foodBId);
    if (itemBResult != null) {
      _itemB = itemBResult.item;
      _itemBType = itemBResult.type;
      
      if (_itemB is FoodModel) {
        final food = _itemB as FoodModel;
        debugPrint('✅ Item B (Food): ${food.name}');
      } else if (_itemB is NutritionistTipsModel) {
        final tip = _itemB as NutritionistTipsModel;
        debugPrint('✅ Item B (NutritionistTip): ${tip.dish} - ${tip.description}');
      }
    } else {
      debugPrint('⚠️ ItemB não encontrado! ID: ${duel.foodBId}');
      _setError('Item B não encontrado.');
    }

    // 🔥 CARREGAR O ITEM CORRETO (para pegar a description) 🔥
    final correctItemResult = await repository.getItemById(duel.correctAnswerId);
    if (correctItemResult != null) {
      _correctItem = correctItemResult.item;
      _correctItemType = correctItemResult.type;
      
      if (_correctItem is FoodModel) {
        final food = _correctItem as FoodModel;
        debugPrint('✅ Item Correto (Food): ${food.name} - Description: ${food.description}');
      } else if (_correctItem is NutritionistTipsModel) {
        final tip = _correctItem as NutritionistTipsModel;
        debugPrint('✅ Item Correto (NutritionistTip): ${tip.dish} - Description: ${tip.description}');
      }
    } else {
      debugPrint('⚠️ Item Correto não encontrado! ID: ${duel.correctAnswerId}');
    }

    notifyListeners();
  }

  // ============= MÉTODOS DE INTERAÇÃO =============

  void selectItem(String itemId) {
    if (_showResult) return;
    _selectedItemId = itemId;
    notifyListeners();
  }

  void showDuelResult() {
    if (_selectedItemId == null || _currentDuel == null) return;
    _isCorrect = _selectedItemId == _currentDuel!.correctAnswerId;
    _showResult = true;
    notifyListeners();
  }

  Future<void> newDuel() async {
    if (_currentContextId == null || _currentContextId!.isEmpty) {
      debugPrint('⚠️ newDuel: currentContextId é null ou vazio');
      return;
    }
    debugPrint('🔄 Novo duelo para contexto: $_currentContextName (ID: $_currentContextId)');
    await loadDuel(_currentContextId!, contextName: _currentContextName);
  }

  // ============= MÉTODOS DE SALVAR RESULTADO =============

  Future<void> saveResult(String userId) async {
    if (_currentDuel == null || _selectedItemId == null || userId.trim().isEmpty) return;
    if (_isSaving) return;

    _isSaving = true;
    notifyListeners();

    try {
      final isWinner = _isCorrect == true;

      await repository.saveUserDuelProgress(
        userId: userId,
        isWinner: isWinner,
      );
      debugPrint('✅ Progresso do duelo salvo em user_duel_progress');

      if (isWinner) {
        _wins++;
      } else {
        _losses++;
      }
      _totalGames++;
      debugPrint('📊 Estatísticas: Vitórias: $_wins, Derrotas: $_losses, Total: $_totalGames');
    } catch (e) {
      debugPrint('❌ Erro ao salvar resultado: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ============= MÉTODOS DE ESTATÍSTICAS =============

  Future<void> loadUserStats(String userId) async {
    try {
      final progress = await repository.getUserDuelProgress(userId);
      if (progress != null) {
        _wins = progress.wins;
        _losses = progress.losses;
        _totalGames = progress.totalGames;
        debugPrint('📊 Estatísticas carregadas: Vitórias: $_wins, Derrotas: $_losses, Total: $_totalGames');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
    }
  }

  // ============= STREAMS EM TEMPO REAL =============

  void listenToDuels(String contextId) {
    repository.streamDuelsByContext(contextId).listen(
      (updatedDuels) async {
        if (updatedDuels.isNotEmpty) {
          debugPrint('🔄 Duelos atualizados em tempo real: ${updatedDuels.length}');
          
          if (_currentDuel != null) {
            final stillExists = updatedDuels.any((d) => d.id == _currentDuel!.id);
            if (!stillExists && updatedDuels.isNotEmpty) {
              final validDuels = updatedDuels.where((duel) =>
                duel.foodAId.isNotEmpty && duel.foodBId.isNotEmpty
              ).toList();
              
              if (validDuels.isNotEmpty) {
                validDuels.shuffle();
                _currentDuel = validDuels.first;
                _selectedItemId = null;
                _showResult = false;
                _isCorrect = null;
                
                await _loadDuelItems(_currentDuel!);
                notifyListeners();
              }
            }
          }
        }
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
        notifyListeners();
      },
    );
  }

  void listenToUserProgress(String userId) {
    repository.streamUserProgress(userId).listen(
      (progress) {
        if (progress != null) {
          _wins = progress.wins;
          _losses = progress.losses;
          _totalGames = progress.totalGames;
          debugPrint('📊 Estatísticas atualizadas em tempo real: Vitórias: $_wins, Derrotas: $_losses, Total: $_totalGames');
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('❌ Erro no stream de progresso: $error');
      },
    );
  }

  // ============= MÉTODOS AUXILIARES =============

  void _resetDuelState() {
    _selectedItemId = null;
    _showResult = false;
    _isCorrect = null;
    _isSaving = false;
    _itemA = null;
    _itemB = null;
    _correctItem = null;
    _itemAType = null;
    _itemBType = null;
    _correctItemType = null;
    _currentDuel = null;
    _errorMessage = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void reset() {
    _resetDuelState();
    _contexts = [];
    _wins = 0;
    _losses = 0;
    _totalGames = 0;
    _currentContextId = null;
    _currentContextName = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
