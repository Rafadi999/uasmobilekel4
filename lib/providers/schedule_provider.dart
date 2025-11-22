import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  final _col = FirebaseFirestore.instance.collection('jadwal');

  // Admin: semua jadwal
  Stream<List<Schedule>> getSchedules() {
    return _col.snapshots().map(
      (snap) => snap.docs.map((doc) => Schedule.fromFirestore(doc)).toList()
    );
  }

  // Guru: filter nama guru
  Stream<List<Schedule>> getSchedulesByTeacher(String teacherName) {
    return _col
        .where('guru', isEqualTo: teacherName)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Schedule.fromFirestore(doc)).toList());
  }

  // Siswa: filter kelas
  Stream<List<Schedule>> getSchedulesByClass(String className) {
    return _col
        .where('namakelas', isEqualTo: className)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Schedule.fromFirestore(doc)).toList());
  }

  Future<void> addSchedule(Schedule schedule) async {
    final docRef = _col.doc();
    final newSchedule = schedule.copyWith(id: docRef.id);
    await docRef.set(newSchedule.toMap());
    notifyListeners();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _col.doc(schedule.id).update(schedule.toMap());
    notifyListeners();
  }

  Future<void> deleteSchedule(String id) async {
    await _col.doc(id).delete();
    notifyListeners();
  }
}