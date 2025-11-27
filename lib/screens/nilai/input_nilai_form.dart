import 'package:flutter/material.dart';
import '../teacher/dashboard_nilai_guru.dart';
import '../../models/student.dart';
import '../../models/nilai.dart';
import '../../services/firestore_service.dart';

class InputNilaiForm extends StatefulWidget {
  final Student siswa;
  final String mapel;

  const InputNilaiForm({
    super.key,
    required this.siswa,
    required this.mapel,
  });

  @override
  State<InputNilaiForm> createState() => _InputNilaiFormState();
}

class _InputNilaiFormState extends State<InputNilaiForm> {
  final tugasC = TextEditingController();
  final utsC = TextEditingController();
  final uasC = TextEditingController();

  double nilaiAkhir = 0;
  String predikat = "-";

  void hitung() {
    final tugas = double.tryParse(tugasC.text) ?? 0;
    final uts = double.tryParse(utsC.text) ?? 0;
    final uas = double.tryParse(uasC.text) ?? 0;

    nilaiAkhir = tugas * 0.3 + uts * 0.3 + uas * 0.4;

    if (nilaiAkhir >= 85) {
      predikat = "A";
    } else if (nilaiAkhir >= 75) {
      predikat = "B";
    } else if (nilaiAkhir >= 65) {
      predikat = "C";
    } else {
      predikat = "D";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Input Nilai – ${widget.siswa.nama}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient Toska
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Colors.teal.shade900, Colors.black]
                    : [Colors.teal.shade300, Colors.teal.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Bulat-bulat background
          Positioned(top: -60, left: -30, child: _circleBg(200)),
          Positioned(bottom: -50, right: -40, child: _circleBg(160)),
          Positioned(bottom: 160, left: -20, child: _circleBg(110)),

          // Content Asli
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mapel: ${widget.mapel}",
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: tugasC,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Nilai Tugas",
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: utsC,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Nilai UTS",
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: uasC,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Nilai UAS",
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: hitung,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Hitung",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Nilai Akhir: ${nilaiAkhir.toStringAsFixed(1)}",
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                "Predikat: $predikat",
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              hitung();

                              final nilai = Nilai(
                                siswaId: widget.siswa.id,
                                mapel: widget.mapel,
                                tugas: double.tryParse(tugasC.text) ?? 0,
                                uts: double.tryParse(utsC.text) ?? 0,
                                uas: double.tryParse(uasC.text) ?? 0,
                                nilaiAkhir: nilaiAkhir,
                                predikat: predikat,
                              );

                              await fs.saveNilai(nilai);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Nilai berhasil disimpan"),
                                ),
                              );

                             Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                              builder: (_) => const DashboardNilaiGuru(),
  ),
);

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Simpan",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Circle Background Widget
  Widget _circleBg(double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDark ? Colors.white : Colors.white70).withOpacity(0.15),
      ),
    );
  }
}
