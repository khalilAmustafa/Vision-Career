import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import 'specialty_recommendation_screen.dart';
import 'fit_questions_screen.dart';

class Phase0HomeScreen extends StatelessWidget {
  const Phase0HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _HeroSection(l10n: l10n),

                    const SizedBox(height: 24),

                    _DividerText(text: l10n.notSureYet),

                    const SizedBox(height: 16),

                    _QuizCard(
                      l10n: l10n,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FitQuestionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Vision Career',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _HeroSection extends StatefulWidget {
  final AppLocalizations l10n;

  const _HeroSection({required this.l10n});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final TextEditingController controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final text = controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    final geminiService = const Phase0GeminiService();
    final mappingService = Phase0MappingService();

    try {
      final allowedSpecialties =
      await mappingService.getAllowedSpecialties();

      if (allowedSpecialties.isEmpty) {
        throw Exception("No specialties available");
      }

      final results = await geminiService.recommendFromFreeText(
        userDescription: text,
        allowedSpecialties: allowedSpecialties,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpecialtyRecommendationScreen(
            title: widget.l10n.suggestedSpecialties,
            subtitle: widget.l10n.choosePathSubtitle,
            recommendations: results,
          ),
        ),
      );
    } catch (e) {
      debugPrint("🔥 GEMINI ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment:
      isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.whatDoYouWantToBecome,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.l10n.weGuideYou,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 18),

        /// INPUT
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 8),

              Expanded(
                child: AppTextField(
                  controller: controller,
                  hint: widget.l10n.aiInputHint,
                ),
              ),

              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : IconButton(
                onPressed: () => _submit(context),
                icon: Icon(
                  isRTL
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          widget.l10n.aiInputHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
          ),
        ),

        const SizedBox(height: 16),

        AppButton(
          text: widget.l10n.startWithAI,
          isLoading: _isLoading,
          onPressed: () => _submit(context),
        ),
      ],
    );
  }
}

class _DividerText extends StatelessWidget {
  final String text;

  const _DividerText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _QuizCard extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _QuizCard({
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.psychology_alt_rounded,
                color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(l10n.quickQuiz,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l10n.quizDescription,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              isRTL
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}