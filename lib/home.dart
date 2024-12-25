import 'package:alarmmm/controller/home_controller.dart';
import 'package:alarmmm/utils/toast.dart';
import 'package:alarmmm/widgets/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALARMMM...'),
        toolbarHeight: 90,
        backgroundColor: Colors.red.shade50,
        actions: [
          Obx(() {
            return Visibility(
              visible: controller.alarmList.isNotEmpty,
              replacement: const SizedBox(),
              child: Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: () {
                      showDeleteAllDialog(context);
                    }),
              ),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          return Column(
            children: [
              Visibility(
                visible: controller.alarmList.isNotEmpty,
                replacement: const Center(child: Text('No alarms in the list')),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.alarmList.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      key: const ValueKey(0),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {
                          controller.deleteIndividualAlarm(index);
                        }),
                        children: [
                          SlidableAction(
                            onPressed: (_) =>
                                controller.deleteIndividualAlarm(index),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            autoClose: true,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: InkWell(
                        overlayColor:
                            WidgetStateProperty.all(Colors.red.shade100),
                        onTap: () {
                          showDateTimePicker(context,
                                  currentDateTime: DateTime.parse(
                                      controller.alarmList[index].time))
                              .then((dateTime) {
                            if (dateTime != null) {
                              if (dateTime.minute == DateTime.now().minute &&
                                  dateTime.hour == DateTime.now().hour) {
                                Toast.show(
                                    'Cannot set alarm for the current time');
                                return;
                              }
                              if (controller.alarmList.any((element) {
                                final DateTime elementTime =
                                    DateTime.parse(element.time);
                                return elementTime.day == dateTime.day &&
                                    elementTime.hour == dateTime.hour &&
                                    elementTime.minute == dateTime.minute;
                              })) {
                                Toast.show(
                                    'Alarm already exists for this time');
                                return;
                              }
                              controller.alarmList[index].time =
                                  dateTime.toIso8601String();
                              controller.updateAlarmList();
                            }
                          });
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              border: const Border(
                                bottom:
                                    BorderSide(color: Colors.white, width: .5),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.formatTime(
                                          controller.alarmList[index].time),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      controller.formatDate(
                                          controller.alarmList[index].time),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                CupertinoSwitch(
                                    activeColor: Colors.red,
                                    value: controller.alarmList[index].isEnable,
                                    onChanged: (value) {
                                      controller.alarmList[index].isEnable =
                                          value;
                                      controller.updateAlarmList();
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: controller.isAlarmPlaying.value ? 120 : 60),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
                child: const Icon(Icons.add_alarm),
                onPressed: () async {
                  final DateTime? dateTime = await showDateTimePicker(context);

                  if (dateTime != null) {
                    if (dateTime.minute == DateTime.now().minute &&
                        dateTime.hour == DateTime.now().hour) {
                      Toast.show('Cannot set alarm for the current time');
                      return;
                    }
                    if (controller.alarmList.any((element) {
                      final DateTime elementTime = DateTime.parse(element.time);
                      return elementTime.day == dateTime.day &&
                          elementTime.hour == dateTime.hour &&
                          elementTime.minute == dateTime.minute;
                    })) {
                      Toast.show('Alarm already exists for this time');
                      return;
                    }
                    controller.addAlarm(dateTime);
                  }
                }),
            Visibility(
              visible: controller.isAlarmPlaying.value,
              child: const SizedBox(height: 8),
            ),
            Visibility(
              visible: controller.isAlarmPlaying.value,
              child: FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () {
                  controller.genrateRandomProblems();
                  showProblemDialog(context, controller.randomProblem.value);
                },
              ),
            ),
          ],
        );
      }),
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
              Text(problem),
              TextField(
                controller: controller.answerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter your answer',
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

  showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete all alarms?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.clearAlarmList();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
