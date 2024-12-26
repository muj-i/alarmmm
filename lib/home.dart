import 'package:alarmmm/controller/home_controller.dart';
import 'package:alarmmm/main.dart';
import 'package:alarmmm/utils/audio_manager.dart';
import 'package:alarmmm/utils/local_storage.dart';
import 'package:alarmmm/utils/toast.dart';
import 'package:alarmmm/widgets/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:local_notification/local_notification.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      onInit();
      await LocalNotification.permission('A L A R M M M M M.....')
          .then((_) async {
        if (context.mounted) await initializeService();
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('A L A R M M M M M......'),
        toolbarHeight: 90,
        backgroundColor: Colors.red.shade50,
        actions: [
          Obx(() {
            return Visibility(
              visible: alarmList.isNotEmpty,
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
          IconButton(
              onPressed: () async {
                await LocalNotification.permission('A L A R M M M M M.....')
                    .then((_) async {
                  if (context.mounted) await initializeService();
                });
              },
              icon: const Icon(Icons.notifications_active)),
        ],
      ),
      body: Obx(() {
        return Visibility(
          visible: alarmList.isNotEmpty,
          replacement: const Center(child: Text('No alarms in the list')),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: alarmList.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      key: const ValueKey(0),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {
                          deleteIndividualAlarm(index);
                        }),
                        children: [
                          SlidableAction(
                            onPressed: (_) => deleteIndividualAlarm(index),
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
                                  currentDateTime:
                                      DateTime.parse(alarmList[index].time))
                              .then((dateTime) {
                            if (dateTime != null) {
                              if (dateTime.minute == DateTime.now().minute &&
                                  dateTime.hour == DateTime.now().hour) {
                                Toast.show(
                                    'Cannot set alarm for the current time');
                                return;
                              }
                              if (alarmList.any((element) {
                                final DateTime elementTime =
                                    DateTime.parse(element.time);
                                return elementTime.day == dateTime.day &&
                                    elementTime.hour == dateTime.hour &&
                                    elementTime.minute == dateTime.minute;
                              })) {
                                alarmList[index].time =
                                    dateTime.toIso8601String();
                              }
                              if (context.mounted) {
                                titleController.text = alarmList[index].title;
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
                                      alarmList[index].title,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      formatTime(alarmList[index].time),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          formatDate(alarmList[index].time),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.music_note_rounded,
                                            size: 20),
                                        Text(
                                            getAudioTitle(
                                                alarmList[index].alarmTone),
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                                CupertinoSwitch(
                                  activeColor: Colors.red,
                                  value: alarmList[index].isEnable,
                                  onChanged: (value) {
                                    alarmList[index].isEnable = value;
                                    updateAlarmList(purpose: 'switch');
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
              if (alarmList.any((element) {
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
      barrierDismissible: false,
      builder: (context) {
        if (forUpdate) {
          alarmTone.value = alarmList[index!].alarmTone;
        } else {
          alarmTone.value = alarmTones[0];
        }
        return AlertDialog(
          title: const Text('Alarm Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Alarm Title',
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return PopupMenuButton(
                    itemBuilder: (context) {
                      return alarmTones
                          .map((e) => PopupMenuItem(
                                value: e,
                                child: Text(getAudioTitle(e)),
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
                          Text(getAudioTitle(alarmTone.value),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    onSelected: (value) {
                      alarmTone.value = value.toString();
                      playAudioOnce(alarmTone: value.toString());
                    });
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                titleController.clear();
                alarmTone.value = '';
                stopAudio();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (forUpdate) {
                  alarmList[index!].time = dateTime.toIso8601String();
                  alarmList[index].alarmTone = alarmTone.value;
                  alarmList[index].title = titleController.text.trim();
                  alarmList[index].isEnable = true;
                  updateAlarmList(
                    purpose: 'time',
                    dateTime: dateTime,
                  );
                } else {
                  addAlarm(dateTime, alarmTone.value);
                }
                stopAudio();
                Navigator.pop(context);
                titleController.clear();
                alarmTone.value = '';
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
                clearAlarmList();
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
