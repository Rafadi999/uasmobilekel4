import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grade.dart';

class GradeProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ambil nilai untuk 1 siswa
  Stream<List<Grade>> getNilaiByStudent(String siswaId) {
    return _db
        .collection('nilai')
        .where('siswaId', isEqualTo: siswaId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Grade.fromMap(d.id, d.data()))
            .toList());
  }

  // Tambah nilai
  Future<void> addGrade(Grade g) async {
    final map = g.toMap();

    final nilaiAkhir = g.finalScore;
    final predikat = g.predicate;

    map["nilaiAkhir"] = nilaiAkhir;
    map["predikat"] = predikat;

    await _db.collection('nilai').add(map);
  }

  // Update nilai
  Future<void> updateGrade(Grade g) async {
    if (g.id.isEmpty) return;

    final map = g.toMap();
    final nilaiAkhir = g.finalScore;
    final predikat = g.predicate;

    map["nilaiAkhir"] = nilaiAkhir;
    map["predikat"] = predikat;

    await _db.collection('nilai').doc(g.id).update(map);
  }

  // Hapus nilai
  Future<void> deleteGrade(String id) async {
    await _db.collection('nilai').doc(id).delete();
  }
}
