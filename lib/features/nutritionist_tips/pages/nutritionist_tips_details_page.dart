import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../models/nutritionist_tips_model.dart';

class NutritionistTipsDetailsPage extends StatelessWidget {
  final NutritionistTipsModel tip;

  const NutritionistTipsDetailsPage({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyles.logoRed.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Glico',
                                  style: TextStyles.logoRed,
                                ),
                                const TextSpan(
                                  text: 'Educa',
                                  style: TextStyles.logoGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: tip.image.isNotEmpty
                              ? Image.network(
                                  tip.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
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
                    const SizedBox(height: 14),
                    Text(
                      tip.dish,
                      style: TextStyles.pageTitle.copyWith(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sobre a combinação',
                      style: TextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1E90FF),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tip.description.isNotEmpty
                            ? tip.description
                            : 'Descrição não disponível.',
                        style: TextStyles.bodySmall.copyWith(
                          height: 1.5,
                          color: const Color(0xFF374151),
                        ),
                      ),
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
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.optionTheory,
                  );
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.instructionsDuel,
                  );
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.instructionsQuiz,
                  );
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
}
