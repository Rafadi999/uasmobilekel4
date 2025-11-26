import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/student.dart';
import 'input_nilai_form.dart';

class SelectSiswaScreen extends StatelessWidget {
  final String mapel;

  const SelectSiswaScreen({super.key, required this.mapel});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text("Pilih Siswa – $mapel")),
      body: StreamBuilder<List<Student>>(
        stream: fs.getStudentsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final siswaList = snapshot.data!;

          return ListView.builder(
            itemCount: siswaList.length,
            itemBuilder: (context, index) {
              final s = siswaList[index];
              return ListTile(
                title: Text(s.nama),
                subtitle: Text(s.kelas),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InputNilaiForm(
                        siswa: s,
                        mapel: mapel,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
