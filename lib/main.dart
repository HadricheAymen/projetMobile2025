import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.screen.dart';
import 'providers/theme_provider.dart';
import 'services/sound_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  final SoundService _soundService = SoundService();
  final SettingsService _settingsService = SettingsService();
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _initSound();
    _startSoundWatcher();
  }

  Future<void> _initSound() async {
    _soundEnabled = await _settingsService.getSoundEnabled();
    if (_soundEnabled) {
      await _soundService.playStartSoundLoop();
    }
  }

  void _startSoundWatcher() async {
    while (mounted) {
      bool currentStatus = await _settingsService.getSoundEnabled();
      if (currentStatus != _soundEnabled) {
        _soundEnabled = currentStatus;
        if (_soundEnabled) {
          await _soundService.playStartSoundLoop();
        } else {
          await _soundService.stopStartSound();
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Trivia Quiz',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
