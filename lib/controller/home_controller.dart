import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:alarmmm/model/alarm_model.dart';
import 'package:alarmmm/utils/audio_manager.dart';
import 'package:alarmmm/utils/local_storage.dart';
import 'package:alarmmm/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:solve_24_game/solve_24_game.dart';

class HomeController extends GetxController {
  RxList<AlarmModel> alarmList = <AlarmModel>[].obs;
  Timer? timer;

  RxBool isAlarmPlaying = false.obs;

  _playAlarm() {
    playAudio(setVolume: 200.0);
    isAlarmPlaying.value = true;
  }

  stopAlarm() {
    stopAudio();
    isAlarmPlaying.value = false;
  }

  clearAlarmList() {
    alarmList.clear();
    sortArray();
  }

  deleteIndividualAlarm(int index) {
    alarmList.removeAt(index);
    sortArray();
  }

  @override
  void onInit() {
    getAlarmList();
    _startAlarmListener();
    super.onInit();
  }

  // @override
  // void onClose() {
  //   _timer?.cancel();
  //   super.onClose();
  // }

  addAlarm(DateTime dateTime) {
    alarmList.add(AlarmModel(
        time: dateTime.toIso8601String(), title: 'Alarm', isEnable: true));
    sortArray();
  }

  getAlarmList() async {
    final times = await LocalStorage.getTimeListFromLocalStorage('alarm');
    if (times != null) {
      alarmList.assignAll(times
          .map((e) => AlarmModel(time: e.time, title: 'Alarm', isEnable: true))
          .toList());
    }
  }

  // Check and run alarm if the current time matches an alarm time
  void _checkAlarms() {
    if (alarmList.isNotEmpty) {
      final now = DateTime.now();

      // Find the alarms that match the current time (to the minute)
      alarmList.removeWhere((alarmTime) {
        final alarmDateTime = DateTime.tryParse(alarmTime.time);
        if (alarmDateTime != null && _isTimeMatching(alarmDateTime, now)) {
          if ((alarmTime.isEnable)) {
            _playAlarm();
            dev.log('Ringing alarm for the time: $alarmTime');
          } else {
            Toast.show(
                'You have an alarm at ${formatTime(alarmTime.time)}, but it is disabled');
          }

          return true; // Remove the alarm after ringing
        }
        return false;
      });

      sortArray();
    }
  }

  bool _isTimeMatching(DateTime alarmTime, DateTime now) {
    return alarmTime.year == now.year &&
        alarmTime.month == now.month &&
        alarmTime.day == now.day &&
        alarmTime.hour == now.hour &&
        alarmTime.minute == now.minute;
  }

  void _startAlarmListener() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkAlarms(); // Check for alarms every second
    });
  }

  String formatTime(String dateTime) {
    final parsedDateTime = DateTime.tryParse(dateTime);
    final hour = parsedDateTime?.hour;
    final minute = parsedDateTime?.minute.toString().padLeft(2, '0');
    final period = hour! >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }

  String formatDate(String dateTime) {
    final parsedDateTime = DateTime.tryParse(dateTime);
    return '${parsedDateTime?.day}/${parsedDateTime?.month}/${parsedDateTime?.year}';
  }

  void updateAlarmList() {
    LocalStorage.setTimeListToLocalStorage(
        'alarm',
        alarmList
            .map((e) =>
                AlarmModel(time: e.time, title: 'Alarm', isEnable: e.isEnable))
            .toList());
  }

  sortArray() {
    alarmList.sort((a, b) {
      final aTime = DateTime.tryParse(a.time);
      final bTime = DateTime.tryParse(b.time);
      return aTime!.compareTo(bTime!);
    });
    updateAlarmList();
  }

  RxString randomProblem = ''.obs;
  RxInt randomNum = 0.obs;
  
  TextEditingController answerController = TextEditingController();
  genrateRandomProblems() {
    randomNum.value = Random().nextInt(100);
    // Generate a random number
    for (int i = 0; i < 4; i++) {
      // Generate random solutions
      final solutions = solve(
          List.generate(4, (index) => Random().nextInt(10) + 1), randomNum.value);
      dev.log('Random number: $randomNum');
      dev.log('Generated solutions: $solutions');

      if (solutions.isNotEmpty) {
        // Pick a random solution from the list
        final randomIndex = Random().nextInt(solutions.length);
        randomProblem.value = solutions.toList()[randomIndex].toString();
        dev.log('Randomly selected problem: ${randomProblem.value}');
      } else {
        dev.log('No solutions generated.');
      }
    }
  }

  bool checkAnswer() {
    final answer = answerController.text;
    if (answer.isNotEmpty) {
      if (answer == randomNum.value.toString()) {
        Toast.show('Correct answer!');
        return true;
      } else {
        Toast.show('Incorrect answer. Try again.');
      }
    } else {
      Toast.show('Please enter an answer.');
    }
    return false;
  }
}
