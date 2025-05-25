import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final SettingsService _settingsService = SettingsService();
  final SoundService _soundService = SoundService();
  bool _soundEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    setState(() {
      _soundEnabled = soundEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? size.width * 0.055 : size.width * 0.035,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: isSmallScreen ? size.width * 0.05 : 20,
          ),
          onPressed: () {
            _soundService.playClickSound();
            Navigator.pop(context);
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: isSmallScreen ? 8 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: isSmallScreen ? size.width * 0.08 : 32,
                      color: colorScheme.onPrimary,
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personnalisation',
                            style: TextStyle(
                              fontSize: isSmallScreen ? size.width * 0.05 : 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          Text(
                            'Configurez votre expérience',
                            style: TextStyle(
                              fontSize: isSmallScreen ? size.width * 0.035 : 14,
                              color: colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 18 : 24),

              // Theme Setting
              _buildSettingCard(
                icon:
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                title: 'Mode d\'affichage',
                subtitle:
                    themeProvider.isDarkMode
                        ? 'Mode sombre activé'
                        : 'Mode clair activé',
                trailing: Switch.adaptive(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    _soundService.playClickSound();
                    themeProvider.toggleTheme();
                  },
                  activeColor: colorScheme.primary,
                ),
                colorScheme: colorScheme,
                isSmallScreen: isSmallScreen,
                size: size,
              ),

              SizedBox(height: isSmallScreen ? 10 : 16),

              // Sound Setting
              _buildSettingCard(
                icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                title: 'Effets sonores',
                subtitle: _soundEnabled ? 'Sons activés' : 'Sons désactivés',
                trailing: Switch.adaptive(
                  value: _soundEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _soundEnabled = value;
                    });
                    await _settingsService.setSoundEnabled(value);
                    if (value) {
                      _soundService.playClickSound();
                    }
                  },
                  activeColor: colorScheme.primary,
                ),
                colorScheme: colorScheme,
                isSmallScreen: isSmallScreen,
                size: size,
              ),

              SizedBox(height: isSmallScreen ? 22 : 32),

              // About Section
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: isSmallScreen ? size.width * 0.05 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          'À propos',
                          style: TextStyle(
                            fontSize: isSmallScreen ? size.width * 0.045 : 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    Text(
                      'Trivia Quiz App v1.0.0\nUne application de quiz interactive avec des questions variées.',
                      style: TextStyle(
                        fontSize: isSmallScreen ? size.width * 0.035 : 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required ColorScheme colorScheme,
    required bool isSmallScreen,
    required Size size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: isSmallScreen ? 6 : 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 14 : 20,
          vertical: isSmallScreen ? 6 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: isSmallScreen ? size.width * 0.06 : 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? size.width * 0.04 : 16,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isSmallScreen ? size.width * 0.035 : 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
