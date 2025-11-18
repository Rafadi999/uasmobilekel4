import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';

class StudentProvider extends ChangeNotifier {
  final FirestoreService _svc = FirestoreService();
  final List<Student> items = [];

  Stream<QuerySnapshot> streamAll() => FirebaseFirestore.instance.collection('students').snapshots();

  Future<void> add(Student s) => _svc.addData('students', s.toMap());
  Future<void> update(Student s) => _svc.updateData('students', s.id, s.toMap());
  Future<void> delete(String id) => _svc.deleteData('students', id);
}