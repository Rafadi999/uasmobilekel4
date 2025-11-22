import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/firestore_service.dart';

class ScheduleProvider with ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Schedule> schedules = [];

  ScheduleProvider() {
    _listenToSchedules();
  }

  /// ============================
  /// LISTEN SEMUA JADWAL (ADMIN)
  /// ============================
  void _listenToSchedules() {
    _service.getJadwalStream().listen((data) {
      schedules = data;
      notifyListeners();
    });
  }

  /// =======================================
  /// STREAM UNTUK SISWA: Berdasarkan Kelas
  /// =======================================
  Stream<List<Schedule>> getSchedulesByClass(String className) {
    return _service.getJadwalByClass(className);
  }

  /// =======================================
  /// STREAM UNTUK GURU: Berdasarkan ID Guru
  /// =======================================
  Stream<List<Schedule>> getSchedulesByTeacher(String teacherId) {
    return _service.getJadwalByTeacher(teacherId);
  }

  /// ============================
  /// CRUD JADWAL
  /// ============================
  Future<void> addSchedule(Schedule schedule) async {
    await _service.addJadwal(schedule);
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _service.updateJadwal(schedule);
  }

  Future<void> deleteSchedule(String id) async {
    await _service.deleteJadwal(id);
  }
}