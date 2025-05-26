// IMPORTANT :
// SoundService est un singleton qui gère la musique de fond et les effets sonores.
// La musique de fond (start.mp3) NE DOIT PAS être stoppée ou disposée ailleurs que dans SoundService.
// Seul SoundService contrôle le démarrage/arrêt de la musique de fond selon le paramètre utilisateur.
// Les écrans doivent uniquement utiliser les méthodes publiques pour jouer les effets.

import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _effectsPlayer = AudioPlayer(); // pour effets
  final AudioPlayer _startPlayer = AudioPlayer(); // pour start.mp3
  final SettingsService _settingsService = SettingsService();

  Future<void> playCorrectSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _effectsPlayer.play(AssetSource('sounds/correct.mp3'));
      } catch (e) {
        print('Erreur lecture correct: $e');
      }
    }
  }

  Future<void> playIncorrectSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _effectsPlayer.play(AssetSource('sounds/incorrect.mp3'));
      } catch (e) {
        print('Erreur lecture incorrect: $e');
      }
    }
  }

  Future<void> playClickSound() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _effectsPlayer.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        print('Erreur lecture clic: $e');
      }
    }
  }

  Future<void> playStartSoundLoop() async {
    final soundEnabled = await _settingsService.getSoundEnabled();
    if (soundEnabled) {
      try {
        await _startPlayer.setReleaseMode(ReleaseMode.loop);
        await _startPlayer.play(AssetSource('sounds/start.mp3'));
        print('Son start lancé en boucle');
      } catch (e) {
        print('Erreur lecture start: $e');
      }
    }
  }

  Future<void> stopStartSound() async {
    try {
      await _startPlayer.stop();
      print('Son start arrêté');
    } catch (e) {
      print('Erreur arrêt son start: $e');
    }
  }

  void dispose() {
    //_effectsPlayer.dispose();
    //_startPlayer.dispose();
  }
}
