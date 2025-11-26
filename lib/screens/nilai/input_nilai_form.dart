import 'package:flutter/material.dart';
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

    if (nilaiAkhir >= 85) predikat = "A";
    else if (nilaiAkhir >= 75) predikat = "B";
    else if (nilaiAkhir >= 65) predikat = "C";
    else predikat = "D";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Input Nilai – ${widget.siswa.nama}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Mapel: ${widget.mapel}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            TextField(
              controller: tugasC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nilai Tugas"),
            ),
            TextField(
              controller: utsC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nilai UTS"),
            ),
            TextField(
              controller: uasC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nilai UAS"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: hitung, child: const Text("Hitung")),

            const SizedBox(height: 10),
            Text("Nilai Akhir: ${nilaiAkhir.toStringAsFixed(1)}", style: const TextStyle(fontSize: 18)),
            Text("Predikat: $predikat", style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),
            ElevatedButton(
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
                  const SnackBar(content: Text("Nilai berhasil disimpan")),
                );

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
