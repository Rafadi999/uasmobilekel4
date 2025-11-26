import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  String id;
  String guru;
  String hari;
  String idguru;
  String idkelas;
  String namakelas;
  String pelajaran;
  String role;
  String waktumulai;
  String waktuselesai;

  Schedule({
    required this.id,
    required this.guru,
    required this.hari,
    required this.idguru,
    required this.idkelas,
    required this.namakelas,
    required this.pelajaran,
    required this.role,
    required this.waktumulai,
    required this.waktuselesai,
  });

  /// ✔ DIPAKAI OLEH FIRESTORE SNAPSHOT
  factory Schedule.fromFirestore(String id, Map<String, dynamic> data) {
    return Schedule(
      id: id,
      guru: data['guru'] ?? '',
      hari: data['hari'] ?? '',
      idguru: data['idguru'] ?? '',
      idkelas: data['idkelas'] ?? '',
      namakelas: data['namakelas'] ?? '',
      pelajaran: data['pelajaran'] ?? '',
      role: data['role'] ?? '',
      waktumulai: data['waktumulai'] ?? '',
      waktuselesai: data['waktuselesai'] ?? '',
    );
  }

  /// ✔ Tambahkan ini agar error Schedule.fromMap hilang
  factory Schedule.fromMap(String id, Map<String, dynamic> data) {
    return Schedule(
      id: id,
      guru: data['guru'] ?? '',
      hari: data['hari'] ?? '',
      idguru: data['idguru'] ?? '',
      idkelas: data['idkelas'] ?? '',
      namakelas: data['namakelas'] ?? '',
      pelajaran: data['pelajaran'] ?? '',
      role: data['role'] ?? '',
      waktumulai: data['waktumulai'] ?? '',
      waktuselesai: data['waktuselesai'] ?? '',
    );
  }

  /// ✔ Untuk add / update
  Map<String, dynamic> toMap() {
    return {
      'guru': guru,
      'hari': hari,
      'idguru': idguru,
      'idkelas': idkelas,
      'namakelas': namakelas,
      'pelajaran': pelajaran,
      'role': role,
      'waktumulai': waktumulai,
      'waktuselesai': waktuselesai,
    };
  }
}
