import 'dart:io';

import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

Future<DateTime?> showDateTimePicker(
  BuildContext context, {
  DateTime? currentDateTime,
}) async {
  // For iOS, use OmniDateTimePicker
  if (Platform.isIOS) {
    if (context.mounted) {
      return await showOmniDateTimePicker(
        context: context,
        initialDate: currentDateTime ?? DateTime.now(),
        firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
        lastDate: DateTime.now().add(const Duration(days: 3652)),
        is24HourMode: false,
        isShowSeconds: false,
        minutesInterval: 1,
        secondsInterval: 1,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        constraints: const BoxConstraints(
          maxWidth: 350,
          maxHeight: 650,
        ),
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1.drive(
              Tween(begin: 0, end: 1),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
      );
    }
  } else {
    // For Android, combine DatePicker and TimePicker
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDateTime ?? DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2035),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              surface: Colors.red.shade50,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (context.mounted) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime:
              TimeOfDay.fromDateTime(currentDateTime ?? DateTime.now()),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.red,
                  surface: Colors.red.shade50,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          return DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      }
    }
  }

  return null;
}
