import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Announcement>> getAnnouncements() {
    return _db
        .collection('announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) =>
                Announcement.fromMap(doc.id, doc.data()))
            .toList()
        );
  }

  Future<void> addAnnouncement(Announcement announcement) async {
    await _db.collection('announcements').add(announcement.toMap());
  }

  Future<void> updateAnnouncement(Announcement announcement) async {
    await _db.collection('announcements')
        .doc(announcement.id)
        .update(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }
}