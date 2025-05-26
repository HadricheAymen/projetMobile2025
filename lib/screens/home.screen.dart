import 'package:flutter/material.dart';
import 'about.screen.dart';
import 'quiz_setup.screen.dart';
import 'leaderboard.screen.dart';
import '../widgets/settings_icon_button.dart';
import '../services/sound_service.dart';



class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final colorScheme = Theme.of(context).colorScheme;
    final soundService = SoundService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trivia Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? size.width * 0.06 : size.width * 0.04,
          ),
        ),
        actions: const [SettingsIconButton()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 16 : 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.quiz,
                          size:
                              isSmallScreen
                                  ? size.width * 0.12
                                  : size.width * 0.08,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 32),
                      Text(
                        'Bienvenue dans',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen
                                  ? size.width * 0.04
                                  : size.width * 0.03,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Text(
                        'Trivia Quiz',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen
                                  ? size.width * 0.06
                                  : size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Testez vos connaissances avec des questions variées',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? size.width * 0.035
                                    : size.width * 0.025,
                            color: colorScheme.onSurface.withOpacity(0.6),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMenuButton(
                        context: context,
                        icon: Icons.play_arrow,
                        title: 'Commencer le Quiz',
                        subtitle: 'Nouvelle partie',
                        onPressed: () {
                          soundService.playClickSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuizSetupScreen(),
                            ),
                          );
                        },
                        useGradient: true,
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 24),
                      _buildMenuButton(
                        context: context,
                        icon: Icons.leaderboard,
                        title: 'Classement',
                        subtitle: 'Meilleurs scores',
                        onPressed: () {
                          soundService.playClickSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 24),
                      _buildMenuButton(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'À propos',
                        subtitle: 'Infos application',
                        onPressed: () {
                          soundService.playClickSound();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutScreen(),
                            ),
                          );
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    bool useGradient = false,
    bool isSmallScreen = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient:
            useGradient
                ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.85),
                  ],
                )
                : null,
        color: useGradient ? null : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                useGradient
                    ? colorScheme.primary.withOpacity(0.3)
                    : colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            useGradient
                ? null
                : Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 14,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        useGradient
                            ? colorScheme.onPrimary.withOpacity(0.2)
                            : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color:
                        useGradient
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          color:
                              useGradient
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 12,
                          color:
                              useGradient
                                  ? colorScheme.onPrimary.withOpacity(0.8)
                                  : colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color:
                      useGradient
                          ? colorScheme.onPrimary.withOpacity(0.7)
                          : colorScheme.onSurface.withOpacity(0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
