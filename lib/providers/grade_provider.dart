// lib/providers/grade_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grade.dart';

class GradeProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream semua nilai untuk satu siswa (dipakai di rapor)
  Stream<List<Grade>> getNilaiByStudent(String studentId) {
    return _db
        .collection('nilai')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Grade.fromMap(d.id, Map<String, dynamic>.from(d.data())))
            .toList());
  }

  // Stream semua nilai (opsional: untuk guru menampilkan daftar nilai)
  Stream<List<Grade>> getAllNilai() {
    return _db.collection('nilai').snapshots().map((snap) => snap.docs
        .map((d) => Grade.fromMap(d.id, Map<String, dynamic>.from(d.data())))
        .toList());
  }

  // Tambah nilai baru
  Future<DocumentReference> addGrade(Grade g) async {
    final map = g.toMap();
    // hitung nilaiAkhir & predikat jika mau simpan juga (optional)
    final nilaiAkhir = (g.tugas * .3) + (g.uts * .3) + (g.uas * .4);
    final predikat = _konversiPredikat(nilaiAkhir);

    map['nilaiAkhir'] = nilaiAkhir;
    map['predikat'] = predikat;

    return await _db.collection('nilai').add(map);
  }

  // Update nilai (mengharapkan g.id diisi)
  Future<void> updateGrade(Grade g) async {
    if (g.id.isEmpty) throw Exception('Grade.id kosong saat update');
    final map = g.toMap();
    final nilaiAkhir = (g.tugas * .3) + (g.uts * .3) + (g.uas * .4);
    final predikat = _konversiPredikat(nilaiAkhir);

    map['nilaiAkhir'] = nilaiAkhir;
    map['predikat'] = predikat;

    await _db.collection('nilai').doc(g.id).update(map);
  }

  // Hapus nilai
  Future<void> deleteGrade(String id) async {
    await _db.collection('nilai').doc(id).delete();
  }

  String _konversiPredikat(double nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 75) return 'B';
    if (nilai >= 65) return 'C';
    return 'D';
  }
}
