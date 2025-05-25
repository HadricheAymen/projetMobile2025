import 'package:flutter/material.dart';
import '../widgets/settings_icon_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'À propos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? size.width * 0.055 : size.width * 0.035,
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
            child: Center(
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 18 : 32),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size:
                              isSmallScreen
                                  ? size.width * 0.08
                                  : size.width * 0.045,
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 16),
                        Text(
                          'Trivia Quiz App',
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? size.width * 0.06
                                    : size.width * 0.035,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 20),
                    Text(
                      'Cette application utilise l\'API OpenTDB pour récupérer des questions de quiz variées.',
                      style: TextStyle(
                        fontSize:
                            isSmallScreen
                                ? size.width * 0.038
                                : size.width * 0.022,
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 20),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: colorScheme.secondary,
                          size:
                              isSmallScreen
                                  ? size.width * 0.05
                                  : size.width * 0.03,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 12),
                        Text(
                          'Version: 1.0.0',
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? size.width * 0.035
                                    : size.width * 0.02,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 12),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: colorScheme.secondary,
                          size:
                              isSmallScreen
                                  ? size.width * 0.05
                                  : size.width * 0.03,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 12),
                        Text(
                          'Développé par: Hadriche Aymen & Mohamed Kamoun',
                          style: TextStyle(
                            fontSize:
                                isSmallScreen
                                    ? size.width * 0.035
                                    : size.width * 0.02,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
