import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Student>> getStudents() {
    return _db.collection('users').where('role', isEqualTo: 'siswa').snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Student.fromMap(doc.id, doc.data()))
      .toList());
  }

  Future<void> addStudent(Student student) async {
    await _db.collection('users').add(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    await _db.collection('users').doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _db.collection('users').doc(id).delete();
  }
}