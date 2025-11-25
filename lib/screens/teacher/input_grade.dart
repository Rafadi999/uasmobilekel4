import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputScoreScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const InputScoreScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  _InputScoreScreenState createState() => _InputScoreScreenState();
}

class _InputScoreScreenState extends State<InputScoreScreen> {
  String? selectedClass;
  String? selectedSubject;

  final TextEditingController nilaiController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // AMBIL DATA KELAS
  Stream<List<String>> getClasses() {
    return _db.collection("kelas").snapshots().map(
      (snap) => snap.docs.map((d) => d["nama"].toString()).toList(),
    );
  }

  // AMBIL DATA SISWA PER KELAS
  Stream<QuerySnapshot> getStudents() {
    return _db
        .collection("users")
        .where("role", isEqualTo: "siswa")
        .where("kelas", isEqualTo: selectedClass)
        .snapshots();
  }

  // SIMPAN NILAI
  Future<void> saveScore(String studentId, String nilai) async {
    await _db.collection("nilai").add({
      "siswaId": studentId,
      "guruId": widget.teacherId,
      "guruNama": widget.teacherName,
      "pelajaran": selectedSubject,
      "kelas": selectedClass,
      "nilai": int.tryParse(nilai) ?? 0,
      "tanggal": DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Nilai Siswa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PILIH KELAS
            StreamBuilder<List<String>>(
              stream: getClasses(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField(
                  value: selectedClass,
                  hint: const Text("Pilih Kelas"),
                  items: snap.data!
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value.toString();
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // PILIH MAPEL
            DropdownButtonFormField(
              value: selectedSubject,
              hint: const Text("Pilih Mata Pelajaran"),
              items: const [
                DropdownMenuItem(value: "Matematika", child: Text("Matematika")),
                DropdownMenuItem(value: "B. Indonesia", child: Text("B. Indonesia")),
                DropdownMenuItem(value: "B. Inggris", child: Text("B. Inggris")),
                DropdownMenuItem(value: "IPA", child: Text("IPA")),
                DropdownMenuItem(value: "IPS", child: Text("IPS")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSubject = value.toString();
                });
              },
            ),

            const SizedBox(height: 20),

            if (selectedClass != null && selectedSubject != null)
              Expanded(
                child: StreamBuilder(
                  stream: getStudents(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final students = snap.data!.docs;

                    if (students.isEmpty) {
                      return const Center(child: Text("Tidak ada siswa di kelas ini"));
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (ctx, i) {
                        final s = students[i];
                        final siswaId = s.id;
                        final nama = s["nama"];

                        final controller = TextEditingController();

                        return Card(
                          child: ListTile(
                            title: Text(nama),
                            subtitle: Text("ID: $siswaId"),
                            trailing: SizedBox(
                              width: 80,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "0-100",
                                ),
                                onSubmitted: (value) async {
                                  await saveScore(siswaId, value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Nilai $nama disimpan")),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
