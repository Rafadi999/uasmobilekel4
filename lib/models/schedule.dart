import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String guru;
  final String hari;
  final String idguru;
  final String idkelas;
  final String namakelas;
  final String pelajaran;
  final String role;
  final Timestamp? waktudibuat;
  final String waktumulai;
  final String waktuselesai;

  Schedule({
    required this.id,
    required this.guru,
    required this.hari,
    required this.idguru,
    required this.idkelas,
    required this.namakelas,
    required this.pelajaran,
    required this.role,
    this.waktudibuat,
    required this.waktumulai,
    required this.waktuselesai,
  });

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

  
  factory Schedule.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      guru: d['guru'] ?? '',
      hari: d['hari'] ?? '',
      idguru: d['idguru'] ?? '',
      idkelas: d['idkelas'] ?? '',
      namakelas: d['namakelas'] ?? '',
      pelajaran: d['pelajaran'] ?? '',
      role: d['role'] ?? 'all',
      waktudibuat: d['waktudibuat'] as Timestamp?,
      waktumulai: d['waktumulai'] ?? '',
      waktuselesai: d['waktuselesai'] ?? '',
    );
  }
  
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

  Map<String, dynamic> toMapForCreate() {
    return {
      'guru': guru,
      'hari': hari,
      'idguru': idguru,
      'idkelas': idkelas,
      'namakelas': namakelas,
      'pelajaran': pelajaran,
      'role': role,
      'waktudibuat': FieldValue.serverTimestamp(),
      'waktumulai': waktumulai,
      'waktuselesai': waktuselesai,
    };
  }

  Map<String, dynamic> toMapForUpdate() {
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
