import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/input_grade_list_screen.dart'; // nanti kamu sesuaikan tujuan navigasinya

class SelectMapelScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const SelectMapelScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<SelectMapelScreen> createState() => _SelectMapelScreenState();
}

class _SelectMapelScreenState extends State<SelectMapelScreen> {
  String? selectedMapel;

  Stream<List<String>> getMapel() {
    return FirebaseFirestore.instance
        .collection("mapel")
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d["nama"].toString())
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pilih Mata Pelajaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<List<String>>(
              stream: getMapel(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                final mapel = snap.data!;

                if (mapel.isEmpty) {
                  return const Text(
                    "Tidak ada data mata pelajaran.\nTambahkan koleksi 'mapel' di Firestore.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  );
                }

                return DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Pilih Mata Pelajaran",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMapel,
                  items: mapel
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedMapel = val.toString();
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: selectedMapel == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InputGradeListScreen(
                            subject: selectedMapel!,
                            teacherId: widget.teacherId,
                          ),
                        ),
                      );
                    },
              child: const Text("Lanjut"),
            )
          ],
        ),
      ),
    );
  }
}
