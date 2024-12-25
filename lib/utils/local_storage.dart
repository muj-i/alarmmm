import 'dart:convert';
import 'dart:developer';

import 'package:alarmmm/model/alarm_model.dart';
import 'package:get_storage/get_storage.dart';

abstract class LocalStorage {
  static final _storage = GetStorage();

  // Save a list of AlarmModel objects
  static Future<void> setTimeListToLocalStorage(
      String key, List<AlarmModel> times) async {
    try {
      // Convert the list of AlarmModel to a list of maps (JSON)
      final jsonString = jsonEncode(times.map((e) => e.toJson()).toList());
      await _storage.write(key, jsonString);
      log("List of times saved to local storage: $times");
    } catch (e) {
      log("Error saving list of times to local storage: $e");
    }
  }

  // Retrieve a list of AlarmModel objects
  static Future<List<AlarmModel>?> getTimeListFromLocalStorage(
      String key) async {
    try {
      final jsonString = await _storage.read(key);
      if (jsonString != null) {
        // Decode the JSON string and map it to a list of AlarmModel
        final List<dynamic> decodedList = jsonDecode(jsonString);
        final List<AlarmModel> times =
            decodedList.map((e) => AlarmModel.fromJson(e)).toList();
        log("List of times retrieved from local storage: $times");
        return times;
      }
    } catch (e) {
      log("Error retrieving list of times from local storage: $e");
    }
    return null;
  }

  static clearStorage() {
    _storage.erase();
  }
}
