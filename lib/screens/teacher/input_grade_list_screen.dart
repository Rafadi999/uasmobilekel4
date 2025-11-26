// lib/screens/teacher/input_grade_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student.dart';
import '../nilai/input_nilai_form.dart';

class InputGradeListScreen extends StatelessWidget {
  final String subject;
  final String teacherId;

  const InputGradeListScreen({
    super.key,
    required this.subject,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Siswa - $subject"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "siswa")
            .orderBy("nama")
            .snapshots(),
        builder: (context, snap) {
          // 🔹 Debug logs
          if (snap.hasError) {
            print("Firestore error: ${snap.error}");
            return Center(child: Text("Terjadi error: ${snap.error}"));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final studentsData = snap.data!.docs;

          if (studentsData.isEmpty) {
            return const Center(child: Text("Tidak ada siswa"));
          }

          return ListView.builder(
            itemCount: studentsData.length,
            itemBuilder: (context, i) {
              final s = studentsData[i];

              // Buat objek Student, fallback jika field kosong
              final siswa = Student(
                id: s.id,
                nis: s.get("nis") ?? '',
                nama: s.get("nama") ?? '',
                kelas: s.get("kelas") ?? '',
                email: s.get("email") ?? '',
                jurusan: s.get("jurusan") ?? '',
              );

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(siswa.nama),
                  subtitle: Text("Kelas: ${siswa.kelas}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InputNilaiForm(
                          siswa: siswa,
                          mapel: subject,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
