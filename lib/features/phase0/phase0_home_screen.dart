
import 'package:flutter/material.dart';
import 'fit_questions_screen.dart';
import 'know_what_i_want_screen.dart';

class Phase0HomeScreen extends StatelessWidget {
  const Phase0HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF091321),
              Color(0xFF0D1A2D),
              Color(0xFF06101B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeaderSection(),
                      const SizedBox(height: 18),
                      _FlowCard(
                        icon: Icons.ads_click_rounded,
                        title: 'I Know What I Want',
                        subtitle:
                            'Describe what you want to study, build, or become. The AI will suggest specialties that already exist in the app.',
                        accentColor: const Color(0xFF57D6FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KnowWhatIWantScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _FlowCard(
                        icon: Icons.psychology_alt_rounded,
                        title: "I Don't Know Where I Fit",
                        subtitle:
                            'Interest questions, guided AI chat, and a soft aptitude quiz to help you choose the right specialty.',
                        accentColor: const Color(0xFFFFD98A),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FitQuestionsScreen()),
                          );
                        },
                        isComingSoon: true,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.16),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How Phase 0 works',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'The AI only recommends specialties that already exist in Vision Career. '
                              'The app still controls the real path, mapping, and tree opening.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF162338),
            Color(0xFF0E1C2F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF57D6FF).withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vision Career',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Phase 0 helps the user choose the right specialty before opening the learning tree.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _FlowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF142038),
                Color(0xFF081E2D),
                Color(0xFF032031),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: accentColor.withOpacity(0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.14),
                  border: Border.all(
                    color: accentColor.withOpacity(0.6),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    if (isComingSoon) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                        child: const Text(
                          'Coming next',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: accentColor.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
