import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String nama;
  final String tentang;
  final DateTime dibuat;
  final String targetRole; // ➜ Tambahkan field ini

  Announcement({
    required this.id,
    required this.nama,
    required this.tentang,
    required this.dibuat,
    required this.targetRole, // ➜ Tambahkan di constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'tentang': tentang,
      'dibuat': Timestamp.fromDate(dibuat),
      'targetRole': targetRole, // ➜ Simpan ke database
    };
  }

  factory Announcement.fromMap(String id, Map<String, dynamic> data) {
    return Announcement(
      id: id,
      nama: data['nama'] ?? '',
      tentang: data['tentang'] ?? '',
      dibuat: (data['dibuat'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetRole: data['targetRole'] ?? 'all', // ➜ Ambil dari database
    );
  }
}