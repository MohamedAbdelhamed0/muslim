import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AdhanAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  AdhanAudioService() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });
  }

  /// Plays the Adhan sound from assets/audio/adhan.mp3
  Future<void> playAdhan() async {
    try {
      if (kDebugMode) {
        debugPrint('🔊 [AUDIO SERVICE] Starting Adhan sound playback...');
      }
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/adhan.mp3'));
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [AUDIO SERVICE] Error playing Adhan sound: $e');
        debugPrint('   Ensure adhan.mp3 is placed at: assets/audio/adhan.mp3');
      }
    }
  }

  /// Stops Adhan sound playback
  Future<void> stopAdhan() async {
    try {
      if (kDebugMode) {
        debugPrint('🔇 [AUDIO SERVICE] Stopping Adhan sound playback.');
      }
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [AUDIO SERVICE] Error stopping Adhan sound: $e');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
