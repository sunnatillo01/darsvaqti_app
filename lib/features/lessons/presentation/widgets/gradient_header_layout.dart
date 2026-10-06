import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Tepada to'q ko'k gradient, uning ustiga oq kartalar chiqib turadigan maket.
class GradientHeaderLayout extends StatelessWidget {
  const GradientHeaderLayout({super.key, required this.gradientHeight, required this.children});

  final double gradientHeight;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + gradientHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.gradientTop, AppColors.gradientBottom],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: top + 16, bottom: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }
}
