import 'package:alarmmm/controller/home_controller.dart';
import 'package:alarmmm/home.dart';
import 'package:alarmmm/model/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmRingingScreen extends GetView<HomeController> {
  const AlarmRingingScreen(this.alarmTime, {super.key});
  final AlarmModel alarmTime;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Alarm is ringing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.alarm,
                  size: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  alarmTime.title,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  controller.formatTime(alarmTime.time),
                  style:
                      const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
                Text(
                  controller.formatDate(alarmTime.time),
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.stop),
                      Text('Stop Alarm'),
                    ]),
                    onPressed: () {
                      controller.genrateRandomProblems();
                      showProblemDialog(context, controller.randomProblem.value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showProblemDialog(BuildContext context, String problem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Solve the problem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(problem,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              TextField(
                controller: controller.answerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter your answer',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                final isCorrect = controller.checkAnswer();
                if (isCorrect) {
                  controller.stopAlarm();
                  Navigator.pop(context);
                  Get.offAll(() => const Home());
                  controller.answerController.clear();
                }
              },
              child: const Text('Check'),
            ),
          ],
        );
      },
    );
  }
}
