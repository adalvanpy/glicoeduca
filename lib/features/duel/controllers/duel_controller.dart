
import 'package:flutter/foundation.dart';
import '../../contexts/models/context_model.dart';
import '../../foods/models/food_model.dart';
import '../../nutritionist_tips/models/nutritionist_tips_model.dart';
import '../models/duel_model.dart';
import '../repositories/duel_repository.dart';

class DuelController extends ChangeNotifier {
  final DuelRepository repository;

  DuelController({required this.repository});

  List<ContextModel> _contexts = [];

  dynamic _itemA; // FoodModel ou NutritionistTipsModel
  dynamic _itemB; // FoodModel ou NutritionistTipsModel
  dynamic _correctItem; // Item que é a resposta correta
  
  String? _itemAType; // 'food' ou 'nutritionist_tip'
  String? _itemBType; // 'food' ou 'nutritionist_tip'
  String? _correctItemType; // 'food' ou 'nutritionist_tip'
  
  DuelModel? _currentDuel;
  List<DuelModel> _duelsInOrder = [];
  int _currentDuelIndex = 0;
  int _duelsPlayed = 0;
  int _duelsAvailableForContext = 0;
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

  List<ContextModel> get contexts => _contexts;
  dynamic get itemA => _itemA;
  dynamic get itemB => _itemB;
  dynamic get correctItem => _correctItem;
  String? get itemAType => _itemAType;
  String? get itemBType => _itemBType;
  String? get correctItemType => _correctItemType;
  DuelModel? get currentDuel => _currentDuel;
  String? get selectedItemId => _selectedItemId;
  int get duelsPlayed => _duelsPlayed;
  int get duelsAvailableForContext => _duelsAvailableForContext;
  bool get isDuelLimitReached =>
      _duelsAvailableForContext > 0 && _duelsPlayed >= _duelsAvailableForContext;
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


  Future<void> loadContexts() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _contexts = await repository.getContexts();
    } catch (e) {
      _setError('Não foi possível carregar os contextos.');

    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDuel(String contextId, {String? contextName}) async {
    if (contextId.trim().isEmpty) return;

    _duelsPlayed = 0;
    _duelsAvailableForContext = 0;
    _resetDuelState();
    _setLoading(true);
    _clearError();

    try {
      _currentContextId = contextId;
      _currentContextName = contextName;

      final contextDuels = await repository.getDuelsByContext(contextId);

      if (contextDuels.isEmpty) {
        _currentDuel = null;
        _duelsInOrder = [];
        _currentDuelIndex = 0;
        _setError('Não há duelos disponíveis para este contexto.');
      } else {
        final validDuels = contextDuels.where((duel) =>
          duel.foodAId.isNotEmpty && duel.foodBId.isNotEmpty
        ).toList();

        if (validDuels.isEmpty) {
          _currentDuel = null;
          _duelsInOrder = [];
          _currentDuelIndex = 0;
          _setError('Não há duelos válidos disponíveis para este contexto.');

        } else {
          _duelsInOrder = _sortDuels(validDuels);
          _duelsAvailableForContext = _duelsInOrder.length;
          _currentDuelIndex = 0;
          _currentDuel = _duelsInOrder[_currentDuelIndex];

          await _loadDuelItems(_currentDuel!);

        }
      }
    } catch (e) {
      _setError('Não foi possível carregar o duelo.');

    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadDuelItems(DuelModel duel) async {

    final itemAResult = await repository.getItemById(duel.foodAId);
    if (itemAResult != null) {
      _itemA = itemAResult.item;
      _itemAType = itemAResult.type;
      
      if (_itemA is FoodModel) {
        final food = _itemA as FoodModel;

      } else if (_itemA is NutritionistTipsModel) {
        final tip = _itemA as NutritionistTipsModel;

      }
    } else {

      _setError('Item A não encontrado.');
    }

    final itemBResult = await repository.getItemById(duel.foodBId);
    if (itemBResult != null) {
      _itemB = itemBResult.item;
      _itemBType = itemBResult.type;
      
      if (_itemB is FoodModel) {
        final food = _itemB as FoodModel;

      } else if (_itemB is NutritionistTipsModel) {
        final tip = _itemB as NutritionistTipsModel;

      }
    } else {

      _setError('Item B não encontrado.');
    }

    final resolvedCorrectId = duel.correctAnswerId.trim();
    final fallbackLabel = duel.correctAnswerLabel.trim();

    if (resolvedCorrectId.isNotEmpty && _looksLikeDocumentId(resolvedCorrectId)) {
      final correctItemResult = await repository.getItemById(resolvedCorrectId);
      if (correctItemResult != null) {
        _correctItem = correctItemResult.item;
        _correctItemType = correctItemResult.type;
      }
    } else if (fallbackLabel.isNotEmpty) {
      final normalizedFallback = _normalizeName(fallbackLabel);
      if (_itemA != null && _normalizeName(itemAName) == normalizedFallback) {
        _correctItem = _itemA;
        _correctItemType = _itemAType;
      } else if (_itemB != null && _normalizeName(itemBName) == normalizedFallback) {
        _correctItem = _itemB;
        _correctItemType = _itemBType;
      }
    }

    if (_correctItem == null) {
      if (_itemA != null && _itemB != null) {
        final itemANameNormalized = _normalizeName(itemAName);
        final itemBNameNormalized = _normalizeName(itemBName);
        final fallbackSelected = _normalizeName(fallbackLabel);

        if (fallbackSelected.isNotEmpty) {
          if (itemANameNormalized == fallbackSelected) {
            _correctItem = _itemA;
            _correctItemType = _itemAType;
          } else if (itemBNameNormalized == fallbackSelected) {
            _correctItem = _itemB;
            _correctItemType = _itemBType;
          }
        }
      }
    }

    if (_correctItem != null) {
      if (_correctItem is FoodModel) {
        final food = _correctItem as FoodModel;

      } else if (_correctItem is NutritionistTipsModel) {
        final tip = _correctItem as NutritionistTipsModel;

      }
    } else {

    }

    notifyListeners();
  }


  void selectItem(String itemId) {
    if (_showResult) return;
    _selectedItemId = itemId;
    notifyListeners();
  }

  void showDuelResult() {
    if (_selectedItemId == null || _currentDuel == null) return;

    final duel = _currentDuel!;
    final correctId = duel.correctFoodId.trim();
    final selectedId = _selectedItemId!.trim();
    final correctLabel = duel.correctAnswerLabel.trim();

    final selectedName = _selectedItemName();
    final correctNameFromLabel = correctLabel.isNotEmpty ? _normalizeName(correctLabel) : '';
    final correctNameFromIds =
        correctId.isNotEmpty && _looksLikeDocumentId(correctId)
            ? _normalizeName(_itemNameById(correctId))
            : '';

    bool isCorrect = selectedId == correctId;

    if (!isCorrect && correctNameFromLabel.isNotEmpty) {
      isCorrect = _normalizeName(selectedName) == correctNameFromLabel;
    }

    if (!isCorrect && correctNameFromIds.isNotEmpty) {
      isCorrect = _normalizeName(selectedName) == correctNameFromIds;
    }

    if (!isCorrect && _itemA != null && _itemB != null) {
      final leftName = _normalizeName(itemAName);
      final rightName = _normalizeName(itemBName);
      if (_normalizeName(selectedName) == leftName && leftName == correctNameFromLabel) {
        isCorrect = true;
      } else if (_normalizeName(selectedName) == rightName && rightName == correctNameFromLabel) {
        isCorrect = true;
      }
    }

    _isCorrect = isCorrect;
    _showResult = true;
    notifyListeners();
  }

  void registerCompletedDuel() {
    if (_duelsAvailableForContext > 0 && _duelsPlayed < _duelsAvailableForContext) {
      _duelsPlayed++;
    }
    notifyListeners();
  }

  Future<void> restartCurrentContext() async {
    if (_currentContextId == null || _currentContextId!.isEmpty) {
      return;
    }

    _duelsPlayed = 0;
    await loadDuel(_currentContextId!, contextName: _currentContextName);
  }

  Future<void> newDuel() async {
    if (_currentContextId == null || _currentContextId!.isEmpty) {
      return;
    }

    if (isDuelLimitReached) {
      return;
    }

    if (_duelsInOrder.isEmpty) {
      await loadDuel(_currentContextId!, contextName: _currentContextName);
      return;
    }

    _currentDuelIndex = (_currentDuelIndex + 1) % _duelsInOrder.length;
    _currentDuel = _duelsInOrder[_currentDuelIndex];
    _selectedItemId = null;
    _showResult = false;
    _isCorrect = null;
    _errorMessage = null;

    await _loadDuelItems(_currentDuel!);
    notifyListeners();
  }


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

      if (isWinner) {
        _wins++;
      } else {
        _losses++;
      }
      _totalGames++;

    } catch (e) {

    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }


  Future<void> loadUserStats(String userId) async {
    try {
      final progress = await repository.getUserDuelProgress(userId);
      if (progress != null) {
        _wins = progress.wins;
        _losses = progress.losses;
        _totalGames = progress.totalGames;

        notifyListeners();
      }
    } catch (e) {

    }
  }


  void listenToDuels(String contextId) {
    repository.streamDuelsByContext(contextId).listen(
      (updatedDuels) async {
        if (updatedDuels.isNotEmpty) {

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

          notifyListeners();
        }
      },
      onError: (error) {

      },
    );
  }


  String _selectedItemName() {
    if (_selectedItemId == null || _currentDuel == null) {
      return '';
    }

    if (_selectedItemId == _currentDuel!.foodAId) return itemAName;
    if (_selectedItemId == _currentDuel!.foodBId) return itemBName;
    return '';
  }

  String _itemNameById(String itemId) {
    if (_currentDuel == null) return '';
    if (itemId == _currentDuel!.foodAId) return itemAName;
    if (itemId == _currentDuel!.foodBId) return itemBName;
    return '';
  }

  bool _looksLikeDocumentId(String value) {
    if (value.trim().isEmpty) return false;
    return RegExp(r'^[A-Za-z0-9_-]{8,}$').hasMatch(value.trim());
  }

  List<DuelModel> _sortDuels(List<DuelModel> duels) {
    final sorted = List<DuelModel>.from(duels);
    sorted.sort((a, b) {
      final orderComparison = a.order.compareTo(b.order);
      if (orderComparison != 0) return orderComparison;
      return a.id.compareTo(b.id);
    });
    return sorted;
  }

  String _normalizeName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

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
    _duelsInOrder = [];
    _currentDuelIndex = 0;
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
    _duelsInOrder = [];
    _currentDuelIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

