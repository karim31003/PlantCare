import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/persistence_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboarding_1.png",
      "title": "Welcome to Gardener",
      "description":
          "Detect plant diseases instantly using artificial intelligence. Keep your plants healthy and growing strong."
    },
    {
      "image": "assets/images/onboarding_2.png",
      "title": "AI Powered Detection",
      "description":
          "Advanced AI analyzes your plant and detects diseases within seconds."
    },
    {
      "image": "assets/images/onboarding_3.png",
      "title": "Treatment Advice",
      "description":
          "Receive watering tips and treatment recommendations instantly."
    },
  ];

  void finishOnboarding() async {
    await PersistenceService.markFirstLaunchComplete();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          /// PAGE VIEW
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              final page = pages[index];

              return Column(
                children: [
                  /// TOP IMAGE SECTION
                  SizedBox(
                    height: height * 0.55,
                    width: width,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(32)),
                          child: Image.asset(
                            page["image"]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(32)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.15),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  /// TEXT SECTION
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                page["title"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromARGB(255, 69, 116, 69),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page["description"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  color: const Color(0xFF6B7280),
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),

                          /// FOOTER SECTION
                          Column(
                            children: [
                              /// DOTS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  pages.length,
                                  (dotIndex) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    height: 8,
                                    width: currentIndex == dotIndex ? 28 : 8,
                                    decoration: BoxDecoration(
                                      color: currentIndex == dotIndex
                                          ? AppTheme.primaryGreen
                                          : const Color(0xFFE5E7EB),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              /// BUTTONS
                              // Show buttons only on first two pages
                              if (currentIndex < 2)
                                Row(
                                  children: [
                                    /// SKIP BUTTON
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: finishOnboarding,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          side: BorderSide(
                                            color: const Color.fromARGB(255, 243, 246, 242)
                                                .withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          "Skip",
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: AppTheme.primaryGreen,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    /// NEXT BUTTON
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _controller.nextPage(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryGreen,
                                          foregroundColor: AppTheme.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          elevation: 2,
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                        label: Text(
                                          "Next",
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              // Show "Get Started" only on the last page
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: finishOnboarding,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: AppTheme.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      elevation: 2,
                                    ),
                                    icon: const Icon(
                                      Icons.check_rounded,
                                      size: 22,
                                    ),
                                    label: Text(
                                      "Get Started",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}