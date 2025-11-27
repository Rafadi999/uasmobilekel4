// lib/models/schedule.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String guru;
  final String idguru;
  final String hari;
  final String pelajaran;
  final String waktumulai;
  final String waktuselesai;
  final String idkelas;
  final String namakelas;
  final String role;
  final Timestamp? createdAt;

  Schedule({
    required this.id,
    required this.guru,
    required this.idguru,
    required this.hari,
    required this.pelajaran,
    required this.waktumulai,
    required this.waktuselesai,
    required this.idkelas,
    required this.namakelas,
    required this.role,
    this.createdAt,
  });

  factory Schedule.fromMap(String id, Map<String, dynamic> data) {
    return Schedule(
      id: id,
      guru: data['guru'] ?? '',
      idguru: data['idguru'] ?? '',
      hari: data['hari'] ?? '',
      pelajaran: data['pelajaran'] ?? '',
      waktumulai: data['waktumulai'] ?? '',
      waktuselesai: data['waktuselesai'] ?? '',
      idkelas: data['idkelas'] ?? '',
      namakelas: data['namakelas'] ?? '',
      role: data['role'] ?? 'all',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// NOTE:
  /// - When creating a new schedule locally to send to Firestore, you can pass createdAt: null
  ///   so Firestore will set server timestamp (see toMap()).
  Map<String, dynamic> toMap() {
    return {
      'guru': guru,
      'idguru': idguru,
      'hari': hari,
      'pelajaran': pelajaran,
      'waktumulai': waktumulai,
      'waktuselesai': waktuselesai,
      'idkelas': idkelas,
      'namakelas': namakelas,
      'role': role,
      // Use server timestamp when createdAt is null (new doc). If createdAt already exists,
      // we can set the timestamp value directly (Timestamp type).
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}