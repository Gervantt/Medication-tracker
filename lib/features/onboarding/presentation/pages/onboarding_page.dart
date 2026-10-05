import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/core/widgets/medical_disclaimer.dart';
import 'package:medtrack/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:medtrack/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:medtrack/features/onboarding/presentation/widgets/page_indicator.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: BlocListener<OnboardingCubit, OnboardingStatus>(
        listener: (context, status) {
          if (status == OnboardingStatus.completed) {
            context.go(AppRoutes.today);
          }
        },
        child: const OnboardingView(),
      ),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  static const _pageCount = 3;

  final _controller = PageController();
  int _page = 0;

  bool get _isLastPage => _page == _pageCount - 1;

  Future<void> _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  OnboardingSlide(
                    icon: Icons.medication_outlined,
                    title: l10n.onboardingWelcomeTitle,
                    body: l10n.onboardingWelcomeBody,
                  ),
                  OnboardingSlide(
                    icon: Icons.health_and_safety_outlined,
                    title: l10n.onboardingDisclaimerTitle,
                    body: l10n.onboardingDisclaimerBody,
                    extra: const MedicalDisclaimer(),
                  ),
                  OnboardingSlide(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.onboardingRemindersTitle,
                    body: l10n.onboardingRemindersBody,
                  ),
                ],
              ),
            ),
            PageIndicator(count: _pageCount, current: _page),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _isLastPage
                  ? const _ReminderButtons()
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(l10n.next),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderButtons extends StatelessWidget {
  const _ReminderButtons();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OnboardingCubit>();
    final isBusy = context.select<OnboardingCubit, bool>(
      (cubit) => cubit.state != OnboardingStatus.idle,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isBusy ? null : cubit.enableReminders,
          child: Text(l10n.onboardingEnableReminders),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isBusy ? null : cubit.skipReminders,
          child: Text(l10n.onboardingNotNow),
        ),
      ],
    );
  }
}
