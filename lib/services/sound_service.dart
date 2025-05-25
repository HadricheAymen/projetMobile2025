import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final SettingsService _settingsService = SettingsService();

  // Play correct answer sound
  Future<void> playCorrectSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        // For now, we'll use a system sound. In a real app, you'd use custom audio files
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        // Fallback: use a simple beep or do nothing
        print('Could not play correct sound: $e');
      }
    }
  }

  // Play incorrect answer sound
  Future<void> playIncorrectSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } catch (e) {
        print('Could not play incorrect sound: $e');
      }
    }
  }

  // Play button click sound
  Future<void> playClickSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        print('Could not play click sound: $e');
      }
    }
  }

  // Play quiz start sound
  Future<void> playStartSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('sounds/start.mp3'));
      } catch (e) {
        print('Could not play start sound: $e');
      }
    }
  }

  // Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
