// lib/providers/schedule_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = 'jadwal';

  // Stream realtime, newest first (by createdAt)
  Stream<List<Schedule>> getSchedules() {
    return _db
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Schedule.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _db.collection(collectionName).add({
      ...schedule.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _db.collection(collectionName).doc(schedule.id).update({
      ...schedule.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSchedule(String id) async {
    await _db.collection(collectionName).doc(id).delete();
  }
}