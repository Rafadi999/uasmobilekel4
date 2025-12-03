import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grade.dart';
import '../../providers/grade_provider.dart';

class InputGradeScreen extends StatefulWidget {
  final String siswaId;
  final String studentName;
  final String subject;
  final Grade? existingGrade;

  const InputGradeScreen({
    super.key,
    required this.siswaId,
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

    final nilai = t * 0.3 + u * 0.3 + a * 0.4;

    String pred;
    if (nilai >= 85) pred = "A";
    else if (nilai >= 75) pred = "B";
    else if (nilai >= 65) pred = "C";
    else pred = "D";

    setState(() {
      _nilaiAkhir = nilai;
      _predikat = pred;
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<GradeProvider>(context, listen: false);

    final grade = Grade(
      id: widget.existingGrade?.id ?? "",
      siswaId: widget.siswaId,
      mapel: widget.subject,
      tugas: double.tryParse(_tugasCtrl.text) ?? 0,
      uts: double.tryParse(_utsCtrl.text) ?? 0,
      uas: double.tryParse(_uasCtrl.text) ?? 0,
    );

    if (widget.existingGrade == null) {
      await provider.addGrade(grade);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nilai berhasil disimpan!")),
      );
    } else {
      await provider.updateGrade(grade);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nilai berhasil diperbarui!")),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Input Nilai - ${widget.subject}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // 🌿 Background gradient toska gelap
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E8A6B),
                  Color(0xFF0E5F4B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Blurred circle decorations
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            right: -90,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // 🌟 MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Nama siswa
                    Text(
                      "Siswa: ${widget.studentName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // === INPUT FIELD GLASS STYLE =====
                    _buildField("Nilai Tugas", _tugasCtrl),
                    _buildField("Nilai UTS", _utsCtrl),
                    _buildField("Nilai UAS", _uasCtrl),

                    const SizedBox(height: 25),

                    // Tombol Hitung
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.withOpacity(0.25),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _hitung,
                      child: const Text(
                        "Hitung Nilai",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    if (_nilaiAkhir != null) ...[
                      const SizedBox(height: 20),
                      _resultText("Nilai Akhir", _nilaiAkhir!.toStringAsFixed(2)),
                      _resultText("Predikat", _predikat ?? "-"),
                    ],

                    const SizedBox(height: 30),

                    // Tombol Simpan
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _simpan,
                      child: const Text(
                        "Simpan Nilai",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOM FIELD GLASSMORPHISM
  // ============================================================
  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Wajib diisi" : null,
              onChanged: (_) => _hitung(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _resultText(String title, String value) {
    return Text(
      "$title: $value",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}