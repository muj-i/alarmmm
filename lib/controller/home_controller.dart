import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:alarmmm/alarm_ringing_screen.dart';
import 'package:alarmmm/model/alarm_model.dart';
import 'package:alarmmm/utils/audio_manager.dart';
import 'package:alarmmm/utils/local_storage.dart';
import 'package:alarmmm/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:local_notification/local_notification.dart';
import 'package:solve_24_game/solve_24_game.dart';

// class HomeController extends GetxController {
//   static HomeController get to => Get.put(HomeController());

  RxList<AlarmModel> alarmList = <AlarmModel>[].obs;
  RxList alarmTones = [].obs;
  RxString alarmTone = ''.obs;
  Timer? timer;

  TextEditingController titleController = TextEditingController();

  _playAlarm(tone) {
    playAudio(setVolume: 200.0, alarmTone: tone);
  }

  stopAlarm() {
    stopAudio();
  }

  clearAlarmList() {
    alarmList.clear();
    sortArray();
  }

  deleteIndividualAlarm(int index) {
    alarmList.removeAt(index);
    sortArray();
  }

  // @override
  void onInit() {
    getAlarmList();
    startAlarmListener();
    alarmTones.addAll([alarmClock, alarm, alarmEcho, alarmBang]);
    // super.onInit();
  }

  // @override
  // void onClose() {
  //   _timer?.cancel();
  //   super.onClose();
  // }

  addAlarm(DateTime dateTime, String tone) {
    alarmList.add(AlarmModel(
      time: dateTime.toIso8601String(),
      title:
          titleController.text.isEmpty ? 'Alarm' : titleController.text.trim(),
      isEnable: true,
      alarmTone: tone,
    ));

    final timeLeft = dateTime.difference(DateTime.now());
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes.remainder(60);
    final seconds = timeLeft.inSeconds.remainder(60);
    Toast.show('Time left for the alarm: ${hours}h ${minutes}m ${seconds}s');
    sortArray();
    updateAlarmList(purpose: 'time', dateTime: dateTime);
  }

  getAlarmList() async {
    final times = await LocalStorage.getTimeListFromLocalStorage('alarm');
    if (times != null) {
      alarmList.assignAll(times
          .map((e) => AlarmModel(
              time: e.time,
              title: e.title,
              isEnable: e.isEnable,
              alarmTone: e.alarmTone))
          .toList());
    }
  }

  // Check and run alarm if the current time matches an alarm time
  void _checkAlarms() {
    if (alarmList.isNotEmpty) {
      final now = DateTime.now();

      // Find the alarm that matches the current time (to the minute)
      alarmList.firstWhere(
        (alarmTime) {
          final alarmDateTime = DateTime.tryParse(alarmTime.time);
          if (alarmDateTime != null && _isTimeMatching(alarmDateTime, now)) {
            if (alarmTime.isEnable) {
              _playAlarm(alarmTime.alarmTone);
              LocalNotification.showLocalNotification(Random().nextInt(1000),
                  alarmTime.title, formatTime(alarmTime.time));
              Get.offAll(() => AlarmRingingScreen(alarmTime));
              alarmTime.isEnable = false;
              updateAlarmList(
                  purpose: 'complete',
                  dateTime: DateTime.tryParse(alarmTime.time));
              dev.log('Ringing alarm for the time: $alarmTime');
            }
            return true;
          }
          return false;
        },
        orElse: () => AlarmModel(
            time: '',
            title: 'No Alarm',
            isEnable: false,
            alarmTone: alarmClock),
      );

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

  void startAlarmListener() {
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

  void updateAlarmList({required String purpose, DateTime? dateTime}) {
    LocalStorage.setTimeListToLocalStorage(
        'alarm',
        alarmList
            .map((e) => AlarmModel(
                  time: e.time,
                  title: e.title,
                  isEnable: e.isEnable,
                  alarmTone: e.alarmTone,
                ))
            .toList());
    if (purpose == 'time') {
      final timeLeft = dateTime!.difference(DateTime.now());
      final hours = timeLeft.inHours;
      final minutes = timeLeft.inMinutes.remainder(60);
      final seconds = timeLeft.inSeconds.remainder(60);
      Toast.show('Time left for the alarm: ${hours}h ${minutes}m ${seconds}s');
    } else if (purpose == 'switch') {
      Toast.show('Alarm ${alarmList.last.isEnable ? 'enabled' : 'disabled'}');
    } else {
      dev.log('Unknown purpose: $purpose');
    }
  }

  sortArray() {
    alarmList.sort((a, b) {
      final aTime = DateTime.tryParse(a.time);
      final bTime = DateTime.tryParse(b.time);
      return aTime!.compareTo(bTime!);
    });
    // updateAlarmList(purpose: 'sort');
  }

  RxString randomProblem = ''.obs;
  RxInt randomNum = 0.obs;

  TextEditingController answerController = TextEditingController();
  genrateRandomProblems() {
    randomNum.value = Random().nextInt(50);
    // Generate a random number
    for (int i = 0; i < 4; i++) {
      // Generate random solutions
      final solutions = solve(
          List.generate(4, (index) => Random().nextInt(10) + 1),
          randomNum.value);
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

  getAudioTitle(String tone) {
    switch (tone) {
      case alarmClock:
        return 'Alarm Clock';
      case alarm:
        return 'Alarm';
      case alarmEcho:
        return 'Alarm Echo';
      case alarmBang:
        return 'Alarm Bang';
      default:
        return 'Unknown';
    }
  }
// }
