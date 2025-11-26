<<<<<<< HEAD
// lib/screens/teacher/input_grade.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grade.dart';
import '../../providers/grade_provider.dart';

class InputGradeScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String subject;
  final Grade? existingGrade; // jika edit, pass grade

  const InputGradeScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.subject,
    this.existingGrade,
  });

  @override
  State<InputGradeScreen> createState() => _InputGradeScreenState();
}

class _InputGradeScreenState extends State<InputGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tugasCtrl = TextEditingController();
  final _utsCtrl = TextEditingController();
  final _uasCtrl = TextEditingController();

  double? _nilaiAkhir;
  String? _predikat;

  @override
  void initState() {
    super.initState();
    if (widget.existingGrade != null) {
      _tugasCtrl.text = widget.existingGrade!.tugas.toString();
      _utsCtrl.text = widget.existingGrade!.uts.toString();
      _uasCtrl.text = widget.existingGrade!.uas.toString();
      _hitung();
    }
  }

  void _hitung() {
    final t = double.tryParse(_tugasCtrl.text) ?? 0;
    final u = double.tryParse(_utsCtrl.text) ?? 0;
    final a = double.tryParse(_uasCtrl.text) ?? 0;
    final nilai = t * .3 + u * .3 + a * .4;
    String p;
    if (nilai >= 85) p = 'A';
    else if (nilai >= 75) p = 'B';
    else if (nilai >= 65) p = 'C';
    else p = 'D';

    setState(() {
      _nilaiAkhir = nilai;
      _predikat = p;
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<GradeProvider>(context, listen: false);
    final grade = Grade(
      id: widget.existingGrade?.id ?? '',
      studentId: widget.studentId,
      subject: widget.subject,
      tugas: double.tryParse(_tugasCtrl.text) ?? 0,
      uts: double.tryParse(_utsCtrl.text) ?? 0,
      uas: double.tryParse(_uasCtrl.text) ?? 0,
    );

    if (widget.existingGrade == null) {
      await provider.addGrade(grade);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai ditambahkan')));
    } else {
      await provider.updateGrade(grade);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai diperbarui')));
    }

    Navigator.pop(context);
=======
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
>>>>>>> d96931a40b2aa92daa8bfb1f447f27d5d15e9a36
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: Text('Input Nilai - ${widget.subject}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Siswa: ${widget.studentName}'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tugasCtrl,
                decoration: const InputDecoration(labelText: 'Nilai Tugas'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                onChanged: (_) => _hitung(),
              ),
              TextFormField(
                controller: _utsCtrl,
                decoration: const InputDecoration(labelText: 'Nilai UTS'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                onChanged: (_) => _hitung(),
              ),
              TextFormField(
                controller: _uasCtrl,
                decoration: const InputDecoration(labelText: 'Nilai UAS'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                onChanged: (_) => _hitung(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: const Text('Hitung'),
                onPressed: _hitung,
              ),
              const SizedBox(height: 8),
              if (_nilaiAkhir != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nilai Akhir: ${_nilaiAkhir!.toStringAsFixed(2)}'),
                    Text('Predikat: $_predikat'),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpan,
                child: const Text('Simpan Nilai'),
              ),
            ],
          ),
=======
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
>>>>>>> d96931a40b2aa92daa8bfb1f447f27d5d15e9a36
        ),
      ),
    );
  }
}
