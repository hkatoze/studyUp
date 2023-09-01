import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_up/models/models.dart';

double heightP(BuildContext context, double value) {
  return MediaQuery.of(context).size.height * value;
}

double widthP(BuildContext context, double value) {
  return MediaQuery.of(context).size.width * value;
}

Color kPrimaryColor = Color(0XFF223170);

Color KSecondaryColor = Color(0XFFf7b15c);

saveNotififications(String newValue) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'notifications_list';
  List<String> newValues = [];
  List<String> oldValues = [];
  oldValues =
      await readNotifications() == null ? [] : await readNotifications();
  oldValues.add(newValue);
  newValues = oldValues;
  prefs.setStringList(key, newValues);
}

Future<List<String>> readNotifications() async {
  List<String> values = [];
  final prefs = await SharedPreferences.getInstance();
  final key = 'notifications_list';
  values =
      await prefs.getStringList(key) == null ? [] : prefs.getStringList(key)!;

  return values;
}

saveBookLength(int length) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'book_added_length';

  prefs.setInt(key, length);
}

Future<int> readBookLength() async {
  int value;
  final prefs = await SharedPreferences.getInstance();
  final key = 'book_added_length';

  value = await prefs.getInt(key) == null ? 0 : prefs.getInt(key)!;

  return value;
}
