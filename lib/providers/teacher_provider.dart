import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/teacher.dart';

class TeacherProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ambil data guru terurut terbaru di atas
  Stream<List<Teacher>> getTeachers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'guru')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Teacher.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Tambah guru baru lengkap dengan createdAt
  Future<void> addTeacher(Teacher teacher) async {
    await _db.collection('users').add({
      ...teacher.toMap(),
      'createdAt': FieldValue.serverTimestamp(), // WAJIB agar sorting berfungsi
    });
  }

  /// Update data guru
  Future<void> updateTeacher(Teacher teacher) async {
    await _db
        .collection('users')
        .doc(teacher.id)
        .update(teacher.toMap());
  }

  /// Hapus data guru
  Future<void> deleteTeacher(String id) async {
    await _db
        .collection('users')
        .doc(id)
        .delete();
  }
}