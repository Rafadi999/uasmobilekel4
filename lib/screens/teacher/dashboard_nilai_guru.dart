import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/nilai.dart';

class DashboardNilaiGuru extends StatelessWidget {
  const DashboardNilaiGuru({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Nilai Siswa"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<List<Nilai>>(
        stream: fs.streamSemuaNilai(), // ⬅️ AUTO UPDATE REALTIME
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada nilai"));
          }

          final nilaiList = snapshot.data!;

          return ListView.builder(
            itemCount: nilaiList.length,
            itemBuilder: (context, index) {
              final n = nilaiList[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${n.mapel} - Predikat: ${n.predikat}"),
                  subtitle: Text(
                    "Tugas: ${n.tugas} | UTS: ${n.uts} | UAS: ${n.uas}\n"
                    "Nilai Akhir: ${n.nilaiAkhir.toStringAsFixed(1)}",
                  ),
                  trailing: Text("Siswa: ${n.siswaId}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
