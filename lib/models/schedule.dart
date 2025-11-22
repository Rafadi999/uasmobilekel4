import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String namakelas;
  final String pelajaran;
  final String guru;
  final String hari;
  final String waktumulai;
  final String waktuselesai;

  Schedule({
    required this.id,
    required this.namakelas,
    required this.pelajaran,
    required this.guru,
    required this.hari,
    required this.waktumulai,
    required this.waktuselesai,
  });

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      namakelas: data['namakelas'] ?? '',
      pelajaran: data['pelajaran'] ?? '',
      guru: data['guru'] ?? '',
      hari: data['hari'] ?? '',
      waktumulai: data['waktumulai'] ?? '',
      waktuselesai: data['waktuselesai'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namakelas': namakelas,
      'pelajaran': pelajaran,
      'guru': guru,
      'hari': hari,
      'waktumulai': waktumulai,
      'waktuselesai': waktuselesai,
    };
  }

  Schedule copyWith({
    String? id,
    String? namakelas,
    String? pelajaran,
    String? guru,
    String? hari,
    String? waktumulai,
    String? waktuselesai,
  }) {
    return Schedule(
      id: id ?? this.id,
      namakelas: namakelas ?? this.namakelas,
      pelajaran: pelajaran ?? this.pelajaran,
      guru: guru ?? this.guru,
      hari: hari ?? this.hari,
      waktumulai: waktumulai ?? this.waktumulai,
      waktuselesai: waktuselesai ?? this.waktuselesai,
    );
  }
}