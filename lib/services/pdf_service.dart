import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/grade.dart';

class PdfService {
  static Future<void> generateRaporPDF({
    required String studentName,
    required String nis,
    required String kelas,
    required String jurusan,
    required List<Grade> nilaiList,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [

          // ===========================
          // 🟦 HEADER RAPOR
          // ===========================
          pw.Center(
            child: pw.Text(
              "RAPOR SISWA",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 24),

          // ===========================
          // 🟦 IDENTITAS SISWA
          // ===========================
          pw.Text("Nama: $studentName", style: pw.TextStyle(fontSize: 14)),
          pw.Text("NIS: $nis", style: pw.TextStyle(fontSize: 14)),
          pw.Text("Kelas: $kelas", style: pw.TextStyle(fontSize: 14)),
          pw.Text("Jurusan: $jurusan", style: pw.TextStyle(fontSize: 14)),

          pw.SizedBox(height: 20),

          // ===========================
          // 🟦 TABEL NILAI
          // ===========================
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(width: 1),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            headers: [
              'Mapel',
              'Tugas',
              'UTS',
              'UAS',
              'Akhir',
              'Predikat',
            ],
            data: nilaiList.map((g) {
              return [
                g.mapel,
                g.tugas.toString(),
                g.uts.toString(),
                g.uas.toString(),
                g.finalScore.toStringAsFixed(2),
                g.predicate,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 40),

          // ===========================
          // 🟦 TANDA TANGAN
          // ===========================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text("Wali Kelas"),
                  pw.SizedBox(height: 60),
                  pw.Text("( ______________________ )"),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text("Kepala Sekolah"),
                  pw.SizedBox(height: 60),
                  pw.Text("( ______________________ )"),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
