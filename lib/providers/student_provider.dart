import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ambil data siswa dengan urutan terbaru di atas
  Stream<List<Student>> getStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'siswa')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addStudent(Student student) async {
    await _db.collection('users').add({
      ...student.toMap(),
      'createdAt': FieldValue.serverTimestamp(), // penting!
    });
  }

  Future<void> updateStudent(Student student) async {
    await _db.collection('users').doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _db.collection('users').doc(id).delete();
  }
}