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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }
}
