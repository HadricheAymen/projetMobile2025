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
        print('Playing correct sound');
        await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        // Fallback: use a simple beep or do nothing
        print('Could not play correct sound: $e');
      }
    } else {
      // If sound is disabled, do nothing
      print('Sound is disabled, not playing correct sound');
    }
  }

  // Play incorrect answer sound
  Future<void> playIncorrectSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        print('Playing incorrect sound');
        await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } catch (e) {
        print('Could not play incorrect sound: $e');
      }
    } else {
      // If sound is disabled, do nothing
      print('Sound is disabled, not playing incorrect sound');
    }
  }

  // Play button click sound
  Future<void> playClickSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        print('Playing click sound');
        await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        print('Could not play click sound: $e');
      }
    } else {
      // If sound is disabled, do nothing
      print('Sound is disabled, not playing click sound');
    }
  }

  // Play quiz start sound
  Future<void> playStartSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        print('Playing start sound');
        await _audioPlayer.play(AssetSource('sounds/start.mp3'));
      } catch (e) {
        print('Could not play start sound: $e');
      }
    } else {
      // If sound is disabled, do nothing
      print('Sound is disabled, not playing start sound');
    }
  }

  // Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
