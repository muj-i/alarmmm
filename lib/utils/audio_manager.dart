import 'package:audioplayers/audioplayers.dart';

AudioPlayer audioPlayer = AudioPlayer();

const loudAlarmSound = 'audios/loud_alarm_sound.mp3';

playAudio({required double setVolume}) async {
  if (!isPlaying()) {
    audioPlayer.setSourceAsset(loudAlarmSound);
    audioPlayer.setVolume(setVolume);
    audioPlayer.play(AssetSource(loudAlarmSound));
    audioPlayer.onPlayerComplete.listen((event) {
      audioPlayer.play(AssetSource(loudAlarmSound));
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
