import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Announcement> _announcements = [];

  List<Announcement> get announcements => _announcements;

  AnnouncementProvider() {
    _firestoreService.getAnnouncements().listen((data) {
      _announcements = data;
      notifyListeners();
    });
  }

  Future<void> add(Announcement announcement) async {
    await _firestoreService.addAnnouncement(announcement);
  }

  Future<void> update(Announcement announcement) async {
    await _firestoreService.updateAnnouncement(announcement);
  }

  Future<void> delete(String id) async {
    await _firestoreService.deleteAnnouncement(id);
  }
}