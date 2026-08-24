import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/text_styles.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;

  const AppBottomNavigation({
    super.key,
    this.currentIndex = 0,
    this.onItemSelected,
  });

  static const _items = [
    (icon: Icons.home_outlined, label: 'Início'),
    (icon: Icons.menu_book_outlined, label: 'Guia'),
    (icon: Icons.sports_kabaddi_outlined, label: 'Game'),
    (icon: Icons.quiz_outlined, label: 'Quiz'),
    (icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = index == currentIndex;
          return InkWell(
            onTap: onItemSelected == null ? null : () => onItemSelected!(index),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 27, color: selected ? AppTheme.primaryColor : Colors.black),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyles.navigation.copyWith(
                      color: selected ? AppTheme.primaryColor : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
