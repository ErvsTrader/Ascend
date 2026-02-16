import 'package:flutter/material.dart';
import '../../core/design_system.dart';
import 'name_collection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to Ascend',
      subtitle: 'Build lasting habits, one day at a time',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.primary,
      description: 'Person climbing stairs towards a bright goal.',
    ),
    OnboardingData(
      title: 'Track Your Progress',
      subtitle: 'See your streaks grow and celebrate your wins',
      icon: Icons.calendar_month_rounded,
      color: AppColors.habitIndigo,
      description: 'Visual calendar with colorful habit streaks.',
    ),
    OnboardingData(
      title: 'Stay Consistent',
      subtitle: 'Daily reminders help you stay on track',
      icon: Icons.notifications_active_rounded,
      color: AppColors.habitCoral,
      description: 'A friendly notification nudging you to check in.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NameCollectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Placeholder
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            borderRadius: AppRadius.cardLargeBorder,
                          ),
                          child: Icon(
                            page.icon,
                            size: 100,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxxl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Action Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
  });
}
