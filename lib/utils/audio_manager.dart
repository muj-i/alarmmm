import 'package:audioplayers/audioplayers.dart';

AudioPlayer audioPlayer = AudioPlayer();

const alarmClock = 'audios/alarm_clock.mp3';
const alarm = 'audios/alarm.mp3';
const alarmEcho = 'audios/alarm_echo.mp3';
const alarmBang = 'audios/alarm_bang.mp3';

playAudio({required double setVolume, String? alarmTone}) async {
  if (!isPlaying()) {
    audioPlayer.setSourceAsset(alarmTone ?? alarmClock);
    audioPlayer.setVolume(setVolume);
    audioPlayer.play(AssetSource(alarmTone ?? alarmClock));
    audioPlayer.onPlayerComplete.listen((event) {
      audioPlayer.play(AssetSource(alarmTone ?? alarmClock));
    });
  }
}

stopAudio() async {
  audioPlayer.state = PlayerState.stopped;
  audioPlayer.stop();
}

isPlaying() {
  return audioPlayer.state == PlayerState.playing;
}
