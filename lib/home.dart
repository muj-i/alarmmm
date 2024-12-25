import 'package:alarmmm/controller/home_controller.dart';
import 'package:alarmmm/utils/local_storage.dart';
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
        title: const Text('A L A R M M M M M......'),
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
      body: Obx(() {
        return Visibility(
          visible: controller.alarmList.isNotEmpty,
          replacement: const Center(child: Text('No alarms in the list')),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
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
                                controller.alarmList[index].time =
                                    dateTime.toIso8601String();
                              }
                              if (context.mounted) {
                                controller.titleController.text =
                                    controller.alarmList[index].title;
                                showAlarmOtherInfoDialog(
                                  context,
                                  dateTime: dateTime,
                                  forUpdate: true,
                                  index: index,
                                );
                              }
                            }
                          });
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.shade50,
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
                                      controller.alarmList[index].title,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      controller.formatTime(
                                          controller.alarmList[index].time),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          controller.formatDate(
                                              controller.alarmList[index].time),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.music_note_rounded,
                                            size: 20),
                                        Text(
                                            controller.getAudioTitle(controller
                                                .alarmList[index].alarmTone),
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                                CupertinoSwitch(
                                  activeColor: Colors.red,
                                  value: controller.alarmList[index].isEnable,
                                  onChanged: (value) {
                                    controller.alarmList[index].isEnable =
                                        value;
                                    controller.updateAlarmList(
                                        purpose: 'switch');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
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
              if (context.mounted) {
                showAlarmOtherInfoDialog(context, dateTime: dateTime);
              }
            }
          }),
    );
  }

  showAlarmOtherInfoDialog(context,
      {required DateTime dateTime, bool forUpdate = false, int? index}) {
    return showDialog(
      context: context,
      builder: (context) {
        if (forUpdate) {
          controller.alarmTone.value = controller.alarmList[index!].alarmTone;
        } else {
          controller.alarmTone.value = controller.alarmTones[0];
        }
        return AlertDialog(
          title: const Text('Alarm Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Alarm Title',
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return PopupMenuButton(
                    itemBuilder: (context) {
                      return controller.alarmTones
                          .map((e) => PopupMenuItem(
                                value: e,
                                child: Text(controller.getAudioTitle(e)),
                              ))
                          .toList();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Text('Alarm Tone:',
                              style: TextStyle(fontSize: 16)),
                          const Icon(Icons.music_note_rounded, size: 20),
                          Text(
                              controller
                                  .getAudioTitle(controller.alarmTone.value),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    onSelected: (value) {
                      controller.alarmTone.value = value.toString();
                    });
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.titleController.clear();
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (forUpdate) {
                  controller.alarmList[index!].time =
                      dateTime.toIso8601String();
                  controller.alarmList[index].alarmTone =
                      controller.alarmTone.value;
                  controller.alarmList[index].title =
                      controller.titleController.text.trim();
                  controller.alarmList[index].isEnable = true;
                  controller.updateAlarmList(
                    purpose: 'time',
                    dateTime: dateTime,
                  );
                } else {
                  controller.addAlarm(dateTime, controller.alarmTone.value);
                }
                Navigator.pop(context);
                controller.titleController.clear();
                controller.alarmTone.value = '';
              },
              child: const Text('Save'),
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
                LocalStorage.clearStorage();
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
