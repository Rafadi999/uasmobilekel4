import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';
import '../../../models/nilai.dart';

class StudentNilaiScreen extends StatelessWidget {
  const StudentNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final siswaId = user?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Nilai Saya")),
      body: StreamBuilder<List<Nilai>>(
        stream: FirestoreService().streamNilaiByStudent(siswaId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final nilaiList = snapshot.data!;

          if (nilaiList.isEmpty) {
            return const Center(
              child: Text("Belum ada nilai yang tersedia"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: nilaiList.length,
            itemBuilder: (context, index) {
              final n = nilaiList[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    n.mapel,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tugas: ${n.tugas}"),
                        Text("UTS: ${n.uts}"),
                        Text("UAS: ${n.uas}"),
                        Text("Nilai Akhir: ${n.nilaiAkhir}"),
                        Text("Predikat: ${n.predikat}"),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
