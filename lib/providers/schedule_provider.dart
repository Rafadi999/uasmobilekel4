// lib/providers/schedule_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/firestore_service.dart';

class ScheduleProvider with ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  StreamSubscription<List<Schedule>>? _subscription;

  /// Universal untuk semua role
  /// role: 'admin'/'all' → tidak mem-filter
  /// role: 'guru' → gunakan idGuru
  /// role: 'siswa' → gunakan idKelas
  void loadSchedules(String role, {String? idGuru, String? idKelas}) {
    _subscription?.cancel();

    _subscription = _service
        .getScheduleByRole(role: role, idGuru: idGuru, idKelas: idKelas)
        .listen((data) {
      _schedules = data;
      notifyListeners();
    }, onError: (error) {
      // optional: handle errors (e.g. permission, connectivity)
      debugPrint('ScheduleProvider loadSchedules error: $error');
    });
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _service.addJadwal(schedule);
    // don't call notifyListeners() here — the stream listener will update automatically.
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _service.updateJadwal(schedule);
    // stream will reflect changes
  }

  Future<void> deleteSchedule(String id) async {
    await _service.deleteJadwal(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}